module part_bom_csv;
define part_bom_csv;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_BOM_CSV (LIST, FNAM, STAT)
*
*   Write a BOM from the list of parts LIST.  The BOM is written in CSV (comma
*   separated values) format.  This file is meant for easy importing of the BOM
*   into other programs.  It does not contain any equations intended for
*   spreadsheet cells.
}
procedure part_bom_csv (               {write BOM CSV file, for reading by programs}
  in      list: part_list_t;           {list of parts to write BOM for}
  in      fnam: univ string_var_arg_t; {name of output file, ".csv" may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  cout: csv_out_t;                     {CSV file writing state}
  part_p: part_p_t;                    {to current part in list}
  p2_p: part_p_t;                      {to secondary part relative to current}
  ii: sys_int_machine_t;               {scratch integer}
  tk: string_var8192_t;                {scratch token or string}
  stat2: sys_err_t;                    {to avoid corrupting status in STAT}

label
  leave;

begin
  tk.max := size_char(tk.str);         {init local var string}

  csv_out_open (fnam, cout, stat);     {open the CSV output file}
  if sys_error(stat) then return;
{
*   Write the header line.  This line contains the names of each field.
}
  csv_out_str (cout, 'Qty', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Designators', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Desc', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Value', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Package', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Subst', stat); if sys_error(stat) then goto leave;

  if list.housename.len > 0
    then begin                         {we have explicit name for in-house parts}
      string_copy (list.housename, tk); {init with house name}
      string_appends (tk, ' #'(0));    {add "#"}
      csv_out_vstr (cout, tk, stat);
      if sys_error(stat) then goto leave;
      end
    else begin                         {no housename}
      csv_out_str (cout, 'Inhouse #', stat);
      if sys_error(stat) then goto leave;
      end
    ;

  csv_out_str (cout, 'Manuf', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Manuf part #', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Supplier', stat); if sys_error(stat) then goto leave;
  csv_out_str (cout, 'Supp part #', stat); if sys_error(stat) then goto leave;

  csv_out_line (cout, stat); if sys_error(stat) then goto leave;
{
*   Scan thru the components list and write one output file line for each unique
*   part.
}
  part_p := nil;                       {init to before all parts}
  while true do begin                  {back here to go to next part}
    if part_p = nil
      then begin                       {currently before first part}
        part_p := list.first_p;        {go to first part in list}
        end
      else begin                       {at an existing part}
        part_p := part_p^.next_p;      {to next part in list}
        end
      ;
    if part_p = nil then exit;         {hit end of list ?}

    if part_flag_nobom_k in part_p^.flags {this part not to be added to the BOM ?}
      then next;
    if part_flag_comm_k in part_p^.flags {already on a previous line ?}
      then next;
    {
    *   Quantity.
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

    csv_out_vstr (cout, tk, stat);
    if sys_error(stat) then goto leave;
    {
    *   Designators.
    }
    tk.len := 0;                       {init list of designators}
    p2_p := part_p;                    {init to first part of this type}
    while p2_p <> nil do begin         {once for each component of this type}
      if p2_p^.desig.len > 0 then begin {this part has a designator ?}
        if tk.len > 0 then begin       {not first designator in list ?}
          string_append1 (tk, ' ');    {separator before new designator}
          end;
        string_append (tk, p2_p^.desig); {add this designator to list}
        if part_flag_isafe_k in p2_p^.flags then begin {critical to Intrinsic Safety ?}
          string_append1 (tk, '*');
          end;
        end;
      p2_p := p2_p^.same_p;            {advance to next component using this part}
      end;

    csv_out_vstr (cout, tk, stat);
    if sys_error(stat) then goto leave;
    {
    *   Description.
    }
    csv_out_vstr (cout, part_p^.desc, stat);
    if sys_error(stat) then goto leave;
    {
    *   Value.
    }
    csv_out_vstr (cout, part_p^.val, stat);
    if sys_error(stat) then goto leave;
    {
    *   Package.
    }
    csv_out_vstr (cout, part_p^.pack, stat);
    if sys_error(stat) then goto leave;
    {
    *   Substitute yes/no.
    }
    if part_flag_subst_k in part_p^.flags
      then string_vstring (tk, 'Yes'(0), -1)
      else string_vstring (tk, 'No'(0), -1);
    csv_out_vstr (cout, tk, stat);
    if sys_error(stat) then goto leave;
    {
    *   Inhouse #
    }
    csv_out_vstr (cout, part_p^.housenum, stat);
    if sys_error(stat) then goto leave;
    {
    *   Manufacturer.
    }
    csv_out_vstr (cout, part_p^.manuf, stat);
    if sys_error(stat) then goto leave;
    {
    *   Manufacturer part #.
    }
    csv_out_vstr (cout, part_p^.mpart, stat);
    if sys_error(stat) then goto leave;
    {
    *   Supplier.
    }
    csv_out_vstr (cout, part_p^.supp, stat);
    if sys_error(stat) then goto leave;
    {
    *   Supplier part #.
    }
    csv_out_vstr (cout, part_p^.spart, stat);
    if sys_error(stat) then goto leave;

    csv_out_line (cout, stat);         {write this line to output file}
    if sys_error(stat) then goto leave;
    end;                               {back for next part in list}

leave:                                 {common exit point with file open, STAT set}
  csv_out_close (cout, stat2);         {close the output file}
  end;
