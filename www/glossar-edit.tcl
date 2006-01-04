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


db_1row get_glossar {}

set from_object_id [db_string get_from_default_object { }]
set to_object_id [db_string get_to_default_object { }]

# We get the mapped category tree's to show in the form
set source_tree_id [lindex [lindex [category_tree::get_mapped_trees $from_object_id] 0] 0]
set target_tree_id [lindex [lindex [category_tree::get_mapped_trees $to_object_id] 0] 0]

ad_form -name glossar-edit -form {

    {glossar_id:key}
    {title:text(text) {label "[_ glossar.Title]"}  }
    {description:text(textarea),optional {label "[_ glossar.Comment]"} {html{rows 4 cols 30} }}
}

if {![empty_string_p $target_category_id]} {
    ad_form -extend -name glossar-edit -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_source_category]"} {category_tree_id $source_tree_id}  {category_assign_single_p t} {category_require_category_p t}}

	{target_category_id:integer(category) {label "[_ glossar.glossar_target_category]"} {category_tree_id   $target_tree_id} {category_assign_single_p t} {category_require_category_p t}}

    } 


} else {
    ad_form -extend -name glossar-edit -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_single_category]"} {category_tree_id $source_tree_id} {category_assign_single_p t} {category_require_category_p t}}

	{target_category_id:text(hidden) {value "[db_null]"}}

    }  

}

    
set group_id [group::get_id -group_name "Etat"]
set is_etat_p [db_string check_if_is_etat {} -default 0]

set options [db_list_of_lists get_etats {}]
set options [concat [list [list "" ""]] $options]

if {[llength $options] > 1} {
    ad_form -extend -name glossar-edit -form {
	{target_id:integer(select),optional {label "[_ glossar.glossar_etat]"} {options $options}}
    }
} else {
    ad_form -extend -name glossar-edit -form {
	{target_id:text(hidden) {value ""}}
    }
}

ad_form -extend -name glossar-edit -form {
    {owner_id:text(hidden)}
} -edit_request {
}  -edit_data {

    set old_owner_id $owner_id
    if {![empty_string_p $target_id]} {
	db_1row get_rel_id {}
    }

    gl_glossar::edit -glossar_item_id $glossar_id -title $title -description $comment -source_category_id $source_category_id  -target_category_id $target_category_id -owner_id $owner_id -etat_id ""

} -after_submit {
    ad_returnredirect "/contacts/$old_owner_id"
    ad_script_abort
}
