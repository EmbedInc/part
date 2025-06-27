{   Routines that manipulate BOM (Bill of Materials) data structure.
}
module part_bom;
define part_bom_new;
define part_bom_del;
define part_bom_ent_new;
define part_bom_ent_link_end;
define part_bom_ent_end;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_BOM_NEW (BOM_P, MEM)
*
*   Create a new empty BOM.  BOM_P will be returned pointing to the new BOM data
*   structure.  A new memory context will be created for the BOM.  This memory
*   context will be subordinate to MEM.
}
procedure part_bom_new (               {create new BOM data structure}
  out     bom_p: part_bom_p_t;         {returned pointer to the new BOM}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param;

var
  mem_p: util_mem_context_p_t;         {to memory context for the new BOM}

begin
  util_mem_context_get (mem, mem_p);   {create new private memory context}
  util_mem_context_err_bomb (mem_p);

  util_mem_grab (                      {allocate memory for new BOM descriptor}
    sizeof(bom_p^), mem_p^, false, bom_p);
  util_mem_grab_err_bomb (bom_p, sizeof(bom_p^));

  bom_p^.mem_p := mem_p;               {init BOM descriptor}
  bom_p^.nent := 0;
  bom_p^.first_p := nil;
  bom_p^.last_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine PART_BOM_DEL (BOM_P)
*
*   Delete the BOM pointed to by BOM_P and deallocate all resources associated
*   with it.  BOM_P is returned NIL.  Nothing is done if BOM_P is NIL on entry.
}
procedure part_bom_del (               {delete BOM, deallocate resources}
  in out  bom_p: part_bom_p_t);        {pointer to BOM, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {to BOM's memory context}

begin
  if bom_p = nil then return;          {no BOM to delete ?}

  mem_p := bom_p^.mem_p;               {get pointer to mem context for this BOM}
  if mem_p = nil then begin            {no memory context ?}
    writeln;
    writeln ('INTERNAL ERROR: No memory context on delete BOM in PART_BOM_DEL.');
    sys_bomb;
    end;

  util_mem_context_del (mem_p);        {delete mem context, dealloc all BOM memory}
  bom_p := nil;                        {return pointer to BOM as invalid}
  end;
{
********************************************************************************
*
*   Subroutine PART_BOM_ENT_NEW (BOM, ENT_P)
*
*   Create a new entry for a BOM, but do not link it to the BOM.  ENT_P is
*   is returned pointing to the new BOM entry descriptor.  The new entry will be
*   initialized to blank.
}
procedure part_bom_ent_new (           {create new BOM entry, not added to BOM}
  in out  bom: part_bom_t;             {BOM to create new entry in}
  out     ent_p: part_bom_ent_p_t);    {returned pointing to new BOM entry}
  val_param;

begin
  util_mem_grab (                      {allocate memory for the new entry}
    sizeof(ent_p^), bom.mem_p^, false, ent_p);
  util_mem_grab_err_bomb (ent_p, sizeof(ent_p^));

  ent_p^.next_p := nil;                {initialize the new BOM entry descriptor}
  ent_p^.qty.max := sizeof(ent_p^.qty.str);
  ent_p^.qty.len := 0;
  ent_p^.desig_p := nil;
  ent_p^.desig_is_p := nil;
  ent_p^.desc_p := nil;
  ent_p^.val_p := nil;
  ent_p^.pack_p := nil;
  ent_p^.subst := true;
  ent_p^.inhouse_p := nil;
  ent_p^.manf_p := nil;
  ent_p^.manf_part_p := nil;
  ent_p^.supp_p := nil;
  ent_p^.supp_part_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine PART_BOM_ENT_LINK_END (BOM, ENT_P)
*
*   Link the entry at ENT_P as the last entry of the indicated BOM.
}
procedure part_bom_ent_link_end (      {link entry to end of BOM}
  in out  bom: part_bom_t;             {BOM to link entry to}
  in      ent_p: part_bom_ent_p_t);    {to entry to link to BOM}
  val_param;

begin
  if bom.last_p = nil
    then begin                         {this is first entry in list}
      bom.first_p := ent_p;
      end
    else begin                         {link to end of existing list}
      bom.last_p^.next_p := ent_p;
      end
    ;
  bom.last_p := ent_p;                 {update pointer to last entry}
  ent_p^.next_p := nil;                {make sure new entry indicates end of list}

  bom.nent := bom.nent + 1;            {count one more entry in the BOM}
  end;
{
********************************************************************************
*
*   Subroutine PART_BOM_ENT_END (BOM, ENT_P)
*
*   Add a new blank entry to the end of the indicated BOM.  ENT_P will be
*   returned pointing to the new BOM entry.
}
procedure part_bom_ent_end (           {create new BOM entry, link to end}
  in out  bom: part_bom_t;             {BOM to add entry to}
  out     ent_p: part_bom_ent_p_t);    {to new entry, will be last in BOM}
  val_param;

begin
  part_bom_ent_new (bom, ent_p);       {create the new blank entry}
  part_bom_ent_link_end (bom, ent_p);  {add new entry to end of the BOM}
  end;
