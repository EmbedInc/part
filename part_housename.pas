{   Routines to handle names of organizations with private ("in-house") part
*   numbers.
}
module part_housename;
define part_housename_get;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_HOUSENAME_GET (DIR, HOUSENAME, STAT)
*
*   Determine the name of the organization for which private in-house part
*   numbers apply in the directory DIR.  The organization name is returned in
*   HOUSENAME if found, else HOUSENAME is set to the empty string.  House names
*   are case-sensitive.
*
*   House names are defined by text files named HOUSENAME.  These can be in a
*   directory hierarchy.  The HOUSENAME file from the lowest parent directory
*   that contains one applies.  No house name is specified if there is no
*   HOUSENAME file in a directory or any of its parent directories all the way
*   to the root file system directory.
*
*   HOUSENAME files are simple text files with the case-senstive name of the
*   organization on the first line.
}
procedure part_housename_get (         {get name of org that owns private part numbers}
  in      dir: univ string_var_arg_t;  {directory to find housename that applies to it}
  in out  housename: univ string_var_arg_t; {returne organization name, empty if none}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  cdir: string_treename_t;             {name of current directory in hierarchy}
  pdir: string_treename_t;             {name of parent directory}
  tnam: string_treename_t;             {name of HOUSENAME file in curr directory}
  buf: string_var80_t;                 {first line read from HOUSENAME file}
  conn: file_conn_t;                   {connection to a HOUSENAME file}

begin
  cdir.max := size_char(cdir.str);     {init local var strings}
  pdir.max := size_char(pdir.str);
  tnam.max := size_char(tnam.str);
  buf.max := size_char(buf.str);
  sys_error_none (stat);               {init to no error encountered}
  housename.len := 0;                  {init to no house name applies to DIR}

  string_treename (dir, cdir);         {init to starting directory}
  while true do begin                  {up the hierarch of directories}
    string_copy (cdir, tnam);          {make name of HOUSENAME file in this dir}
    string_appends (tnam, '/housename'(0));

    file_open_read_text (tnam, '', conn, stat); {open connection to the file}
    if not file_not_found(stat) then begin {HOUSENAME file exists here ?}
      if sys_error(stat) then return;  {hard error trying to open file ?}
      file_read_text (conn, buf, stat); {read first line of file}
      file_close (conn);               {done with the file}
      if sys_error(stat) then return;  {hard error reading file ?}
      string_copy (buf, housename);    {return the organization name}
      return;
      end;

    string_pathname_split (            {make name of next directory up}
      cdir,                            {starting directory}
      pdir,                            {returned parent directory}
      tnam);                           {returned leafname (not used)}
    if string_equal (pdir, cdir) then exit; {ended up in same place (at top dir) ?}
    string_copy (pdir, cdir);          {go to parent directory}
    end;                               {back to try again in parent directory}
  end;
