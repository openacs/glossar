# packages/glossar/lib/glossar-term-rev-list.tcl
#
# Lists all revisions of one Term
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-15
# @arch-tag: ebb70c9d-b79d-4db8-9a77-ad97244684fe
# @cvs-id $Id$



foreach required_param {glossar_id term_id gl_translation_p searchterm} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {page orderby} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}



if {![info exists format]} {
    set format "normal"
}

if {![info exists page_size]} {
    set page_size "25"
}





if {$gl_translation_p == 1} {

    set row_list [list  source_text target_text dont_text description last_modified first_names last_name ]
    set source_text_lable [_ glossar.glossar_source_text]
    set actions ""

} else {

    set row_list [list  source_text dont_text description last_modified first_names last_name ]
    set source_text_lable [_ glossar.glossar_singel_text]
    set actions ""

}



# Build search_clause

set search_term_types [list source_text target_text dont_text p.first_names p.last_name]
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




template::list::create \
    -name gl_term_rev \
    -multirow gl_term_rev \
    -key crr.revision_id \
    -no_data "[_ glossar.term_None]" \
    -selected_format normal \
    -pass_properties {glossar_id} \
    -elements {
	source_text {
	    label {"$source_text_lable"} 
	}
	target_text { 
	    label {[_ glossar.glossar_target_text]}
        }
	dont_text {
	    label {[_ glossar.glossar_dont_text]}
        }
        description {
	    label {[_ glossar.glossar_comment]}
        } 
	last_modified {
	    label {[_ glossar.glossar_modified_at]}
	} 
	first_names {
	    label {[_ glossar.glossar_first_names]}
	    link_url_eval {[acs_community_member_url -user_id $creation_user]}
	} 
	last_name {
	    label {[_ glossar.glossar_last_name]}
	    link_url_eval {[acs_community_member_url -user_id $creation_user]}
	} 
    } -actions $actions -sub_class narrow \
    -orderby_name orderby \
    -orderby {
     default_value source_text
     source_text {
	 label {$source_text_lable}
	 orderby_desc {glt.source_text desc}
	 orderby_asc {glt.source_text asc}
	 default_direction asc
     }
     target_text {
	 label {[_ glossar.glossar_target_text]}
	 orderby_desc {glt.target_text desc}
	 orderby_asc {glt.target_text asc}
	 default_direction asc
     }
      dont_text {
	    label {[_ glossar.glossar_dont_text]}
	    orderby_desc {glt.dont_text desc}
	    orderby_asc {glt.dont_text asc}
	    default_direction asc
	}
	last_modified {
	    label {[_ glossar.glossar_modified_at]}
	    orderby_desc {aco.last_modified desc}
	    orderby_asc {aco.last_modified asc}
	    default_direction asc
	}
	first_names {
	    label {[_ glossar.glossar_first_names]}
	    orderby_desc {p.first_names desc}
	    orderby_asc {p.first_names asc}
	    default_direction asc
	}
	last_name {
	    label {[_ glossar.glossar_last_name]}
	    orderby_desc {p.last_name desc}
	    orderby_asc {p.last_name asc}
	    default_direction asc
	}
    } -filters {
	glossar_id {}
	gl_translation_p {}
	term_id {}
	searchterm {
	    label "[_ glossar.glossar_term_search]"
	    where_clause $search_where_clause
	}
    } -page_size_variable_p 0 \
    -page_size 10 \
    -page_flush_p 1 \
    -page_query_name gl_term_rev_page \
    -formats {
	normal {
	    label "[_ acs-templating.Table]"
	    layout table
	    elements $row_list  
	}
	csv {
	    label "[_ acs-templating.CSV]"
	    output csv
	    page_size 2
	    elements $row_list
	}
    }


# This elements will be added at least


# May add extra order_by clause

set hidden_vars [export_vars -form {glossar_id gl_translation_p orderby format page term_id}] 
db_multirow  -extend {gl_translation_p} gl_term_rev gl_term_rev  {} {
    if {![empty_string_p $target_text]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }
} if_no_rows {}