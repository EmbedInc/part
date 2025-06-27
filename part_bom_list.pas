{   Routines that manipulate BOMs relative to parts lists.
}
module part_bom_list;
define part_bom_list_add;
define part_bom_list_make;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_BOM_LIST_ADD (BOM, LIST)
*
*   Add the parts in LIST to the end of BOM.
}
procedure part_bom_list_add (          {add BOM entries from parts list}
  in out  bom: part_bom_t;             {BOM to add entries to}
  in      list: part_list_t);          {list to create new BOM entries from}
  val_param;

var
  part_p: part_p_t;                    {to current part in list}
  p2_p: part_p_t;                      {to secondary part relative to current}
  ii: sys_int_machine_t;               {scratch integer}
  tk: string_var8192_t;                {scratch token or string}
  ent_p: part_bom_ent_p_t;             {to current BOM entry}

label
  done_part;
{
******************************
*
*   Local subroutine COPY_STR (STR, COPY_P)
*
*   Create a new copy of the string STR and set COYP_P pointing to the new copy.
*   Memory for the new copy will be allocated under the context of BOM.
}
procedure copy_str (                   {create copy of string}
  in      str: univ string_var_arg_t;  {the string to copy}
  out     copy_p: string_var_p_t);     {returned pointer to the new copy}
  val_param; internal;

begin
  string_alloc (str.len, bom.mem_p^, false, copy_p); {create new string}
  string_copy (str, copy_p^);          {copy into new string}
  end;
{
******************************
*
*   Start of PART_BOM_LIST_ADD
}
begin
  tk.max := size_char(tk.str);         {init local var string}
{
*   Scan thru the parts list and create one BOM entry for each unique part.
}
  part_p := list.first_p;              {init to first part in list}
  while part_p <> nil do begin         {scan the list of parts}
    if part_flag_nobom_k in part_p^.flags {this part not to be added to the BOM ?}
      then goto done_part;
    if part_flag_comm_k in part_p^.flags {already on a previous line ?}
      then goto done_part;
    part_bom_ent_end (bom, ent_p);     {create new blank BOM entry}
    {
    *   Quantity.
    }
    ii := round(part_p^.qty);          {make integer quantity}
    if abs(part_p^.qty - ii) < 0.0001
      then begin                       {quantity really is integer ?}
        string_f_int (ent_p^.qty, ii);
        end
      else begin                       {quantity must be written with fraction digits}
        string_f_fp_fixed (ent_p^.qty, part_p^.qty, 3);
        end
      ;
    {
    *   Designators, no Intrinsic Safety indicators.
    }
    tk.len := 0;                       {init list of designators}
    p2_p := part_p;                    {init to first part of this type}
    while p2_p <> nil do begin         {once for each component of this type}
      if p2_p^.desig.len > 0 then begin {this part has a designator ?}
        if tk.len > 0 then begin       {not first designator in list ?}
          string_append1 (tk, ' ');    {separator before new designator}
          end;
        string_append (tk, p2_p^.desig); {add this designator to list}
        end;
      p2_p := p2_p^.same_p;            {advance to next component using this part}
      end;
    copy_str (tk, ent_p^.desig_p);
    {
    *   Designators with "*" appended to indicate critical to Intrinsic Safety.
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
    copy_str (tk, ent_p^.desig_is_p);
    {
    *   Description.
    }
    copy_str (part_p^.desc, ent_p^.desc_p);
    {
    *   Value.
    }
    copy_str (part_p^.val, ent_p^.val_p);
    {
    *   Package.
    }
    copy_str (part_p^.pack, ent_p^.pack_p);
    {
    *   Substitute yes/no.
    }
    ent_p^.subst := part_flag_subst_k in part_p^.flags;
    {
    *   Inhouse #
    }
    copy_str (part_p^.housenum, ent_p^.inhouse_p);
    {
    *   Manufacturer.
    }
    copy_str (part_p^.manuf, ent_p^.manf_p);
    {
    *   Manufacturer part #.
    }
    copy_str (part_p^.mpart, ent_p^.manf_part_p);
    {
    *   Supplier.
    }
    copy_str (part_p^.supp, ent_p^.supp_p);
    {
    *   Supplier part #.
    }
    copy_str (part_p^.spart, ent_p^.supp_part_p);

done_part:                             {done with this part}
    part_p := part_p^.next_p;          {to next part in list}
    end;                               {back to process this next part}
  end;
{
********************************************************************************
*
*   Subroutine PART_BOM_LIST_MAKE (LIST, BOM_P)
*
*   Create a BOM from the parts list LIST.  BOM_P will be returned pointing to
*   the new BOM.  The BOM's memory will be subordinate to the list.  The BOM
*   will be automatically deleted when the list is deleted.
}
procedure part_bom_list_make (         {create BOM from parts list}
  in      list: part_list_t;           {list of parts to create BOM from}
  out     bom_p: part_bom_p_t);        {returned pointer to new BOM}
  val_param;

begin
  part_bom_new (bom_p, list.mem_p^);   {create a new empty BOM}
  part_bom_list_add (bom_p^, list);    {add the list parts to the BOM}
  end;
