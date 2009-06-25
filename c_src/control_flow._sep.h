/* This C header file is generated by NIT to compile modules and programs that requires control_flow. */
#ifndef control_flow_sep
#define control_flow_sep
#include "syntax_base._sep.h"
#include <nit_common.h>

extern const classtable_elt_t VFT_VariableContext[];

extern const classtable_elt_t VFT_RootVariableContext[];

extern const classtable_elt_t VFT_SubVariableContext[];
extern const char *LOCATE_control_flow;
extern const int SFT_control_flow[];
#define ID_VariableContext (SFT_control_flow[0])
#define COLOR_VariableContext (SFT_control_flow[1])
#define ATTR_control_flow___VariableContext____dico(recv) ATTR(recv, (SFT_control_flow[2] + 0))
#define ATTR_control_flow___VariableContext____all_variables(recv) ATTR(recv, (SFT_control_flow[2] + 1))
#define ATTR_control_flow___VariableContext____stypes(recv) ATTR(recv, (SFT_control_flow[2] + 2))
#define ATTR_control_flow___VariableContext____visitor(recv) ATTR(recv, (SFT_control_flow[2] + 3))
#define ATTR_control_flow___VariableContext____node(recv) ATTR(recv, (SFT_control_flow[2] + 4))
#define ATTR_control_flow___VariableContext____unreash(recv) ATTR(recv, (SFT_control_flow[2] + 5))
#define ATTR_control_flow___VariableContext____already_unreash(recv) ATTR(recv, (SFT_control_flow[2] + 6))
#define ATTR_control_flow___VariableContext____set_variables(recv) ATTR(recv, (SFT_control_flow[2] + 7))
#define INIT_TABLE_POS_VariableContext (SFT_control_flow[3] + 0)
#define CALL_control_flow___VariableContext_____bra(recv) ((control_flow___VariableContext_____bra_t)CALL((recv), (SFT_control_flow[3] + 1)))
#define CALL_control_flow___VariableContext___add(recv) ((control_flow___VariableContext___add_t)CALL((recv), (SFT_control_flow[3] + 2)))
#define CALL_control_flow___VariableContext___mark_is_set(recv) ((control_flow___VariableContext___mark_is_set_t)CALL((recv), (SFT_control_flow[3] + 3)))
#define CALL_control_flow___VariableContext___check_is_set(recv) ((control_flow___VariableContext___check_is_set_t)CALL((recv), (SFT_control_flow[3] + 4)))
#define CALL_control_flow___VariableContext___stype(recv) ((control_flow___VariableContext___stype_t)CALL((recv), (SFT_control_flow[3] + 5)))
#define CALL_control_flow___VariableContext___stype__eq(recv) ((control_flow___VariableContext___stype__eq_t)CALL((recv), (SFT_control_flow[3] + 6)))
#define CALL_control_flow___VariableContext___sub(recv) ((control_flow___VariableContext___sub_t)CALL((recv), (SFT_control_flow[3] + 7)))
#define CALL_control_flow___VariableContext___sub_with(recv) ((control_flow___VariableContext___sub_with_t)CALL((recv), (SFT_control_flow[3] + 8)))
#define CALL_control_flow___VariableContext___node(recv) ((control_flow___VariableContext___node_t)CALL((recv), (SFT_control_flow[3] + 9)))
#define CALL_control_flow___VariableContext___init(recv) ((control_flow___VariableContext___init_t)CALL((recv), (SFT_control_flow[3] + 10)))
#define CALL_control_flow___VariableContext___unreash(recv) ((control_flow___VariableContext___unreash_t)CALL((recv), (SFT_control_flow[3] + 11)))
#define CALL_control_flow___VariableContext___unreash__eq(recv) ((control_flow___VariableContext___unreash__eq_t)CALL((recv), (SFT_control_flow[3] + 12)))
#define CALL_control_flow___VariableContext___already_unreash(recv) ((control_flow___VariableContext___already_unreash_t)CALL((recv), (SFT_control_flow[3] + 13)))
#define CALL_control_flow___VariableContext___already_unreash__eq(recv) ((control_flow___VariableContext___already_unreash__eq_t)CALL((recv), (SFT_control_flow[3] + 14)))
#define CALL_control_flow___VariableContext___set_variables(recv) ((control_flow___VariableContext___set_variables_t)CALL((recv), (SFT_control_flow[3] + 15)))
#define CALL_control_flow___VariableContext___is_set(recv) ((control_flow___VariableContext___is_set_t)CALL((recv), (SFT_control_flow[3] + 16)))
#define CALL_control_flow___VariableContext___merge(recv) ((control_flow___VariableContext___merge_t)CALL((recv), (SFT_control_flow[3] + 17)))
#define CALL_control_flow___VariableContext___merge2(recv) ((control_flow___VariableContext___merge2_t)CALL((recv), (SFT_control_flow[3] + 18)))
#define ID_RootVariableContext (SFT_control_flow[4])
#define COLOR_RootVariableContext (SFT_control_flow[5])
#define INIT_TABLE_POS_RootVariableContext (SFT_control_flow[6] + 0)
#define CALL_control_flow___RootVariableContext___init(recv) ((control_flow___RootVariableContext___init_t)CALL((recv), (SFT_control_flow[6] + 1)))
#define ID_SubVariableContext (SFT_control_flow[7])
#define COLOR_SubVariableContext (SFT_control_flow[8])
#define ATTR_control_flow___SubVariableContext____prev(recv) ATTR(recv, (SFT_control_flow[9] + 0))
#define INIT_TABLE_POS_SubVariableContext (SFT_control_flow[10] + 0)
#define CALL_control_flow___SubVariableContext___prev(recv) ((control_flow___SubVariableContext___prev_t)CALL((recv), (SFT_control_flow[10] + 1)))
#define CALL_control_flow___SubVariableContext___with_prev(recv) ((control_flow___SubVariableContext___with_prev_t)CALL((recv), (SFT_control_flow[10] + 2)))
#define CALL_control_flow___Variable___must_be_set(recv) ((control_flow___Variable___must_be_set_t)CALL((recv), (SFT_control_flow[11] + 0)))
typedef val_t (* control_flow___VariableContext___to_s_t)(val_t  self);
val_t control_flow___VariableContext___to_s(val_t  self);
#define LOCATE_control_flow___VariableContext___to_s "control_flow::VariableContext::(string::Object::to_s)"
typedef val_t (* control_flow___VariableContext_____bra_t)(val_t  self, val_t  param0);
val_t control_flow___VariableContext_____bra(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext_____bra "control_flow::VariableContext::[]"
typedef void (* control_flow___VariableContext___add_t)(val_t  self, val_t  param0);
void control_flow___VariableContext___add(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___add "control_flow::VariableContext::add"
typedef void (* control_flow___VariableContext___mark_is_set_t)(val_t  self, val_t  param0);
void control_flow___VariableContext___mark_is_set(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___mark_is_set "control_flow::VariableContext::mark_is_set"
typedef void (* control_flow___VariableContext___check_is_set_t)(val_t  self, val_t  param0, val_t  param1);
void control_flow___VariableContext___check_is_set(val_t  self, val_t  param0, val_t  param1);
#define LOCATE_control_flow___VariableContext___check_is_set "control_flow::VariableContext::check_is_set"
typedef val_t (* control_flow___VariableContext___stype_t)(val_t  self, val_t  param0);
val_t control_flow___VariableContext___stype(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___stype "control_flow::VariableContext::stype"
typedef void (* control_flow___VariableContext___stype__eq_t)(val_t  self, val_t  param0, val_t  param1);
void control_flow___VariableContext___stype__eq(val_t  self, val_t  param0, val_t  param1);
#define LOCATE_control_flow___VariableContext___stype__eq "control_flow::VariableContext::stype="
typedef val_t (* control_flow___VariableContext___sub_t)(val_t  self, val_t  param0);
val_t control_flow___VariableContext___sub(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___sub "control_flow::VariableContext::sub"
typedef val_t (* control_flow___VariableContext___sub_with_t)(val_t  self, val_t  param0, val_t  param1, val_t  param2);
val_t control_flow___VariableContext___sub_with(val_t  self, val_t  param0, val_t  param1, val_t  param2);
#define LOCATE_control_flow___VariableContext___sub_with "control_flow::VariableContext::sub_with"
typedef val_t (* control_flow___VariableContext___node_t)(val_t  self);
val_t control_flow___VariableContext___node(val_t  self);
#define LOCATE_control_flow___VariableContext___node "control_flow::VariableContext::node"
typedef void (* control_flow___VariableContext___init_t)(val_t  self, val_t  param0, val_t  param1, int* init_table);
void control_flow___VariableContext___init(val_t  self, val_t  param0, val_t  param1, int* init_table);
#define LOCATE_control_flow___VariableContext___init "control_flow::VariableContext::init"
val_t NEW_VariableContext_control_flow___VariableContext___init(val_t p0, val_t p1);
typedef val_t (* control_flow___VariableContext___unreash_t)(val_t  self);
val_t control_flow___VariableContext___unreash(val_t  self);
#define LOCATE_control_flow___VariableContext___unreash "control_flow::VariableContext::unreash"
typedef void (* control_flow___VariableContext___unreash__eq_t)(val_t  self, val_t  param0);
void control_flow___VariableContext___unreash__eq(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___unreash__eq "control_flow::VariableContext::unreash="
typedef val_t (* control_flow___VariableContext___already_unreash_t)(val_t  self);
val_t control_flow___VariableContext___already_unreash(val_t  self);
#define LOCATE_control_flow___VariableContext___already_unreash "control_flow::VariableContext::already_unreash"
typedef void (* control_flow___VariableContext___already_unreash__eq_t)(val_t  self, val_t  param0);
void control_flow___VariableContext___already_unreash__eq(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___already_unreash__eq "control_flow::VariableContext::already_unreash="
typedef val_t (* control_flow___VariableContext___set_variables_t)(val_t  self);
val_t control_flow___VariableContext___set_variables(val_t  self);
#define LOCATE_control_flow___VariableContext___set_variables "control_flow::VariableContext::set_variables"
typedef val_t (* control_flow___VariableContext___is_set_t)(val_t  self, val_t  param0);
val_t control_flow___VariableContext___is_set(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___is_set "control_flow::VariableContext::is_set"
typedef void (* control_flow___VariableContext___merge_t)(val_t  self, val_t  param0);
void control_flow___VariableContext___merge(val_t  self, val_t  param0);
#define LOCATE_control_flow___VariableContext___merge "control_flow::VariableContext::merge"
typedef void (* control_flow___VariableContext___merge2_t)(val_t  self, val_t  param0, val_t  param1, val_t  param2);
void control_flow___VariableContext___merge2(val_t  self, val_t  param0, val_t  param1, val_t  param2);
#define LOCATE_control_flow___VariableContext___merge2 "control_flow::VariableContext::merge2"
typedef void (* control_flow___RootVariableContext___init_t)(val_t  self, val_t  param0, val_t  param1, int* init_table);
void control_flow___RootVariableContext___init(val_t  self, val_t  param0, val_t  param1, int* init_table);
#define LOCATE_control_flow___RootVariableContext___init "control_flow::RootVariableContext::init"
val_t NEW_RootVariableContext_control_flow___RootVariableContext___init(val_t p0, val_t p1);
typedef val_t (* control_flow___SubVariableContext_____bra_t)(val_t  self, val_t  param0);
val_t control_flow___SubVariableContext_____bra(val_t  self, val_t  param0);
#define LOCATE_control_flow___SubVariableContext_____bra "control_flow::SubVariableContext::(control_flow::VariableContext::[])"
typedef val_t (* control_flow___SubVariableContext___stype_t)(val_t  self, val_t  param0);
val_t control_flow___SubVariableContext___stype(val_t  self, val_t  param0);
#define LOCATE_control_flow___SubVariableContext___stype "control_flow::SubVariableContext::(control_flow::VariableContext::stype)"
typedef val_t (* control_flow___SubVariableContext___is_set_t)(val_t  self, val_t  param0);
val_t control_flow___SubVariableContext___is_set(val_t  self, val_t  param0);
#define LOCATE_control_flow___SubVariableContext___is_set "control_flow::SubVariableContext::(control_flow::VariableContext::is_set)"
typedef val_t (* control_flow___SubVariableContext___prev_t)(val_t  self);
val_t control_flow___SubVariableContext___prev(val_t  self);
#define LOCATE_control_flow___SubVariableContext___prev "control_flow::SubVariableContext::prev"
typedef void (* control_flow___SubVariableContext___with_prev_t)(val_t  self, val_t  param0, val_t  param1, int* init_table);
void control_flow___SubVariableContext___with_prev(val_t  self, val_t  param0, val_t  param1, int* init_table);
#define LOCATE_control_flow___SubVariableContext___with_prev "control_flow::SubVariableContext::with_prev"
val_t NEW_SubVariableContext_control_flow___SubVariableContext___with_prev(val_t p0, val_t p1);
val_t NEW_Variable_syntax_base___Variable___init(val_t p0, val_t p1);
typedef val_t (* control_flow___Variable___must_be_set_t)(val_t  self);
val_t control_flow___Variable___must_be_set(val_t  self);
#define LOCATE_control_flow___Variable___must_be_set "control_flow::Variable::must_be_set"
val_t NEW_VarVariable_syntax_base___VarVariable___init(val_t p0, val_t p1);
typedef val_t (* control_flow___VarVariable___must_be_set_t)(val_t  self);
val_t control_flow___VarVariable___must_be_set(val_t  self);
#define LOCATE_control_flow___VarVariable___must_be_set "control_flow::VarVariable::(control_flow::Variable::must_be_set)"
#endif
