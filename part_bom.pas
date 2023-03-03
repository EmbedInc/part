{   Routines related to BOMs (bills of materials).
}
module part_bom;
define part_bom_template;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_BOM_TEMPLATE (DIR, GNAM, STAT)
*
*   Copy the BOM template spreadsheet into the directory DIR.  GNAM is the name
*   of the board the BOM is for, and is the generic name of files related to the
*   board.  The template file will be named "<gnam>_bom.xls" within the DIR
*   directory.
}
procedure part_bom_template (          {copy BOM template spreadsheet into dir}
  in      dir: univ string_var_arg_t;  {directory to copy template spreadsheet into}
  in      gnam: univ string_var_arg_t; {generic board name}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tnam: string_treename_t;             {pathname of the template file}

begin
  tnam.max := size_char(tnam.str);     {init local var string}

  string_pathname_join (dir, gnam, tnam); {build the destination file name}
  string_appends (tnam, '_bom.xls'(0));

  file_copy (                          {copy template spreadsheet file}
    string_v('(cog)progs/part_lib/bom_template.xls'(0)), {source file name}
    tnam,                              {destination file name}
    [file_copy_replace_k],             {overwrite existing file, if any}
    stat);
  end;
