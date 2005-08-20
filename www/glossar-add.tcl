# packages/glossar/www/glossar-add.tcl

ad_page_contract {
    
    Adding a Glossar to a Eta/User
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @arch-tag: 10d0e2ec-fadc-4495-9d10-faa00b8eb5d3
    @cvs-id $Id$
} {
    owner_id:notnull
    glossar_id:optional
    gl_translation_p:notnull
    {customer_id ""}
} -properties {
} -validate {
} -errors {
}

if {$gl_translation_p == 1} {
    if {[exists_and_not_null glossar_id]} {
	set context "translation-edit"
	set page_title "[_ glossar.Edit_Translation]"
    } else {
	set context "translation-add"
	set page_title "[_ glossar.New_Translation]"
    }
} else {
    if {[exists_and_not_null glossar_id]} {
	set context "glossar-edit"
	set page_title "[_ glossar.Edit_Glossar]"
    } else {
	set context "glossar-add"
	set page_title "[_ glossar.Add_new_Glossar]"
    }
}
acs_object::get -object_id $owner_id -array owner
set package_id $owner(package_id)


set source_tree_id [category_tree::get_id "#acs-translations.cat_tree_wieners_from#"]
set target_tree_id [category_tree::get_id "#acs-translations.cat_tree_wieners_to#"]


ad_form -name glossar-add -export {owner_id package_id gl_translation_p customer_id} -form {
    {glossar_id:key}
    {title:text(text) {label "[_ glossar.Title]"}  }
    {description:text(textarea),optional {label "[_ glossar.Comment]"} {html{rows 4 cols 30} }}


} 




if {$gl_translation_p == 1} {

    ad_form -extend -name glossar-add -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_source_category]"} {category_tree_id $source_tree_id}  {assign_single_p t} {require_category_p t} {html {size 4}} }

	{target_category_id:integer(category) {label "[_ glossar.glossar_target_category]"} {category_tree_id   $target_tree_id} {assign_single_p t} {require_category_p f}}

    } 


} else {


    ad_form -extend -name glossar-add -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_single_category]"} {category_tree_id $source_tree_id}  {assign_single_p t} {require_category_p t} {html {size 4}} }

	{target_category_id:text(hidden) {value "[db_null]"}}

    }  

}




ad_form -extend -name glossar-add \
-new_request {
    set source_category_id ""
    set target_category_id ""
    set description ""
    set title ""
} -edit_request {

    db_1row get_glossar {
	SELECT crr.title , crr.description  , gl.source_category_id , gl.target_category_id , gl.owner_id 
	FROM gl_glossars gl, cr_items cr, cr_revisions crr 
	WHERE cr.latest_revision = crr.revision_id 
	AND crr.revision_id = gl.glossar_id 
	AND cr.item_id = :glossar_id
    }


} -new_data {
    
    if {![info exists target_category_id]} {
	set target_category_id [db_null]
    }
    
    gl_glossar::new -owner_id $owner_id -title "$title" -description "$description" -source_category_id $source_category_id -target_category_id $target_category_id -package_id $package_id

} -edit_data {

    gl_glossar::edit -glossar_item_id $glossar_id -title "$title" -description "$description" -source_category_id $source_category_id  -target_category_id $target_category_id -owner_id $owner_id

} -after_submit {
    ad_returnredirect [export_vars -base index {gl_translation_p glossar_id customer_id owner_id}]
    ad_script_abort
}
