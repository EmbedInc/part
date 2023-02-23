@echo off
rem
rem   NEWNAME fnam
rem
rem   Update references in a file from the old PARTREF_ symbol names to the new
rem   PART_ symbol names.  These names were changed when the PARTREF routines
rem   were moved from the STUFF library to the new PART library.
rem
call edit_one "%~1" partref_part_p_t part_ref_p_t
call edit_one "%~1" partref_part_t part_ref_t
call edit_one "%~1" partref_list_p_t part_reflist_p_t
call edit_one "%~1" partref_list_t part_reflist_t
call edit_one "%~1" partref_list_del part_reflist_del
call edit_one "%~1" partref_list_init part_reflist_init
call edit_one "%~1" partref_part_add_end part_reflist_add_end
call edit_one "%~1" partref_part_new part_reflist_new
call edit_one "%~1" partref_read_csv part_reflist_read_csv

call reformat "%~1"
