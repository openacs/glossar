# packages/glossar/www/glossar-term-edit.tcl

ad_page_contract {
    
    Editing a Term
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @arch-tag: eb1da800-8bcd-4f10-8ccc-12c31b902614
    @cvs-id $Id$
} {
    glossar_id:notnull
    {source_text ""}
    {target_text ""}
    {dont_text ""}
    {comment ""}
} -properties {
} -validate {
} -errors {
}

set context "[_ glossar.Edit_Term]"
set title $context

# create search clause
set where_clause "WHERE glossar_id = :glossar_id "

if {![empty_string_p $source_text]} {

    append where_clause " AND source_text = :source_text"
    
}

if {![empty_string_p $target_text]} {

    append where_clause " AND target_text = :target_text"
    
}

if {![empty_string_p $dont_text]} {

    append where_clause " AND dont_text = :dont_text"
    
}

db_1row get_term "SELECT source_text , target_text , dont_text , comment FROM gl_glossar_terms $where_clause"

ad_form -name edit-term -from {

    {source_text:text(textarea) {lable "[_ glossar.glossar_source_text]"} {value "$source_text" } {html {rows 4 cols 60}}}
    {target_text:text(textarea) {lable "[_ glossar.glossar_target_text]"} {value "$target_text" } {html {rows 4 cols 60}}}
    {dont_text:text(textarea) {lable "[_ glossar.glossar_dont_text]"} {value "$dont_text" } {html {rows 4 cols 60}}}
    {comment:text(textarea) {lable "[_ glossar.glossar_comment]"} {value "$comment" } {html {rows 4 cols 60}}}

    {glossar_id:text(hidden) {value $glossar_id}}
} -edit_data {


    gl_glossar::term_edit -glossar_id $glossar_id -source_text $source_text -target_text $target_text -dont_text $dont_text -comment $commnet
}
