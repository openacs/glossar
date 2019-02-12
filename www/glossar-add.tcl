ad_page_contract {
    
    Adding a Glossar to a Eta/User
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @cvs-id $Id$
} {
    owner_id:notnull
    glossar_id:optional
    gl_translation_p:notnull
    {target_id ""}
} -properties {
} -validate {
} -errors {
}

if {$gl_translation_p == 1} {
    if {[exists_and_not_null glossar_id]} {
	set page_title "[_ glossar.Edit_Translation]"
    } else {
	set page_title "[_ glossar.New_Translation]"
    }
} else {
    if {[exists_and_not_null glossar_id]} {
	set page_title "[_ glossar.Edit_Glossar]"
    } else {
	set page_title "[_ glossar.Add_new_Glossar]"
    }
}

set context [list [list "/contacts/$owner_id" [contact::name -party_id $owner_id]] $page_title]
acs_object::get -object_id $owner_id -array owner
set package_id $owner(package_id)

set from_object_id [db_string get_from_default_object { }]
set to_object_id [db_string get_to_default_object { }]

# We get the mapped category tree's to show in the form
set source_tree_id [lindex [lindex [category_tree::get_mapped_trees $from_object_id] 0] 0]
set target_tree_id [lindex [lindex [category_tree::get_mapped_trees $to_object_id] 0] 0]


ad_form -name glossar-add -export {owner_id package_id gl_translation_p customer_id} -form {
    {glossar_id:key}
    {title:text(text) {label "[_ glossar.Title]"}  }
    {description:text(textarea),optional {label "[_ glossar.Comment]"} {html {rows 6 cols 80} }}
} 


if {$gl_translation_p == 1} {
    ad_form -extend -name glossar-add -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_source_category]"} {category_tree_id $source_tree_id}  {category_assign_single_p t} {category_require_category_p t}}

	{target_category_id:integer(category) {label "[_ glossar.glossar_target_category]"} {category_tree_id   $target_tree_id} {category_assign_single_p t} {category_require_category_p t}}

    } 


} else {
    ad_form -extend -name glossar-add -form {
    
	{source_category_id:integer(category) {label "[_ glossar.glossar_single_category]"} {category_tree_id $source_tree_id}  {category_assign_single_p t} {category_require_category_p t}}

	{target_category_id:text(hidden) {value ""}}

    }  

}

set group_id [group::get_id -group_name "Etat"]
set is_etat_p [db_string check_if_is_etat {} -default 0]

set options [db_list_of_lists get_etats {}]
set options [concat [list [list "" ""]] $options]

if {[llength $options] > 1} {
    ad_form -extend -name glossar-add -form {
	{target_id:integer(select),optional {label "[_ glossar.glossar_etat]"} {options $options}}
    }
} else {
    ad_form -extend -name glossar-add -form {
	{target_id:text(hidden) {value ""}}
    }
}




ad_form -extend -name glossar-add \
-new_request {
    set source_category_id ""
    set target_category_id ""
    set description ""
    set title ""
} -edit_request {

    db_1row get_glossar { }

} -on_submit {

    set old_owner_id $owner_id
    if {![empty_string_p $target_id]} {
	db_1row get_rel_id {}
    }

} -new_data {
    
    if {![info exists target_category_id]} {
	set target_category_id ""
    }
    
    glossar::glossary::new -owner_id $owner_id -title "$title" -description "$description" -source_category_id $source_category_id -target_category_id $target_category_id -package_id $package_id -etat_id ""

} -edit_data {

    glossar::glossary::edit -glossar_item_id $glossar_id -title "$title" -description "$description" -source_category_id $source_category_id  -target_category_id $target_category_id -owner_id $owner_id -etat_id ""

} -after_submit {
    ad_returnredirect "/contacts/$old_owner_id"
    ad_script_abort
}
