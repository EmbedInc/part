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

  part_list_t = record                 {list of parts}
    mem_p: util_mem_context_p_t;       {points to dynamic memory context for list}
    first_p: part_p_t;                 {points to first list entry}
    last_p: part_p_t;                  {points to last list entry}
    board: string_var32_t;             {board name, if known}
    housename: string_var80_t;         {name of org owning in-house part numbers}
    reflist_p: part_reflist_p_t;       {to list of reference parts, if any}
    nparts: sys_int_machine_t;         {number of entries in the list}
    nunique: sys_int_machine_t;        {number of unique physical parts in list}
    tnam: string_treename_t;           {full treename of source file, if any}
    end;

  part_bom_ent_p_t = ^part_bom_ent_t;
  part_bom_ent_t = record              {one BOM entry}
    next_p: part_bom_ent_p_t;          {to next BOM entry}
    qty: string_var32_t;               {quantity, integer when possible}
    desig_p: string_var_p_t;           {to list of designators}
    desig_is_p: string_var_p_t;        {to desig list, "*" for critical to Intrinsic Safety}
    desc_p: string_var_p_t;            {to part general description}
    val_p: string_var_p_t;             {to specific part value string}
    pack_p: string_var_p_t;            {to package name string}
    subst: boolean;                    {substitution allowed}
    inhouse_p: string_var_p_t;         {to in-house part number or designation}
    manf_p: string_var_p_t;            {to manufacturer name}
    manf_part_p: string_var_p_t;       {to manufacturer part number}
    supp_p: string_var_p_t;            {to supplier name}
    supp_part_p: string_var_p_t;       {to supplier part number}
    end;

  part_bom_p_t = ^part_bom_t;
  part_bom_t = record                  {bill of materials}
    mem_p: util_mem_context_p_t;       {to memory context for this BOM}
    nent: sys_int_machine_t;           {number of entries in the BOM}
    first_p: part_bom_ent_p_t;         {to first BOM entry}
    last_p: part_bom_ent_p_t;          {to last BOM entry}
    end;
{
*   Subroutines and functions.
}
procedure part_bom_csv (               {write BOM CSV file, for reading by programs}
  in      list: part_list_t;           {list of parts to write BOM for}
  in      fnam: univ string_var_arg_t; {name of output file, ".csv" may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure part_bom_del (               {delete BOM, deallocate resources}
  in out  bom_p: part_bom_p_t);        {pointer to BOM, returned NIL}
  val_param; extern;

procedure part_bom_ent_end (           {create new BOM entry, link to end}
  in out  bom: part_bom_t;             {BOM to add entry to}
  out     ent_p: part_bom_ent_p_t);    {to new entry, will be last in BOM}
  val_param; extern;

procedure part_bom_ent_link_end (      {link entry to end of BOM}
  in out  bom: part_bom_t;             {BOM to link entry to}
  in      ent_p: part_bom_ent_p_t);    {to entry to link to BOM}
  val_param; extern;

procedure part_bom_ent_new (           {create new BOM entry, not added to BOM}
  in out  bom: part_bom_t;             {BOM to create new entry in}
  out     ent_p: part_bom_ent_p_t);    {returned pointing to new BOM entry}
  val_param; extern;

procedure part_bom_list_add (          {add BOM entries from parts list}
  in out  bom: part_bom_t;             {BOM to add entries to}
  in      list: part_list_t);          {list to create new BOM entries from}
  val_param; extern;

procedure part_bom_list_make (         {create BOM from parts list}
  in      list: part_list_t;           {list of parts to create BOM from}
  out     bom_p: part_bom_p_t);        {returned pointer to new BOM}
  val_param; extern;

procedure part_bom_new (               {create new BOM data structure}
  out     bom_p: part_bom_p_t;         {returned pointer to the new BOM}
  in out  mem: util_mem_context_t);    {parent memory context, will create subordinate}
  val_param; extern;

procedure part_bom_template (          {copy BOM template spreadsheet into dir}
  in      dir: univ string_var_arg_t;  {directory to copy template spreadsheet into}
  in      gnam: univ string_var_arg_t; {generic board name}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure part_bom_tsv (               {write BOM for spreadsheet, with equations}
  in      list: part_list_t;           {list of parts to write BOM for}
  in      fnam: univ string_var_arg_t; {name of output file, ".tsv" may be omitted}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

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

procedure part_ref_apply (             {apply reference parts to parts list}
  in out  list: part_list_t;           {parts to update to with reference info}
  in var  ref: part_reflist_t);        {list of refrence parts}
  val_param; extern;

procedure part_ref_write (             {write parts list in reference list CSV format}
  in      list: part_list_t;           {list of parts to write}
  in      fnam: univ string_var_arg_t; {name of output file, ".csv" may be omitted}
  out     stat: sys_err_t);            {completion status}
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
