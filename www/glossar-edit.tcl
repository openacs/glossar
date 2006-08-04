# packages/glossar/www/glossar-edit.tcl

ad_page_contract {
    
    Change a Glossar
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @arch-tag: 5ca20456-b64a-46c0-8adf-f03a8b28a081
    @cvs-id $Id$
} {
    glossar_id:notnull
    contact_id:notnull

} -properties {
}


set from_object_id [db_string get_from_default_object { }]
set to_object_id [db_string get_to_default_object { }]

# We get the mapped category tree's to show in the form
set source_tree_id [lindex [lindex [category_tree::get_mapped_trees $from_object_id] 0] 0]
set target_tree_id [lindex [lindex [category_tree::get_mapped_trees $to_object_id] 0] 0]

set page_title "[_ glossar.Change_Glossar]"
set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] $page_title]

db_1row check_translation_p {}

ad_form -name glossar-edit -export {contact_id} -form {

    {glossar_id:key}
    {title:text(text) {label "[_ glossar.Title]"}  }
    {description:text(textarea),optional {label "[_ glossar.Comment]"} {html {rows 6 cols 80} }}
}

if {$translation_p == "t"} {
    ad_form -extend -name glossar-edit -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_source_category]"} {category_tree_id $source_tree_id}  {category_assign_single_p t} {category_require_category_p t} {category_mapped $source_cat_id}}

	{target_category_id:integer(category) {label "[_ glossar.glossar_target_category]"} {category_tree_id $target_tree_id} {category_assign_single_p t} {category_require_category_p t} {category_mapped $target_cat_id}}

    } 

} else {
    ad_form -extend -name glossar-edit -form {

	{source_category_id:integer(category) {label "[_ glossar.glossar_single_category]"} {category_tree_id $source_tree_id} {category_assign_single_p t} {category_require_category_p t} {category_mapped $source_cat_id}}

	{target_category_id:text(hidden) {value "[db_null]"}}
    }  
}


db_0or1row check_rel_owner {}

set group_id [group::get_id -group_name "Etat"]
if {[db_string check_if_is_etat {} -default 0]} {
    set target_label "[_ glossar.glossar_organization]"
} else {
    set target_label "[_ glossar.glossar_etat]"
}

set options [db_list_of_lists get_etats {}]
set options [concat [list [list "" ""]] $options]

if {[llength $options] > 1} {
    ad_form -extend -name glossar-edit -form {
	{target_id:integer(select),optional {label $target_label} {options $options}}
    }
} else {
    ad_form -extend -name glossar-edit -form {
	{target_id:text(hidden) {value ""}}
    }
}

ad_form -extend -name glossar-edit -form {
    {owner_id:text(hidden)}
} -edit_request {
    db_1row get_glossar {}

    set organization_p [organization::organization_p -party_id $owner_id]
    if {!$organization_p} {
	db_1row get_rel_id {}
    }
    if {[exists_and_not_null rel_target_id]} {
	set target_id $rel_target_id
    }

}  -edit_data {

    set old_owner_id $owner_id

    if {![empty_string_p $target_id]} {
	db_1row get_rel_id2 {}
    }

    glossar::glossary::edit -glossar_item_id $glossar_id -title $title -description $description -source_category_id $source_category_id  -target_category_id $target_category_id -owner_id $owner_id -etat_id ""


} -after_submit {
    ad_returnredirect "/contacts/$contact_id"
    ad_script_abort
}
