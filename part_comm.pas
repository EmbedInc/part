{   Routines related to common parts.
}
module part_comm;
define part_comm_find;
%include 'part2.ins.pas';
{
********************************************************************************
*
*   Subroutine PART_COMM_FIND (LIST)
*
*   Identify parts in the list LIST that are instances of the same physical
*   part.  A chain of parts will be created for each unique physical part.  Only
*   parts flagged to be included in a BOM will be examined.
*
*   The first instance in the list of a common part will have its COMM flag
*   cleared, and its QTY field set to the total quantity of the common part in
*   the chain.  The SAME_P will be set pointing to the next list entry for this
*   common part, if any.
*
*   Subsequent list entries of a common part will have their COMM flags set.
*   SAME_P will point to the next common part in the chain, except that SAME_P
*   of the last part in the chain will be NIL.
*
*   LIST.NUNIQUE is set to the number of different physical parts found that are
*   on the BOM.
*
*   The result of any previous attempt to find common parts is completely
*   overwritten.  The previous common parts state is irrelevant.
}
procedure part_comm_find (             {find and mark common parts in list}
  in out  list: part_list_t);          {list of part, SAME_P and COMM flags set}
  val_param;

var
  part_p: part_p_t;                    {to first instance of comm part being examined}
  p2_p: part_p_t;                      {to subsequent common part candidate}
  last_p: part_p_t;                    {last entry in common parts chain}

label
  commch_same, next_commch, next_comp;

begin
  list.nunique := 0;                   {init number of unique parts found}

  part_p := list.first_p;              {reset all common parts state}
  while part_p <> nil do begin
    part_p^.flags := part_p^.flags - [part_flag_comm_k]; {not subsequent common part}
    part_p^.same_p := nil;             {init to no subsequent common parts}
    part_p := part_p^.next_p;          {to next part in list}
    end;

  part_p := list.first_p;              {init current component to first in list}
  while part_p <> nil do begin         {scan thru the entire list of components}
    if part_flag_nobom_k in part_p^.flags {this component not for the BOM ?}
      then goto next_comp;
    if part_flag_comm_k in part_p^.flags {already found common with a previous part ?}
      then goto next_comp;
    last_p := part_p;                  {init end of comm parts chain for this part}
    list.nunique := list.nunique + 1;  {count one more unique part found}

    p2_p := part_p^.next_p;            {init pointer to second part to check for common}
    while p2_p <> nil do begin         {scan remaining components looking for commons}
      if part_flag_comm_k in p2_p^.flags {already common to another part ?}
        then goto next_commch;
      if not string_equal (p2_p^.housenum, part_p^.housenum) {different in-house number ?}
        then goto next_commch;
      if part_p^.housenum.len > 0      {same in-house part number ?}
        then goto commch_same;
      if not string_equal (p2_p^.lib, part_p^.lib) {in different library ?}
        then goto next_commch;
      if not string_equal (p2_p^.devu, part_p^.devu) {different library device name ?}
        then goto next_commch;
      if not string_equal (p2_p^.val, part_p^.val) {different part value ?}
        then goto next_commch;
      if not string_equal (p2_p^.pack, part_p^.pack) {different package ?}
        then goto next_commch;
      {
      *   The component at P2_P is the same physical part as at PART_P.
      }
commch_same:                           {found common part}
      last_p^.same_p := p2_p;          {link this component to end of common parts chain}
      last_p := p2_p;                  {update pointer to end of common parts chain}
      p2_p^.flags := p2_p^.flags + [part_flag_comm_k]; {this comp is in common parts chain}
      part_p^.qty := part_p^.qty + p2_p^.qtyuse; {update total quantity}
next_commch:                           {to next candidate common part}
      p2_p := p2_p^.next_p;
      end;                             {back to check new component same as curr comp}

next_comp:                             {done with current starting entry, on to next}
    part_p := part_p^.next_p;          {advance to next component in this list}
    end;                               {back to process this new component}
  end;
