# packages/glossar/www/glossar-edit.tcl

ad_page_contract {
    
    Change a Glossar
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @arch-tag: 5ca20456-b64a-46c0-8adf-f03a8b28a081
    @cvs-id $Id$
} {
    glossar_id:notnull

} -properties {
   
} -validate {
} -errors {
}


db_1row get_glossar "SELECT title as old_title, comment as old_comment , source_category_id , target_category_id , owner_id FROM gl_glossars WHERE glossar_id = :glossar_id" 





ad_form -name glossar-edit -form {

    {title:text(text) {lable "[_ glossar.glossar_title]"} {value "$old_title"} }
    {comment:text(textarea),optional {lable "[_ glossar.glossar_comment]"} {value "$old_comment"} {html{rows 4 cols 30} }}
    {glossar_id:integer(hidden) {value $glossar_id}}
    
    {source_category_id:text(hidden) {value "$source_category_id"}}
    {target_category_id:text(hidden) {value "$target_category_id"}}
    {owner_id:key}

}  -edit_data {

    gl_glossar::edit -glossar_id $glossar_id -title "$title" -comment "$comment" -source_category_id $source_category_id  -target_category_id $target_category_id -owner_id $owner_id
} -edit_request {}






