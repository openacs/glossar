# packages/glossar/lib/glossar-portlet-list.tcl
#
# Creates a list of all glossars that belong to this Customer, direct and indirect (Etat)
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-29
# @arch-tag: 4324b14c-cb5d-4512-b56d-0e0ab10ff025
# @cvs-id $Id$

foreach required_param {owner_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {gl_format gl_orderby} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}


set base_url [dotlrn_community::get_community_url \
		  [dotlrn_community::get_community_id_from_url] \
		 ]

set page_size 100
set base_url "glossar"
set user_id [ad_conn user_id]
set contact_id $owner_id

if {[empty_string_p $user_id]} {
    ad_redirect_for_registration
}

if {[goup::member_p -user_id $user_id -group_name Customer]} {
    # owner is customer
    set customer_id $owner_id
    set query_name gl_glossar_portlet_customer
} else {
    # owner is etat
    set etat_id $owner_id
    set query_name gl_glossar_portlet_etat
}

# We check if the owner_id is a relation, if it is, the real_owner_id
# becomes the eta_id stored in gl_glossars, else it becomes the
# owner_id which can be a customer_id or a etat_id.
# We still pass on the owner_id to check permission.
# Only if the owner_id is an relation we have two id's an etat_id
# (glossar owner) and an extra custommer_id which is stored in
# gl_glossar_terms to indicate which terms of a glossar , owned by a
# etat,  belong to a specific customer.
# This results into three possible displays.
# 1. owner_id is a customer_id (all glossars , owned by customer_id, 
#    with all terms will be displayed)
#
# 2. owner_id is a etat_id (all glossars, owened by etat_id, with all
#    terms will be displayed, while each term indicates to which
#    customer(_id) it belongs (happens if the term was added by a
#    relation), none if it belongs to the etat directly (happens if the
#    term was added by a etat) )
#
# 3. owner_id is a relation_id (all glossars, owned by the etat_id
#    which is stored in the relations object_id_one column, with all
#    terms having a customer_id, equal to the relations object_id_two.     
#    Question: Should it be possible to display all glossars
#    owned by the relations object_id_two (customer_id) including all
#    terms as well?


   
# This lib file deals with 1. and 2. only.

# No actions just a list of glossars

set actions [list "[_ glossar.New_Lecture]" [export_vars -base "${base_url}/glossar-add" {owner_id gl_translation_p }] "[_ glossar.New_Lecture]"]

lappend actions "[_ glossar.New_Translation]" [export_vars -base "${base_url}/glossar-add" {owner_id gl_translation_p }] "[_ glossar.Add_New_Translation]" 


set row_list [list name {} title {} description {} source_category {} target_category {} glossar_edit {} glossar_files {}]

# Just check permission on the first owner_id (the current customer) 
set no_perm_p 0

if [permission::permission_p -object_id $owner_id -privilege admin] {

} elseif {[permission::permission_p -object_id $owner_id -privilege create] || [group::member_p -group_name Employees]} {

    set user_perm create

} elseif {[permission::permission_p -object_id $owner_id -privilege read]} {

    set actions ""
    set row_list [list name {} title {} description {} source_category {} target_category {}]

} else {

    set no_perm_p 1
    set no_perm  "You don't have Permission to read Glossars !"


}

if {$no_perm_p == 0} {

template::list::create \
    -name gl_glossar_portlet \
    -key glossar_id \
    -no_data "[_ glossar.None]" \
    -selected_format $gl_format \
    -pass_properties {owner_id edit_link } \
    -elements {
	name {
	    label {[_ glossar.Organization_Name]}
	    display_template "<a href=\"@gl_glossar_portlet.new_glossar@\">@gl_glossar_portlet.name@</a>"
        }
	title {
	    label {[_ glossar.Title]}
	    display_template "<a href=\"@gl_glossar_portlet.title_url@\">@gl_glossar_portlet.title@</a>"
        }
        description {
	    label {[_ glossar.glossar_description]}
        }
        source_category {
	    label {[_ glossar.glossar_source_category_header]}
	}
        target_category {
	    label {[_ glossar.glossar_target_category]}
        }
	glossar_edit {
	    display_template {<a href="@gl_glossar_portlet.edit_url@"><img border="0" src="/shared/images/Edit16.gif" alt="#acs-kernel.common_Edit#" /></a>}
	}	
	glossar_files {
	    display_template "<a href=\"@gl_glossar_portlet.files_url@\">[_ glossar.Files]</a>"
	}	

    } -actions $actions -sub_class narrow \
    -orderby {
	default_value title
	glossar_id {
	    label {[_ glossar.glossar_id]}
	    orderby_desc {sort_key asc , glossar_id desc}
	    orderby_asc {sort_key asc , glossar_id asc}
	    default_direction desc
	}
	title {
	    label {[_ glossar.glossar_title]}
	    orderby_desc {sort_key asc, lower(title) desc}
	    orderby_asc {sort_key asc, lower(title) asc}
	    default_direction asc
	}
    }  -orderby_name orderby \
    -filters {
	owner_id {}
	edit_link {}
    } \
    -formats {
	normal {
	    label "[_ acs-templating.Table]"
	    layout table
	    elements $row_list 
	}
	csv {
	    label "[_ acs-templating.CSV]"
	    output csv
	    page_size 0
	    row 
	}
    } 


db_multirow -extend {source_category target_category gl_translation_p glossar_edit glossar_files files_url edit_url title_url new_glossar} gl_glossar_portlet $query_name  {} {
    if {![empty_string_p $target_category_id]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }
    set glossar_edit "[_ glossar.glossar_Edit]"
    set glossar_files "[_ glossar.files]"
    set source_category "[category::get_name $source_category_id]"
    set target_category "[category::get_name $target_category_id]"
    set title_url "[export_vars -base "${base_url}/glossar-term-list" {glossar_id gl_translation_p owner_id}]"
    set edit_url "[export_vars -base "${base_url}/glossar-add" {owner_id glossar_id gl_translation_p }]"
    set files_url "[export_vars -base "${base_url}/glossar-file-upload" {glossar_id}]"
    if {$gl_owner_id == $owner_id} {
	set new_glossar "[export_vars -base "${base_url}/index" {owner_id}]"
    } else {
	set new_glossar "[export_vars -base "${base_url}/index" {owner_id {customer_id $gl_owner_id}}]"
    }
} if_no_rows {
}

}
