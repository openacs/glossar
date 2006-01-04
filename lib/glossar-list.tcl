# packages/glossar/lib/glossar-list.tcl
#
# Creates a List of all glossars which belong to a given object_id.
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-09
# @arch-tag: 4760fbcd-c60f-45c9-9ac2-735f3ddae15d
# @cvs-id $Id$

foreach required_param {owner_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {format page_size orderby customer_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}


#if {![exists_and_not_null base_url]} {
    set base_url "/glossar"
#}

if {![info exists format]} {
    set format "normal"
}

if {![info exists format]} {
    set page_size "25"
}

set user_id [ad_conn user_id]

if {[empty_string_p $user_id]} {
    ad_redirect_for_registration
}

# We check if the owner_id is an relation, if it is, the real_owner_id
# becomes the eta_id stored in gl_glossars, else it becomes the
# owner_id which can be a customer_id or a etat_id.
# We still pass on the owner_id to check permission.
# Only if the owner_id is an relation we have two id's an etat_id
# (glossar owner) and an extra custommer_id which is stored in
# gl_glossar_terms to indicate which terms of a glossar , owned by a
# etat,  belong to a specific customer.
# This results into thre possible displays.
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
#    Question: Should it be possible to to display all glossars
#    owned by the relations object_id_two (custommer_id) including all
#    terms as well?


set actions [list "[_ glossar.New_Lecture]" [export_vars -base "${base_url}/glossar-add" {owner_id {gl_translation_p 0} target_id }] "[_ glossar.New_Lecture]"]

lappend actions "[_ glossar.New_Translation]" [export_vars -base "${base_url}/glossar-add" {owner_id {gl_translation_p 1} target_id}] "[_ glossar.Add_New_Translation]" 

set return_url [ad_conn url]
set move_url "[export_vars -base "${base_url}/glossar-move" {$return_url}]"


if {[group::party_member_p -party_id $owner_id -group_name Etat]} {
    set target_name "[_ glossar.glossar_organization]"
} else {
    set target_name "[_ glossar.glossar_etat]"
}


set row_list [list checkbox {} title {} description {} source_category {} target_category {} glossar_edit {} glossar_files {}]

set no_perm_p 0 
set return_url [ad_conn url]

if [permission::permission_p -object_id $owner_id -privilege admin] {

} elseif {[permission::permission_p -object_id $owner_id -privilege create]} {

    set user_perm create

} elseif {[permission::permission_p -object_id $owner_id -privilege read]} {

    set actions ""
    set row_list [list title {} description {} source_category {} target_category {}]

} else {

    set no_perm "You don't have Permission to read Glossars !"
    set no_perm_p 1
}

if { $no_perm_p == 0} {

    template::list::create \
	-name gl_glossar \
	-key glossar_id \
	-no_data "[_ glossar.None]" \
	-selected_format $format \
	-pass_properties {customer_id owner_id edit_link} \
	-elements {
	    title {
		label {[_ glossar.glossar_title]}
		display_template "<a href=\"@gl_glossar.title_url@\">@gl_glossar.title@</a>"
	    }
	    name {
		label $target_name
		display_template {<if @gl_glossar.organization_id@ ne @owner_id@><a href="@gl_glossar.target_url@">@gl_glossar.name@</a></if><else>&nbsp;</else>}
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
		display_template {<a href="@gl_glossar.edit_url@"><img border="0" src="/shared/images/Edit16.gif" alt="#acs-kernel.common_Edit#" /></a>}
	    }	
	    glossar_perm {
		display_template {<a href="@gl_glossar.permission_url@"><img border="0" src="/glossar/resources/padlock.gif" alt="#glossar.set_permissions#" /></a>}
	    }	
	    glossar_files {
		display_template {<a href="@gl_glossar.files_url@"><img border="0" src="/glossar/resources/folder.gif" alt="#glossar.Files#"></a> (@gl_glossar.files_count@)}
	    }

	} -actions $actions -sub_class narrow \
	-bulk_actions [list "[_ glossar.glossar_Move]" $move_url "[_ glossar.glossar_Move2]"] \
	-bulk_action_export_vars {return_url} \
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
		orderby_desc {sort_key asc , gl_title desc}
		orderby_asc {sort_key asc, gl_title asc}
		default_direction asc
	    }
	}  -orderby_name orderby \
	-filters {
	    customer_id {}
	    edit_link {}
	} \
	-page_size_variable_p 1 \
	-page_size $page_size \
	-page_flush_p 0 \
	-page_query_name gl_glossar \
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



    db_multirow -extend {source_category target_category gl_translation_p files_url edit_url permission_url title_url target_url files_count} gl_glossar gl_glossar  {} {
	if {![empty_string_p $target_category_id]} {
	    set gl_translation_p 1
	} else {
	    set gl_translation_p 0
	}
	set files_count [db_string get_files_count { } -default 0]
	set source_category "[category::get_name $source_category_id]"
	set target_category "[category::get_name $target_category_id]"
	set title_url "[export_vars -base "${base_url}/glossar-term-list" {glossar_id}]"
	set edit_url "[export_vars -base "${base_url}/glossar-edit" {glossar_id}]"
	set permission_url "[export_vars -base "/permissions/one" {{object_id $glossar_id} {application_url [ad_return_url]}}]"
	set files_url "[export_vars -base "${base_url}/glossar-file-upload" {glossar_id}]"
	set target_url "/contacts/$organization_id"
    } if_no_rows {
	
	
    }
}