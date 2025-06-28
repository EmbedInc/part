module part_ref_write;
define part_ref_write;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_REF_WRITE (LIST, FNAM, STAT)
*
*   Write the list of parts in the format of a reference parts list CSV file.
*   The fields on each line are:
*
*     Desc,Value,Package,Subst,Inhouse #,Manuf,Manuf part #,Supplier,Supp part #
}
procedure part_ref_write (             {write parts list in reference list CSV format}
  in      list: part_list_t;           {list of parts to write}
  in      fnam: univ string_var_arg_t; {name of output file, ".csv" may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  cout: csv_out_t;                     {CSV file writing state}
  part_p: part_p_t;                    {points to current part in parts list}
  tk: string_var8192_t;                {scratch token or string}
  stat2: sys_err_t;                    {to avoid corrupting STAT}

label
  next_part, leave;

begin
  tk.max := size_char(tk.str);         {init local var string}

  csv_out_open (fnam, cout, stat);     {open CSV output file}
  if sys_error(stat) then return;
  cout.flags :=                        {write only min required characters}
    cout.flags + [csv_outflag_minchar_k];

  part_p := list.first_p;              {init current component to first in list}
  while part_p <> nil do begin         {scan thru the entire list of components}
    if part_flag_nobom_k in part_p^.flags {this part not to be added to the BOM ?}
      then goto next_part;
    if part_flag_comm_k in part_p^.flags {already on a previous line ?}
      then goto next_part;

    csv_out_vstr (cout, part_p^.desc, stat); {description}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.val, stat); {value}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.pack, stat); {package}
    if sys_error(stat) then goto leave;

    if part_flag_subst_k in part_p^.flags
      then string_vstring (tk, 'Yes'(0), -1)
      else string_vstring (tk, 'No'(0), -1);
    csv_out_vstr (cout, tk, stat);     {substitute allowed yes/no}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.housenum, stat); {in-house part number}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.manuf, stat); {manufacturer name}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.mpart, stat); {manufacturer part number}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.supp, stat); {supplier name}
    if sys_error(stat) then goto leave;

    csv_out_vstr (cout, part_p^.spart, stat); {supplier part number}
    if sys_error(stat) then goto leave;

    csv_out_line (cout, stat);         {write this line to output file}
    if sys_error(stat) then goto leave;

next_part:                             {done processing the current part}
    part_p := part_p^.next_p;          {advance to next component in list}
    end;                               {back and process this new component}

leave:                                 {common exit point with file open, STAT set}
  csv_out_close (cout, stat2);         {close the output file}
  end;
