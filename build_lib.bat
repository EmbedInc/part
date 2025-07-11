@echo off
rem
rem   BUILD_LIB
rem
rem   Build the PART library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_bom
call src_pas %srcdir% %libname%_bom_csv
call src_pas %srcdir% %libname%_bom_list
call src_pas %srcdir% %libname%_bom_template
call src_pas %srcdir% %libname%_bom_tsv
call src_pas %srcdir% %libname%_comm
call src_pas %srcdir% %libname%_def
call src_pas %srcdir% %libname%_housename
call src_pas %srcdir% %libname%_list
call src_pas %srcdir% %libname%_ref_apply
call src_pas %srcdir% %libname%_ref_write
call src_pas %srcdir% %libname%_reflist
call src_pas %srcdir% %libname%_reflist_read

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
