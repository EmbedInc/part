{   Routines for manipulating lists of reference part definitions.
}
module part_reflist;
define part_reflist_new;
define part_reflist_del;
define part_reflist_ent_new;
define part_reflist_ent_add_end;
define part_reflist_ent_new_end;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_REFLIST_NEW (LIST_P, MEM)
*
*   Create a new reference parts list.  LIST_P will be returned pointing to the
*   new list.  MEM is the parent memory context.  A private subordinate memory
*   context will be created for the list.
}
procedure part_reflist_new (           {create new empty list of reference parts}
  out     list_p: part_reflist_p_t;    {returned pointer to the new list}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param;

var
  mem_p: util_mem_context_p_t;         {to our new private memory context}
  stat: sys_err_t;                     {completion status}

begin
  util_mem_context_get (mem, mem_p);   {make new subordinate memory context}
  if util_mem_context_err (mem_p, stat) then begin
    sys_error_abort (stat, '', '', nil, 0);
    end;

  util_mem_grab (                      {allocate memory for new list structure}
    sizeof(list_p^), mem_p^, false, list_p);
  if util_mem_grab_err (list_p, sizeof(list_p^), stat) then begin
    sys_error_abort (stat, '', '', nil, 0);
    end;

  list_p^.mem_p := mem_p;              {save pointer to private mem context}
  list_p^.first_p := nil;              {init the list to empty}
  list_p^.last_p := nil;
  list_p^.nparts := 0;
  end;
{
********************************************************************************
*
*   Subroutine PART_REFLIST_DEL (LIST_P)
*
*   Delete the refernce parts list pointed to by LIST_P.  All dynamic memory
*   allocated to the list will be deallocated.  LIST_P is returned NIL.
}
procedure part_reflist_del (           {delete reference parts list, deallocate resources}
  in out  list_p: part_reflist_p_t);   {pointer to list to delete, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {temp saved pointer to list mem context}

begin
  if list_p = nil then return;         {no list, nothing to do ?}

  mem_p := list_p^.mem_p;              {get pointer to list's memory context}
  util_mem_context_del (mem_p);        {deallocate all list memory}

  list_p := nil;                       {invalidate the pointer to the list}
  end;
{
********************************************************************************
*
*   Subroutine PART_REFLIST_ENT_NEW (LIST, PART_P)
*
*   Create and initialize a new reference parts list entry.  PART_P is returned
*   pointing to the new part descriptor.  The part is not added to the list, but
*   it will be deallocated when the list is deleted.  The part can be
*   subsequently added to the list with a PART_REFLIST_END_ADD_xxx routine.
}
procedure part_reflist_ent_new (       {create and init new reference parts list entry}
  in out  list: part_reflist_t;        {the list the entry will be part of}
  out     part_p: part_ref_p_t);       {returned pointer to the new entry, not linked}
  val_param;

var
  stat: sys_err_t;                     {completion status}

begin
  util_mem_grab (                      {allocate memory for new part}
    sizeof(part_p^), list.mem_p^, false, part_p);
  if util_mem_grab_err (part_p, sizeof(part_p^), stat) then begin
    sys_error_abort (stat, '', '', nil, 0);
    end;

  part_p^.prev_p := nil;               {initialize the fields}
  part_p^.next_p := nil;
  part_p^.desc.max := size_char(part_p^.desc.str);
  part_p^.desc.len := 0;
  part_p^.value.max := size_char(part_p^.value.str);
  part_p^.value.len := 0;
  part_p^.package.max := size_char(part_p^.package.str);
  part_p^.package.len := 0;
  part_p^.subst_set := false;
  part_p^.subst := true;
  nameval_list_init (part_p^.inhouse, list.mem_p^);
  nameval_list_init (part_p^.manuf, list.mem_p^);
  nameval_list_init (part_p^.supplier, list.mem_p^);
  end;
{
********************************************************************************
*
*   Subroutine PART_REFLIST_ENT_ADD_END (LIST, PART_P)
*
*   Add the part at PART_P to the end of the reference part list LIST.
}
procedure part_reflist_ent_add_end (   {add part to end of reference parts list}
  in out  list: part_reflist_t;        {the list to add the part to}
  in      part_p: part_ref_p_t);       {pointer to the part to add}
  val_param;

begin
  part_p^.prev_p := list.last_p;       {set links in the entry}
  part_p^.next_p := nil;

  if list.last_p = nil
    then begin                         {the list is currently empty}
      list.first_p := part_p;
      end
    else begin                         {there are one or more previous entries}
      list.last_p^.next_p := part_p;
      end
    ;
  list.last_p := part_p;

  list.nparts := list.nparts + 1;      {count one more entry in the list}
  end;
{
********************************************************************************
*
*   Subroutine PART_REFLIST_ENT_NEW_END (LIST, PART_P)
*
*   Create and initialize a new reference part, then add it to the end of the
*   reference part list LIST.  PART_P is returned pointing to the new part.
}
procedure part_reflist_ent_new_end (   {add new initialized entry to end of ref parts list}
  in out  list: part_reflist_t;        {the list the entry will be part of}
  out     part_p: part_ref_p_t);       {returned pointer to the new entry, not linked}
  val_param;

begin
  part_reflist_ent_new (list, part_p); {create and init new part descriptor}
  part_reflist_ent_add_end (list, part_p); {add it to the end of the list}
  end;
