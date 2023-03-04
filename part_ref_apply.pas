module part_ref_apply;
define part_ref_apply;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_REF_APPLY (LIST, REF)
*
*   Apply the information in the reference parts list REF to the parts in the
*   list LIST.  LIST.REFLIST_P will be set pointing to the reference list unless
*   a reference list was previously set.
}
procedure part_ref_apply (             {apply reference parts into to parts list}
  in out  list: part_list_t;           {parts to update to with reference info}
  in var  ref: part_reflist_t);        {list of refrence parts}
  val_param;

var
  part_p: part_p_t;                    {to current part in parts list}
  ref_p: part_ref_p_t;                 {to current reference part}
  nvent_p: nameval_ent_p_t;            {points to curr name/value list entry}
  ii: sys_int_machine_t;               {scratch integer}
  tk: string_var80_t;                  {scratch token}
  absmatch: boolean;                   {absolute part match}

label
  refmatch, doneref;

begin
  tk.max := size_char(tk.str);         {init local var string}

  if list.reflist_p = nil then begin   {no reference list previously set ?}
    list.reflist_p := addr(ref);       {set REF as the reference list}
    end;

  part_p := list.first_p;              {init to first part in list}
  while part_p <> nil do begin         {once for each part in the list}
    ref_p := ref.first_p;              {init to first reference part}
    while ref_p <> nil do begin        {scan list of reference parts}
{
*   PART_P is pointing to the part in this BOM, and REF_P is pointing to the
*   reference part to compare it to.
*
*   Look for absolute match first.  If a manufacturer part number, supplier part
*   number, or the inhouse number match, then this will be considered a matching
*   reference part.
}
  absmatch := true;                    {match will be absolute if found here}

  ii := nameval_match (                {get manufacturer part number match}
    ref_p^.manuf,                      {the name/value pair to compare to}
    part_p^.manuf,                     {name to compare against}
    part_p^.mpart);                    {value to compare against}
  if ii > 0 then goto refmatch;        {definitely matches ?}
  if ii < 0 then goto doneref;         {definitely does not match ?}

  ii := nameval_match (                {get supplier part number match}
    ref_p^.supplier,                   {the name/value pair to compare to}
    part_p^.supp,                      {name to compare against}
    part_p^.spart);                    {value to compare against}
  if ii > 0 then goto refmatch;        {definitely matches ?}
  if ii < 0 then goto doneref;         {definitely does not match ?}

  ii := nameval_match (                {get inhouse part number match}
      ref_p^.inhouse,                  {the name/value pair to compare to}
      list.housename,                  {name to compare against}
      part_p^.housenum);               {value to compare against}
  if ii > 0 then goto refmatch;        {definitely matches ?}
  if ii < 0 then goto doneref;         {definitely does not match ?}
{
*   No absolute match was found.  These fields also did not indicate an absolute
*   mismatch.
*
*   For this reference part to match this BOM part, at least one of the
*   remaining fields must be a match, and none of them must be a mismatch.
}
  absmatch := false;                   {matches found here won't be absolute}
  ii := 0;                             {init number of fields with explicit matches}

  if (part_p^.desc.len > 0) and (ref_p^.desc.len > 0) then begin
    if not string_equal(part_p^.desc, ref_p^.desc) then goto doneref;
    ii := ii + 1;
    end;

  if (part_p^.val.len > 0) and (ref_p^.value.len > 0) then begin
    if not string_equal(part_p^.val, ref_p^.value) then goto doneref;
    ii := ii + 1;
    end;

  if (part_p^.pack.len > 0) and (ref_p^.package.len > 0) then begin
    if not string_equal(part_p^.pack, ref_p^.package) then goto doneref;
    ii := ii + 1;
    end;

  if ii <= 0 then goto doneref;        {no matching field found at all ?}
{
*   This reference part matches this BOM part.
*
*   Fill in or update fields in the BOM part from those in the reference part.
}
refmatch:                              {this is a matching reference part}
  if
      (ref_p^.desc.len > 0) and        {reference description exists ?}
      ((part_p^.desc.len = 0) or absmatch)
      then begin
    string_copy (ref_p^.desc, part_p^.desc); {use the reference description}
    end;

  if
      (ref_p^.value.len > 0) and       {reference value exists ?}
      ((ref_p^.value.len > part_p^.val.len) or absmatch) {longer than existing value ?}
      then begin
    string_copy (ref_p^.value, part_p^.val); {use the reference part value}
    end;

  if
      (ref_p^.package.len > 0) and     {reference package name exists ?}
      ((part_p^.pack.len <= 0) or absmatch)
      then begin
    string_copy (ref_p^.package, part_p^.pack);
    end;

  if
      ref_p^.subst_set and
      (not ref_p^.subst)
      then begin
    part_p^.flags := part_p^.flags - [part_flag_subst_k]; {disallow substitutions}
    end;

  nvent_p := ref_p^.manuf.first_p;     {get manuf name and part num if appropriate}
  if
      (nvent_p <> nil) and             {refernce manufacturer info exists ?}
      ((part_p^.manuf.len <= 0) or absmatch) {better than what we already have ?}
      then begin
    if nvent_p^.name_p <> nil then begin {ref manuf name exists ?}
      string_copy (nvent_p^.name_p^, part_p^.manuf);
      end;
    if nvent_p^.value_p <> nil then begin {ref manuf part number exists ?}
      string_copy (nvent_p^.value_p^, part_p^.mpart);
      end;
    end;

  nvent_p := ref_p^.supplier.first_p;  {get supplier name and partnum if appropriate}
  if
      (nvent_p <> nil) and             {reference supplier info exists ?}
      ((part_p^.supp.len <= 0) or absmatch) {better than what we already have ?}
      then begin
    if nvent_p^.name_p <> nil then begin {ref supplier name exists ?}
      string_copy (nvent_p^.name_p^, part_p^.supp);
      end;
    if nvent_p^.value_p <> nil then begin {ref supplier part number exists ?}
      string_copy (nvent_p^.value_p^, part_p^.spart);
      end;
    end;

  if part_p^.housenum.len <= 0 then begin {don't already have in-house number ?}
    if nameval_get_val (               {ref part has inhouse number ?}
        ref_p^.inhouse,
        list.housename,
        tk) then begin
      string_copy (tk, part_p^.housenum); {yes, copy it into BOM part}
      end;
    end;

doneref:                               {done with this ref part}
      ref_p := ref_p^.next_p;          {advance to next reference part in list}
      end;                             {back to compare against this new ref part}
    part_p := part_p^.next_p;          {advance to the next part in the list}
    end;                               {back to process this new part}
  end;
