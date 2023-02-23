{   Public include file for the PART library.  This library handles lists of
*   parts that might appear on a bill of materials.
}
const
  part_subsys_k = -78;                 {PART library subsystem ID}

  part_stat_partref_orgovfl_k = 1;     {too many organizations with private part nums}

type
  part_ref_p_t = ^part_ref_t;
  part_ref_t = record                  {one reference part in list of ref parts}
    prev_p: part_ref_p_t;              {points to previous list entry}
    next_p: part_ref_p_t;              {points to next list entry}
    desc: string_var80_t;              {description string}
    value: string_var80_t;             {value string}
    package: string_var32_t;           {package description string}
    subst_set: boolean;                {SUBST field has been set}
    subst: boolean;                    {substitutions allowed, TRUE when not set}
    inhouse: nameval_list_t;           {list of organizations with their part numbers}
    manuf: nameval_list_t;             {list of manufacturers with their part numbers}
    supplier: nameval_list_t;          {list of suppliers with their part numbers}
    end;

  part_reflist_p_t = ^part_reflist_t;
  part_reflist_t = record              {list of reference part definitions}
    mem_p: util_mem_context_p_t;       {points to dynamic memory context for list}
    first_p: part_ref_p_t;             {points to first list entry}
    last_p: part_ref_p_t;              {points to last list entry}
    nparts: sys_int_machine_t;         {number of entries in the list}
    end;
{
*   Subroutines and functions.
}
procedure part_reflist_del (           {deallocate resources of reference parts list}
  in out  list: part_reflist_t);       {list to deallocate resources of, will be invalid}
  val_param; extern;

procedure part_reflist_init (          {initialize list of reference part definitions}
  out     list: part_reflist_t;        {the list to initialize}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param; extern;

procedure part_reflist_add_end (       {add part to end of reference parts list}
  in out  list: part_reflist_t;        {the list to add the part to}
  in      part_p: part_ref_p_t);       {poiner to the part to add}
  val_param; extern;

procedure part_reflist_new (           {create and initialize new partref list entry}
  in      list: part_reflist_t;        {the list the entry will be part of}
  out     part_p: part_ref_p_t);       {returned pointer to the new entry, not linked}
  val_param; extern;

procedure part_reflist_read_csv (      {add parts from CSV file to partref list}
  in out  list: part_reflist_t;        {the list to add parts to}
  in      csvname: univ string_var_arg_t; {CSV file name, ".csv" suffix may be omitted}
  out     stat: sys_err_t);
  val_param; extern;
