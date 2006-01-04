# packages/glossar/lib/glossar-term-list.tcl
#
# Lists all Terms from one Glossar
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-10
# @arch-tag: beb88796-955e-4cbd-af5e-3919597c7ed1
# @cvs-id $Id$

foreach required_param {glossar_id searchterm} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {page orderby format customer_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

# Get glossar info
set glossar_info [db_1row get_glossar_info { }]

set glossar_language [category::get_name $source_category_id]
set glossar_target_lan [category::get_name $target_category_id]
set user_id [ad_conn user_id]
set locale [lang::user::site_wide_locale -user_id $user_id]
set time_format "[lc_get -locale $locale d_fmt] %X"
set freelancer_p [group::member_p -user_id $user_id -group_name Freelancer]

if {[empty_string_p $glossar_language] } {
    set glossar_language "<div align=\"center\"> - - - - - - - - -</div>"
}

if {[empty_string_p $glossar_target_lan] } {
    set glossar_target_lan "<div align=\"center\"> - - - - - - - - -</div>"
}

# get all the files
set files [list]
db_foreach get_files { } {
    lappend files "<a href=\"download/?file_id=$item_id\" title=\"$name\">$title</a>"
}

if {[empty_string_p $files] } {
    set files "<div align=\"center\"> - - - - - - - - -</div>"
} else {
    set files [join $files ",&nbsp;&nbsp;"]
}

if {![info exists format]} {
    set format "normal"
}

if {![info exists page_size]} {
    set page_size "25"
}




if {[empty_string_p $user_id]} {
    ad_redirect_for_registration
}


if {$format == "normal"} {
    set row_list [list source_text {} target_text {} dont_text {} description {} owner {} last_modified {} creation_user {} edit {} history {}]
} else {
    set row_list [list source_text {} target_text {} dont_text {} description {} owner {} last_modified {} creation_user {}] 
}

set glossar_ids $glossar_id
set organization_p [organization::organization_p -party_id $owner_id]
if {$organization_p} {
    # glossar is etat-glossar or customer-glossar
    set glossar_query_name glossars_etat
    set glossar_owner_lable "[_ glossar.glossar_organization]"

    if {![group::party_member_p -party_id $owner_id -group_name Etat]} {
	# if glossar belongs to customer, dont show 
	set row_list [lreplace $row_list 8 9]
    }
} else {
    # glossar is relation-glossar
    set glossar_query_name glossars_rel
    set glossar_owner_lable "[_ glossar.glossar_etat]"
}

# get glossars with matching languages that belongs to the relationships
db_foreach $glossar_query_name {} {
    lappend glossar_ids $item_id
    set owners($owner_id) $name
}

if {![empty_string_p $target_category_id]} {
    
    set source_text_lable [_ glossar.glossar_source_text]
    set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id}] "[_ glossar.glossar_New_term]" ]

} else {

    set row_list [lreplace $row_list 2 3]
    set source_text_lable [_ glossar.glossar_singel_text]
    set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id}] "[_ glossar.glossar_New_term]"]

}



if {[permission::permission_p -object_id $glossar_id -privilege admin]} {

    if {$format == "normal"} {
	
	set where_format " AND  "
	lappend actions "[_ glossar.glossar_Format_CSV]" [export_vars -base glossar-term-list {glossar_id {format csv}}] "[_ glossar.glossar_New2]"

    } else {

	set where_format "   "
	lappend actions "[_ glossar.glossar_Format_Normal]" [export_vars -base glossar-term-list {glossar_id {format normal}}] "[_ glossar.glossar_New2]"
    }

} elseif {[permission::permission_p -object_id $glossar_id -privilege create]} {
    set actions $actions 
    set where_format " AND  "

} elseif {[permission::permission_p -object_id $glossar_id -privilege read]} {

    set actions ""
    set where_format " AND "
   
} else {
    ad_return_forbidden "No Permission!" "You don't have Permission to read Glossars !"
    ad_script_abort
}






# Build search_clause

