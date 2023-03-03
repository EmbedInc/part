module part_bom_tsv;
define part_bom_tsv;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subrouitine PART_BOM_TSV (LIST, FNAM, STAT)
*
*   Write the list of parts LIST as a BOM to a TSV (tab-separated values) file.
*   The TSV file is intended for importing into a spreadsheet, and contains
*   formulas for costs, quantities, and the like.
}
procedure part_bom_tsv (               {write BOM for spreadsheet, with equations}
  in      list: part_list_t;           {list of parts to write BOM for}
  in      fnam: univ string_var_arg_t; {name of output file, ".tsv" may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param;

const
  tab = chr(9);                        {ASCII TAB character}

var
  conn: file_conn_t;                   {connection to the TSV output file}
  part_p: part_p_t;                    {to current part in list}
  p2_p: part_p_t;                      {to secondary part relative to current}
  ii: sys_int_machine_t;               {scratch integer}
  buf: string_var8192_t;               {one line output buffer}
  tk: string_var8192_t;                {scratch token or string}
  tk2: string_var80_t;                 {secondary token or string}
  olempty: boolean;                    {output line is completely empty}

label
  next_part, leave;
{
****************************************
*
*   Internal subroutine PUTFIELD (F)
*
*   Add the string F as a new field to the end of the current output file line
*   in BUF.
}
procedure putfield (                   {append field to current output line}
  in      f: univ string_var_arg_t);   {string to append as new field}
  val_param; internal;

begin
  if not olempty then begin            {output line is not completely empty ?}
    string_append1 (buf, tab);         {add separator after previous field}
    end;
  string_append (buf, f);              {add the new field}
  olempty := false;                    {line is no longer empty, even if nothing added}
  end;
{
****************************************
*
*   Internal subroutine PUTBLANK
*
*   Set the next field to blank.  This is the same as writing the empty string
*   to the field.
}
procedure putblank;                    {write empty string to next field}

var
  s: string_var4_t;

begin
  s.max := size_char(s.str);           {build a empty string}
  s.len := 0;
  putfield (s);                        {write it as the value of the next field}
  end;
{
****************************************
*
*   Internal subroutine WOUT (STAT)
*
*   Write the string in BUF as the next line to the output file.  BUF will be
*   reset to empty, and LINE will be advanced to indicate the new line that will
*   now be built.
}
procedure wout (                       {write BUF to output file}
  out     stat: sys_err_t);            {completion status}
  val_param; internal;

begin
  file_write_text (buf, conn, stat);   {write line to output file}
  buf.len := 0;                        {reset output buffer to empty}
  olempty := true;                     {init new line as being completely empty}
  end;
{
****************************************
*
*   Start of main routine.
}
begin
  buf.max := size_char(buf.str);       {init local var strings}
  tk.max := size_char(tk.str);
  tk2.max := size_char(tk2.str);

  file_open_write_text (               {open the TSV output file}
    fnam, '.tsv',                      {file name and mandatory suffix}
    conn,                              {returned connection to the file}
    stat);
  if sys_error(stat) then return;

  buf.len := 0;                        {init output line to empty}
  olempty := true;
{
*   Write the column names as the first output file line.
}
  putfield (string_v('1'));            {A, quantity in production run}
  putfield (string_v('Qty'));          {B}
  putfield (string_v('Designators'));  {C}
  putfield (string_v('Desc'));         {D}
  putfield (string_v('Value'));        {E}
  putfield (string_v('Package'));      {F}
  putfield (string_v('Subst'));        {G}
  if list.housename.len > 0
    then begin                         {we have explicit name for in-house parts}
      string_copy (list.housename, tk); {init with house name}
      string_appends (tk, ' #'(0));    {add "#"}
      end
    else begin                         {no housename}
      string_vstring (tk, 'Inhouse #'(0), -1);
      end
    ;
  putfield (tk);                       {H, in-house part number}
  putfield (string_v('Manuf'));        {I}
  putfield (string_v('Manuf part #')); {J}
  putfield (string_v('Supplier'));     {K}
  putfield (string_v('Supp part #'));  {L}
  putfield (string_v('$Part'));        {M}
  putfield (string_v('$Board'));       {N}
  putfield (string_v('$All'));         {O}

  wout (stat);                         {write this line to the output file}
  if sys_error(stat) then goto leave;
{
*   Scan thru the components list and write one output file line for each unique
*   part.
}
  part_p := list.first_p;              {init current component to first in list}
  while part_p <> nil do begin         {scan thru the entire list of components}
    if part_flag_nobom_k in part_p^.flags {this part not to be added to the BOM ?}
      then goto next_part;
    if part_flag_comm_k in part_p^.flags {already on a previous line ?}
      then goto next_part;
    {
    *   Column A: Quantity in whole production run.  Cell A1 is the number of
    *   units in the run.
    }
    string_vstring (tk, '=B'(0), -1);  {A: =Bn*A$1}
    string_f_int (tk2, conn.lnum+1);
    string_append (tk, tk2);
    string_appends (tk, '*A$1'(0));
    putfield (tk);
    {
    *   Column B: Quantity per unit.
    }
    ii := round(part_p^.qty);          {make integer quantity}
    if abs(part_p^.qty - ii) < 0.0001
      then begin                       {quantity really is integer ?}
        string_f_int (tk, ii);
        end
      else begin                       {quantity must be written with fraction digits}
        string_f_fp_fixed (tk, part_p^.qty, 3);
        end
      ;
    putfield (tk);                     {quantity}
    {
    *   Column C: List of component designators.
    }
    string_copy (part_p^.desig, tk);   {init designators list to first component}
    p2_p := part_p^.same_p;            {init to second component using this part}
    while p2_p <> nil do begin         {once for each component using this part}
      string_append1 (tk, ' ');        {separator before new designator}
      string_append (tk, p2_p^.desig); {add this designator}
      p2_p := p2_p^.same_p;            {advance to next component using this part}
      end;
    putfield (tk);                     {list of designators using this part}
    {
    *   Column D: Description
    }
    putfield (part_p^.desc);           {part description string}
    {
    *   Column E: Value
    }
    putfield (part_p^.val);            {part value}
    {
    *   Column F: Package
    }
    putfield (part_p^.pack);           {package}
    {
    *   Column G: Substitution allowed yes/no
    }
    if part_flag_subst_k in part_p^.flags
      then string_vstring (tk, 'Yes'(0), -1)
      else string_vstring (tk, 'No'(0), -1);
    putfield (tk);                     {substitution allowed Yes/No}
    {
    *   Column H: In-house part number.
    }
    putfield (part_p^.housenum);
    {
    *   Column I: Manufacturer name.
    }
    putfield (part_p^.manuf);          {manufacturer name}
    {
    *   Column J: Manufacturer part number.
    }
    putfield (part_p^.mpart);          {manufacturer part number}
    {
    *   Column K: Supplier name.
    }
    putfield (part_p^.supp);           {supplier name}
    {
    *   Column L: Supplier part number.
    }
    putfield (part_p^.spart);          {supplier part number}
    {
    *   Column M: Cost for each component.
    }
    putblank;                          {$ for each component}
    {
    *   Column N: Cost of all these parts per unit.
    }
    string_vstring (tk, '=B'(0), -1);  {$Board: =Bn*Mn}
    string_f_int (tk2, conn.lnum+1);
    string_append (tk, tk2);
    string_appends (tk, '*M'(0));
    string_append (tk, tk2);
    putfield (tk);
    {
    *   Column O: Cost of all these parts for all units.
    }
    string_vstring (tk, '=A'(0), -1);  {$All: =An*Mn}
    string_f_int (tk2, conn.lnum+1);
    string_append (tk, tk2);
    string_appends (tk, '*M'(0));
    string_append (tk, tk2);
    putfield (tk);

    wout (stat);                       {write this line to the output file}
    if sys_error(stat) then goto leave;

next_part:                             {done processing the current part}
    part_p := part_p^.next_p;          {advance to next component}
    end;                               {back and process this new component}
{
*   Write the lines for additional costs that are not parts to install on the
*   board.
}
  {
  *   Kitting cost.
  }
  string_vstring (tk, '=B'(0), -1);    {A, Qty/lot, =Bn*A$1}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*A$1'(0));
  putfield (tk);

  putfield (string_v('1'));            {B, quantity}
  putblank;                            {C, designators}
  putfield (string_v('Kitting'));      {D, description}

  putblank;                            {E, value}
  putblank;                            {F, package}
  putblank;                            {G, substitution allowed}
  putblank;                            {H, In-house}
  putblank;                            {I, manufacturer}
  putblank;                            {J, manuf part number}
  putblank;                            {K, supplier}
  putblank;                            {L, supplier part number}
  putblank;                            {M, $Part}

  string_vstring (tk, '=B'(0), -1);    {N, $Board, =Bn*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  string_vstring (tk, '=A'(0), -1);    {O, $All, =An*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  wout (stat);                         {write this line to the output file}
  if sys_error(stat) then goto leave;
  {
  *   Manufacturing cost.
  }
  string_vstring (tk, '=B'(0), -1);    {A, Qty/lot, =Bn*A$1}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*A$1'(0));
  putfield (tk);

  putfield (string_v('1'));            {B, quantity}
  putblank;                            {C, designators}

  putfield (string_v('Manufacturing')); {D, description}

  putblank;                            {E, value}
  putblank;                            {F, package}
  putblank;                            {G, substitution allowed}
  putblank;                            {H, In-house}
  putblank;                            {I, manufacturer}
  putblank;                            {J, manuf part number}
  putblank;                            {K, supplier}
  putblank;                            {L, supplier part number}
  putblank;                            {M, $Part}

  string_vstring (tk, '=B'(0), -1);    {N, $Board, =Bn*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  string_vstring (tk, '=A'(0), -1);    {O, $All, =An*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  wout (stat);                         {write this line to the output file}
  if sys_error(stat) then goto leave;
  {
  *   Testing.
  }
  string_vstring (tk, '=B'(0), -1);    {A, Qty/lot, =Bn*A$1}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*A$1'(0));
  putfield (tk);

  putfield (string_v('1'));            {B, quantity}
  putblank;                            {C, designators}

  putfield (string_v('Testing'));      {D, description}

  putblank;                            {E, value}
  putblank;                            {F, package}
  putblank;                            {G, substitution allowed}
  putblank;                            {H, In-house}
  putblank;                            {I, manufacturer}
  putblank;                            {J, manuf part number}
  putblank;                            {K, supplier}
  putblank;                            {L, supplier part number}
  putblank;                            {M, $Part}

  string_vstring (tk, '=B'(0), -1);    {N, $Board, =Bn*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  string_vstring (tk, '=A'(0), -1);    {O, $All, =An*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  wout (stat);                         {write this line to the output file}
  if sys_error(stat) then goto leave;
  {
  *   Delivery.
  }
  string_vstring (tk, '=B'(0), -1);    {A, Qty/lot, =Bn*A$1}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*A$1'(0));
  putfield (tk);

  putfield (string_v('1'));            {B, quantity}
  putblank;                            {C, designators}

  putfield (string_v('Delivery to stock')); {D, description}

  putblank;                            {E, value}
  putblank;                            {F, package}
  putblank;                            {G, substitution allowed}
  putblank;                            {H, In-house}
  putblank;                            {I, manufacturer}
  putblank;                            {J, manuf part number}
  putblank;                            {K, supplier}
  putblank;                            {L, supplier part number}
  putblank;                            {M, $Part}

  string_vstring (tk, '=B'(0), -1);    {N, $Board, =Bn*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  string_vstring (tk, '=A'(0), -1);    {O, $All, =An*Mn}
  string_f_int (tk2, conn.lnum+1);
  string_append (tk, tk2);
  string_appends (tk, '*M'(0));
  string_append (tk, tk2);
  putfield (tk);

  wout (stat);                         {write this line to the output file}
  if sys_error(stat) then goto leave;
{
*   Write the final line that shows the total cost for the production run.
}
  putblank;                            {A, Qty/lot}
  putblank;                            {B, Qty/unit}
  putblank;                            {C, designators}

  putfield (string_v('Total cost'));   {D, description}

  putblank;                            {E, value}
  putblank;                            {F, package}
  putblank;                            {G, substitution allowed}
  putblank;                            {H, In-house}
  putblank;                            {I, manufacturer}
  putblank;                            {J, manuf part number}
  putblank;                            {K, supplier}
  putblank;                            {L, supplier part number}
  putblank;                            {M, $Part}

  string_vstring (tk, '=SUM(N2:N'(0), -1); {N, $Board, =SUM(N2:Nn)}
  string_f_int (tk2, conn.lnum);
  string_append (tk, tk2);
  string_appends (tk, ')'(0));
  putfield (tk);

  string_vstring (tk, '=SUM(O2:O'(0), -1); {O, $All, =SUM(O2:On)}
  string_f_int (tk2, conn.lnum);
  string_append (tk, tk2);
  string_appends (tk, ')'(0));
  putfield (tk);

  wout (stat);                         {write this line to the output file}
{
*   Common exit point after file open.  STAT is already set.
}
leave:
  file_close (conn);
  end;
