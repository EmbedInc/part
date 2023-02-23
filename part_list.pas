{   Routines to manage lists of parts.
}
module part_list;
define part_list_new;
define part_list_del;
define part_list_ent_new;
define part_list_ent_add_end;
define part_list_ent_new_end;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_LIST_NEW (LIST_P, MEM)
*
*   Create a new parts list.  LIST_P will be returned pointing to the new list.
*   MEM is the parent memory context.  A private subordinate memory context will
*   be created for the list.
}
procedure part_list_new (              {create new parts list}
  out     list_p: part_list_p_t;       {returned pointer to the new list}
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
*   Subroutine PART_LIST_DEL (LIST_P)
*
*   Delete the parts list pointed to by LIST_P.  All dynamic memory allocated to
*   the list will be deallocated.  LIST_P is returned NIL.
}
procedure part_list_del (              {delete parts list, deallocate resources}
  in out  list_p: part_list_p_t);      {pointer to list to delete, returned NIL}
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
*   Subroutine PART_LIST_ENT_NEW (LIST, PART_P)
*
*   Create and initialize a new parts list entry.  PART_P is returned pointing
*   to the new part descriptor.  The part is not added to the list, but it will
*   be deallocated when the list is deleted.  The part can be subsequently added
*   to the list with a PART_LIST_END_ADD_xxx routine.
}
procedure part_list_ent_new (          {create and initialize new parts list entry}
  in out  list: part_list_t;           {the list the entry will be part of}
  out     part_p: part_p_t);           {returned pointer to the new entry, not linked}
  val_param;

var
  stat: sys_err_t;                     {completion status}

begin
  util_mem_grab (                      {allocate memory for new part}
    sizeof(part_p^), list.mem_p^, false, part_p);
  if util_mem_grab_err (part_p, sizeof(part_p^), stat) then begin
    sys_error_abort (stat, '', '', nil, 0);
    end;

  part_p^.next_p := nil;
  part_p^.line := 0;
  part_p^.qtyuse := 1.0;
  part_p^.desig.max := size_char(part_p^.desig.str);
  part_p^.desig.len := 0;
  part_p^.lib.max := size_char(part_p^.lib.str);
  part_p^.lib.len := 0;
  part_p^.dev.max := size_char(part_p^.dev.str);
  part_p^.dev.len := 0;
  part_p^.devu.max := size_char(part_p^.devu.str);
  part_p^.devu.len := 0;
  part_p^.desc.max := size_char(part_p^.desc.str);
  part_p^.desc.len := 0;
  part_p^.val.max := size_char(part_p^.val.str);
  part_p^.val.len := 0;
  part_p^.pack.max := size_char(part_p^.pack.str);
  part_p^.pack.len := 0;
  part_p^.manuf.max := size_char(part_p^.manuf.str);
  part_p^.manuf.len := 0;
  part_p^.mpart.max := size_char(part_p^.mpart.str);
  part_p^.mpart.len := 0;
  part_p^.supp.max := size_char(part_p^.supp.str);
  part_p^.supp.len := 0;
  part_p^.spart.max := size_char(part_p^.spart.str);
  part_p^.spart.len := 0;
  part_p^.housenum.max := size_char(part_p^.housenum.str);
  part_p^.housenum.len := 0;
  part_p^.flags := [];
  part_p^.same_p := nil;
  part_p^.qty := part_p^.qtyuse;
  end;
{
********************************************************************************
*
*   Subroutine PART_LIST_ENT_ADD (LIST, PART_P)
*
*   Add the part at PART_P to the end of the list LIST.
}
procedure part_list_ent_add_end (      {add part to end of parts list}
  in out  list: part_list_t;           {the list to add the part to}
  in      part_p: part_p_t);           {to the part to add}
  val_param;

begin
  part_p^.next_p := nil;               {this part will be at end of list}

  if list.last_p = nil
    then begin                         {adding to empty list}
      list.first_p := part_p;
      end
    else begin                         {adding to existing list}
      list.last_p^.next_p := part_p;
      end
    ;
  list.last_p := part_p;               {this part is now last in the list}

  list.nparts := list.nparts + 1;      {count one more part in the list}
  end;
{
********************************************************************************
*
*   Subroutine PART_LIST_ENT_NEW_END (LIST, PART_P)
*
*   Create and initialize a new part, then add it to the end of the list LIST.
*   PART_P is returned pointing to the new part.
}
procedure part_list_ent_new_end (      {create and init new part, add to end of list}
  in out  list: part_list_t;           {the list the part will be added to}
  out     part_p: part_p_t);           {returned pointer to the new part}
  val_param;

begin
  part_list_ent_new (list, part_p);    {create and init new part descriptor}
  part_list_ent_add_end (list, part_p); {add it to the end of the list}
  end;