set search_term_types [list source_text target_text dont_text first_names last_name]
if [exists_and_not_null searchterm] {
    
    # Split the search terms and connect them
    foreach term [split $searchterm] {
        foreach term_type $search_term_types {
            lappend search_where_list "lower($term_type) like lower('%$term%')"
        }
    }
    
    set search_where_clause "([join $search_where_list " or "])"
} else {
    set search_where_clause ""
}


if { [empty_string_p $customer_id] } {
    set where_customer_id " "
} else {
    set where_customer_id " AND glt.owner_id = $customer_id "
}


template::list::create \
    -name gl_term \
    -multirow gl_term \
    -key crr.item_id \
    -no_data "[_ glossar.term_None]" \
    -pass_properties {glossar_id} \
    -selected_format $format \
    -elements {
	source_text {
	    label {$source_text_lable} 
	}
	target_text { 
	    label {[_ glossar.glossar_target_text]}
        }
	dont_text {
	    label {[_ glossar.glossar_dont_text]}
        }
        description {
	    label {[_ glossar.glossar_description]}
        } 
	owner {
	    label {$glossar_owner_lable}
	} 
	last_modified {
	    label {[_ glossar.glossar_last_modified]}
	} 
	creation_user {
	    label {[_ glossar.glossar_creation_user]}
	    display_template {<a href="@gl_term.creator_url@">@gl_term.last_name@, @gl_term.first_names@</a>}
	} 
	edit {
	    label " "
	    display_template {<a href="@gl_term.edit_url@"><img border="0" src="/shared/images/Edit16.gif" alt="#acs-kernel.common_Edit#" /></a>}
	}
	history {
	    label " "
	    display_template {<a href="@gl_term.history_url@">#glossar.glossar_term_history#</a>}
	}
    } -actions $actions -sub_class narrow \
    -orderby_name orderby \
    -orderby {
     default_value source_text
	source_text {
	    label {$source_text_lable} 
	    orderby_desc {lower(glt.source_text) desc}
	    orderby_asc {lower(glt.source_text) asc}
	    default_direction asc
	}
	target_text {
	    label {[_ glossar.glossar_target_text]}
	    orderby_desc {lower(glt.target_text) desc}
	    orderby_asc {lower(glt.target_text) asc}
	    default_direction asc
	}
	dont_text {
	    label {[_ glossar.glossar_dont_text]}
	    orderby_desc {lower(glt.dont_text) desc}
	    orderby_asc {lower(glt.dont_text) asc}
	    default_direction asc
	}
	last_modified {
	    label {[_ glossar.glossar_last_modified]}
	    orderby_desc {aco.last_modified desc}
	    orderby_asc {aco.last_modified asc}
	    default_direction asc
	}
	creation_user {
	    label {[_ glossar.glossar_creation_user]}
	    orderby_desc {lower(p.last_name desc, lower(p.first_names) desc}
	    orderby_asc {lower(p.last_name) asc, lower(p.first_names) asc}
	    default_direction asc
	}
    } -filters {
	glossar_id {}
	searchterm {
	    label "[_ glossar.glossar_term_search]"
	    where_clause $search_where_clause
	}
    } -page_size_variable_p 0 \
    -page_size 10 \
    -page_flush_p 1 \
    -page_query_name gl_term_page \
    -formats {
	normal {
	    label "[_ acs-templating.Table]"
	    layout table
	    row $row_list  
	}
	csv {
	    label "[_ acs-templating.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }



set hidden_vars [export_vars -form {glossar_id gl_translation_p orderby format page owner_id customer_id }] 

db_multirow  -extend {gl_translation_p creator_url edit_url history_url owner} gl_term gl_term  {} {
    if {![empty_string_p $target_text]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }

    if {$gl_glossar_id != $glossar_id} {
	# entry is from different glossar
	if {$freelancer_p && $organization_p} {
	    set owner "[_ glossar.glossar_organization]"
	} else {
	    set owner "$owners($owner_id)"
	}
    } else {
	set owner ""
    }

    set last_modified [lc_time_fmt $last_modified $time_format]
    set creator_url [acs_community_member_url -user_id $creation_user]
    set edit_url [export_vars -base glossar-term-add {glossar_id term_id}]
    set history_url [export_vars -base glossar-term-rev-list {glossar_id term_id}]
} if_no_rows {}

# template::list::write_output -name gl_term
