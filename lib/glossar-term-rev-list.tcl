# packages/glossar/lib/glossar-term-rev-list.tcl
#
# Lists all revisions of one Term
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-15
# @arch-tag: ebb70c9d-b79d-4db8-9a77-ad97244684fe
# @cvs-id $Id$



foreach required_param {glossar_id term_id searchterm} {
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


set user_id [ad_conn user_id]
set locale [lang::user::site_wide_locale -user_id $user_id]
set time_format "[lc_get -locale $locale d_fmt] %X"

db_1row get_glossar_data {
    select g.target_category_id
    from gl_glossars g, cr_items gi
    where g.glossar_id = gi.latest_revision
    and gi.item_id = :glossar_id
}


if {![empty_string_p $target_category_id]} {

    set row_list [list source_text {} target_text {} dont_text {} description {} last_modified {} creation_user {}]
    set source_text_lable [_ glossar.glossar_source_text]
    set actions ""

} else {

    set row_list [list source_text {} dont_text {} description {} last_modified {} creation_user {}]
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
    -selected_format normal \
    -no_data "[_ glossar.term_None]" \
    -pass_properties {glossar_id} \
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
	    label {[_ glossar.glossar_comment]}
        } 
	last_modified {
	    label {[_ glossar.glossar_modified_at]}
	} 
	creation_user {
	    label {[_ glossar.glossar_creation_user]}
	    display_template {<a href="@gl_term_rev.creator_url@">@gl_term_rev.last_name@, @gl_term_rev.first_names@</a>}
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
	    label {[_ glossar.glossar_modified_at]}
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
	    row $row_list  
	}
	csv {
	    label "[_ acs-templating.CSV]"
	    output csv
	    page_size 2
	    row $row_list
	}
    }


# This elements will be added at least


# May add extra order_by clause

set hidden_vars [export_vars -form {glossar_id gl_translation_p orderby format page term_id}] 
db_multirow  -extend {gl_translation_p creator_url} gl_term_rev gl_term_rev  {} {
    set creator_url [acs_community_member_url -user_id $creation_user]
    set last_modified [lc_time_fmt $last_modified $time_format]
    if {![empty_string_p $target_text]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }
} if_no_rows {}
