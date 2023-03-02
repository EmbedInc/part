@echo off
rem
rem   BUILD_LIB
rem
rem   Build the PART library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_housename
call src_pas %srcdir% %libname%_list
call src_pas %srcdir% %libname%_ref_apply
call src_pas %srcdir% %libname%_reflist
call src_pas %srcdir% %libname%_reflist_read

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
