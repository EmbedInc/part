{   Routines that handle default values.
}
module part_def;
define part_def;
define part_def_list;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_DEF (PART)
*
*   Apply fill in default field values for the part PART.  This is done when a
*   field is blank, and a reasonable default value can be inferred from other
*   fields for which values are available.
}
procedure part_def (                   {default empty fields from others as possible}
  in out  part: part_t);               {part to apply defaults to}
  val_param;

var
  tk1, tk2: string_var132_t;           {scratch strings}

label
  have_desc;

begin
  tk1.max := size_char(tk1.str);       {init local var string}
  tk2.max := size_char(tk2.str);
{
*   Try to default description.
}
  if part.desc.len <= 0 then begin     {no explicit description string ?}
    string_copy (part.lib, part.desc); {init description to library name}

    string_copy (part.devu, tk1);      {get device name}
    string_copy (part.lib, tk2);       {get library name}
    tk1.len := min(tk1.len, tk2.len);  {truncate both to the shortest}
    tk2.len := tk1.len;
    if string_equal (tk1, tk2)         {device name redundant with library name ?}
      then goto have_desc;

    if part.val.len > 0 then begin     {this part has a value string ?}
      string_copy (part.devu, tk1);    {get device name}
      string_copy (part.val, tk2);     {get schematic value string}
      tk1.len := min(tk1.len, tk2.len); {truncate both to the shortest}
      tk2.len := tk1.len;
      string_upcase (tk2);             {upper case value string for match test}
      if string_equal (tk1, tk2)       {device name redundant with part value ?}
        then goto have_desc;
      end;

    string_appends (part.desc, ', '(0)); {add device name to lib to make description}
    string_append (part.desc, part.dev);
    end;
have_desc:                             {part description all set in TK}

  end;
{
********************************************************************************
*
*   Subroutine PART_DEF_LIST (LIST)
*
*   Same as PART_DEF, except that defaults are applied to all parts in a list
*   instead of a single part.  This routine is layered on PART_DEF.
}
procedure part_def_list (              {default empty fields from others as possible}
  in out  list: part_list_t);          {list of parts to apply defaults to}
  val_param;

var
  part_p: part_p_t;                    {to current part in list}

begin
  part_p := list.first_p;              {init to first part in list}
  while part_p <> nil do begin         {back here each new part}
    part_def (part_p^);                {apply defaults to this part}
    part_p := part_p^.next_p;          {to next part in list}
    end;                               {back to do this next part}
  end;
