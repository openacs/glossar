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

set glossar_id "0"

set gl_translation_p 0

#if {![exists_and_not_null owner_id]} {
#    set owner_id 499
#}

ns_log notice "OWNER_ID $owner_id"
if [empty_string_p "[ad_conn user_id]"] {
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


   

if {[db_0or1row owner_type_check {SELECT object_id_one , object_id_two FROM acs_rels WHERE rel_id = :owner_id}]} {
    set customer_id $object_id_two 
    set owner_id $object_id_one 
} else {

    if {![info exists customer_id]} {
	set customer_id ""
    }

    set owner_id $owner_id 
}

set actions [list "[_ glossar.New_Lecture]" [export_vars -base "${base_url}/glossar-add" {owner_id gl_translation_p customer_id }] "[_ glossar.New_Lecture]"]

set gl_translation_p 1

lappend actions "[_ glossar.New_Translation]" [export_vars -base "${base_url}/glossar-add" {owner_id gl_translation_p customer_id}] "[_ glossar.Add_New_Translation]" 


set row_list [list title description source_category target_category glossar_edit glossar_files]

set no_perm_p 0 

if [permission::permission_p -object_id $owner_id -privilege admin] {

} elseif {[permission::permission_p -object_id $owner_id -privilege create]} {

    set user_perm create

} elseif {[permission::permission_p -object_id $owner_id -privilege read]} {

    set actions ""
    set row_list [list title description source_category target_category]

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
	    display_template "<a href=\"@gl_glossar.edit_url@\">[_ acs-kernel.common_Edit]</a>"
	}	
	glossar_files {
	    display_template "<a href=\"@gl_glossar.files_url@\">[_ glossar.Files]</a>"
	}	

    } -actions $actions -sub_class narrow \
    -orderby {
	default_value title
	glossar_id {
	    label {[_ glossar.glossar_id]}
	    orderby_desc {sort_key asc , gl.glossar_id desc}
	    orderby_asc {sort_key asc , gl.glossar_id asc}
	    default_direction desc
	}
	title {
	    label {[_ glossar.glossar_title]}
	    orderby_desc {sort_key asc , crr.title desc}
	    orderby_asc {sort_key asc , crr.title asc}
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
	    label "[_ glossar.Table]"
	    layout table
	    elements $row_list 
	}
	csv {
	    label "[_ glossar.CSV]"
	    output csv
	    page_size 0
	    row 
	}
    } 



db_multirow -extend {source_category target_category gl_translation_p glossar_edit glossar_files files_url edit_url title_url} gl_glossar gl_glossar  {} {
    if {![empty_string_p $target_category_id]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }
    set glossar_edit "[_ glossar.glossar_Edit]"
    set glossar_files "[_ glossar.files]"
    set source_category "[category::get_name $source_category_id]"
    set target_category "[category::get_name $target_category_id]"
    set title_url "[export_vars -base "${base_url}/glossar-term-list" {glossar_id gl_translation_p customer_id owner_id}]"
    set edit_url "[export_vars -base "${base_url}/glossar-add" {owner_id glossar_id gl_translation_p }]"
    set files_url "[export_vars -base "${base_url}/glossar-file-upload" {glossar_id}]"
} if_no_rows {


}
}