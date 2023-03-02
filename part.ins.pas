{   Public include file for the PART library.  This library handles lists of
*   parts that might appear on a bill of materials.
}
const
  part_subsys_k = -78;                 {PART library subsystem ID}

  part_stat_partref_orgovfl_k = 1;     {too many organizations with private part nums}

type
  part_list_p_t = ^part_list_t;

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

  part_flag_k_t = (                    {flags for individial parts}
    part_flag_comm_k,                  {common part, not first in common part chain}
    part_flag_nobom_k,                 {do not add this part to the BOM}
    part_flag_subst_k,                 {OK to substitute part with equivalent}
    part_flag_isafe_k);                {critical to Intrinsic Safety}
  part_flags_t = set of part_flag_k_t;

  part_p_t = ^part_t;
  part_t = record                      {info about one part from input file}
    list_p: part_list_p_t;             {to list this part is within}
    next_p: part_p_t;                  {pointer to next input file part}
    line: sys_int_machine_t;           {input file source line number}
    qtyuse: real;                      {quantity per individual usage, usually 1}
    desig: string_var16_t;             {component designator, upper case}
    lib: string_var80_t;               {Eagle library name, upper case}
    dev: string_var80_t;               {device name within Eagle lib, original case}
    devu: string_var80_t;              {device name within Eagle lib, upper case}
    desc: string_var132_t;             {part description string}
    val: string_var80_t;               {value for BOM, from VALUE or DVAL if present}
    pack: string_var32_t;              {package name within Eagle lib, upper case}
    manuf: string_var132_t;            {manufacturer name}
    mpart: string_var132_t;            {manufacturer part number}
    supp: string_var132_t;             {supplier name}
    spart: string_var132_t;            {supplier part number}
    housenum: string_var132_t;         {in-house part number}
    flags: part_flags_t;               {set of flags for this part}
    same_p: part_p_t;                  {pnt to next same part}
    qty: real;                         {total same parts of this type, valid at first}
    end;

  part_list_t = record                 {list of parts, like in a BOM}
    mem_p: util_mem_context_p_t;       {points to dynamic memory context for list}
    first_p: part_p_t;                 {points to first list entry}
    last_p: part_p_t;                  {points to last list entry}
    housename: string_var80_t;         {name of org owning in-house part numbers}
    nparts: sys_int_machine_t;         {number of entries in the list}
    nunique: sys_int_machine_t;        {number of unique physical parts in list}
    end;
{
*   Subroutines and functions.
}
procedure part_comm_find (             {find and mark common parts in list}
  in out  list: part_list_t);          {list of part, SAME_P and COMM flags set}
  val_param; extern;

procedure part_def (                   {default empty fields from others as possible}
  in out  part: part_t);               {part to apply defaults to}
  val_param; extern;

procedure part_def_list (              {default empty fields from others as possible}
  in out  list: part_list_t);          {list of parts to apply defaults to}
  val_param; extern;

procedure part_housename_get (         {get name of org that owns private part numbers}
  in      dir: univ string_var_arg_t;  {directory to find housename that applies to it}
  in out  housename: univ string_var_arg_t; {returned organization name, empty if none}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure part_list_del (              {delete parts list, deallocate resources}
  in out  list_p: part_list_p_t);      {pointer to list to delete, returned NIL}
  val_param; extern;

procedure part_list_ent_add_end (      {add part to end of parts list}
  in out  list: part_list_t;           {the list to add the part to}
  in      part_p: part_p_t);           {pointer to the part to add}
  val_param; extern;

procedure part_list_ent_new (          {create and initialize new parts list entry}
  in out  list: part_list_t;           {the list the entry will be part of}
  out     part_p: part_p_t);           {returned pointer to the new entry, not linked}
  val_param; extern;

procedure part_list_ent_new_end (      {create and init new part, add to end of list}
  in out  list: part_list_t;           {the list the part will be added to}
  out     part_p: part_p_t);           {returned pointer to the new part}
  val_param; extern;

procedure part_list_new (              {create new empty list of parts}
  out     list_p: part_list_p_t;       {returned pointer to the new list}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param; extern;

procedure part_ref_apply (             {apply reference parts into to parts list}
  in out  list: part_list_t;           {parts to update to with reference info}
  in      ref: part_reflist_t);        {list of refrence parts}
  val_param; extern;

procedure part_reflist_del (           {delete reference parts list, deallocate resources}
  in out  list_p: part_reflist_p_t);   {pointer to list to delete, returned NIL}
  val_param; extern;

procedure part_reflist_ent_add_end (   {add part to end of reference parts list}
  in out  list: part_reflist_t;        {the list to add the part to}
  in      part_p: part_ref_p_t);       {pointer to the part to add}
  val_param; extern;

procedure part_reflist_ent_new (       {create and init new reference parts list entry}
  in out  list: part_reflist_t;        {the list the entry will be part of}
  out     part_p: part_ref_p_t);       {returned pointer to the new entry, not linked}
  val_param; extern;

procedure part_reflist_ent_new_end (   {add new initialized entry to end of ref parts list}
  in out  list: part_reflist_t;        {the list the entry will be part of}
  out     part_p: part_ref_p_t);       {returned pointer to the new entry, not linked}
  val_param; extern;

procedure part_reflist_new (           {create new empty list of reference parts}
  out     list_p: part_reflist_p_t;    {returned pointer to the new list}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param; extern;

procedure part_reflist_read_csv (      {add parts from CSV file to partref list}
  in out  list: part_reflist_t;        {the list to add parts to}
  in      csvname: univ string_var_arg_t; {CSV file name, ".csv" suffix may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;
