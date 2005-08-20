# packages/glossar/lib/glossar-term-list.tcl
#
# Lists all Terms from one Glossar
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-10
# @arch-tag: beb88796-955e-4cbd-af5e-3919597c7ed1
# @cvs-id $Id$

foreach required_param {glossar_id gl_translation_p searchterm customer_id owner_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {page orderby format customer_id} {
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




if [empty_string_p "[ad_conn user_id]"] {
    ad_redirect_for_registration
}


if {$gl_translation_p == 1} {
    
    if {$format == "normal"} {
	set row_list [list  source_text target_text dont_text description last_modified first_names last_name term_id]
    } else {
    	set row_list [list source_text {} target_text {} dont_text {} description {} last_modified {} first_names {} last_name {}] 
    }

    set source_text_lable [_ glossar.glossar_source_text]
    set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id gl_translation_p owner_id customer_id}] "[_ glossar.glossar_New_term]" ]

} else {
    
    if {$format == "normal"} {
    set row_list [list  source_text dont_text description last_modified first_names last_name term_id]
    } else {
	set row_list [list source_text {} dont_text {} description {} last_modified {} first_names {} last_name {} ]
    }
    set source_text_lable [_ glossar.glossar_singel_text]
    set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id gl_translation_p owner_id customer_id}] "[_ glossar.glossar_New_term]"]

}



if [permission::permission_p -object_id $owner_id -privilege admin] {

    set cur_format $format
    if {$format == "normal"} {
	
	set where_format " AND  "
	set format "csv"
	lappend actions "[_ glossar.glossar_Format_CSV]" [export_vars -base glossar-term-list {glossar_id gl_translation_p format owner_id customer_id}] "[_ glossar.glossar_New2]"

    } else {

	set where_format "   "
	set format "normal"
	lappend actions "[_ glossar.glossar_Format_Normal]" [export_vars -base glossar-term-list {glossar_id gl_translation_p format customer_id}] "[_ glossar.glossar_New2]"

    }


    set format $cur_format 

} elseif {[permission::permission_p -object_id $owner_id -privilege create]} {
    set actions $actions 
    set where_format " AND  "

} elseif {[permission::permission_p -object_id $owner_id -privilege read]} {

    set actions ""
    set where_format " AND "
   
} else {
    ad_return_forbidden "No Permission!" "You don't have Permission to read Glossars !"
    ad_script_abort
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


if { [empty_string_p $customer_id] } {

    set where_customer_id " "
    
} else {

    set where_customer_id " AND glt.owner_id = $customer_id "

}



ns_log notice "FORMAT 3: $format"

template::list::create \
    -name gl_term \
    -multirow gl_term \
    -key crr.item_id \
    -no_data "[_ glossar.term_None]" \
    -selected_format $format \
    -pass_properties {glossar_id customer_id owner_id} \
    -elements {
	source_text {
	    label {"$source_text_lable"} 
	    display_template "<a href=\"glossar-term-add?glossar_id=@gl_term.glossar_id@&gl_translation_p=@gl_term.gl_translation_p@&term_id=@gl_term.term_id@\">@gl_term.source_text@</a>"
	}
	target_text { 
	    label {[_ glossar.glossar_target_text]}
	    display_template "<a href=\"glossar-term-add?glossar_id=@gl_term.glossar_id@&gl_translation_p=@gl_term.gl_translation_p@&term_id=@gl_term.term_id@\">@gl_term.target_text@</a>"
        }
	dont_text {
	    label {[_ glossar.glossar_dont_text]}
	    display_template "<a href=\"glossar-term-rev-list?glossar_id=@gl_term.glossar_id@&gl_translation_p=@gl_term.gl_translation_p@&term_id=@gl_term.term_id@\">@gl_term.dont_text@</a>"
        }
        description {
	    label {[_ glossar.glossar_description]}
        } 
	last_modified {
	    label {[_ glossar.glossar_last_modified]}
	} 
	first_names {
	    label {[_ glossar.glossar_first_names]}
	    link_url_eval {[acs_community_member_url -user_id $creation_user]}
	} 
	last_name {
	    label {[_ glossar.glossar_last_name]}
	    link_url_eval {[acs_community_member_url -user_id $creation_user]}
	} 
	term_id {
	    label {[_ glossar.glossar_term_edit]}
	    display_template "<a href=\"glossar-term-add?glossar_id=@gl_term.glossar_id@&gl_translation_p=@gl_term.gl_translation_p@&term_id=@gl_term.term_id@&owner_id=@owner_id@&customer_id=@customer_id@\">[_ glossar.glossar_term_edit]</a>"
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
	    label {[_ glossar.glossar_last_modified]}
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
	customer_id {}
	searchterm {
	    label "[_ glossar.glossar_term_search]"
	    where_clause $search_where_clause
	}
    } -page_size_variable_p 0 \
    -page_size 10 \
    -page_flush_p t \
    -page_query_name gl_term_page \
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
	    row $row_list
	    	    
	}
    }



# This elements will be added at least


# May add extra order_by clause

set hidden_vars [export_vars -form {glossar_id gl_translation_p orderby format page owner_id customer_id }] 
db_multirow  -extend {gl_translation_p} gl_term gl_term  {} {
    if {![empty_string_p $target_text]} {
	set gl_translation_p 1
    } else {
	set gl_translation_p 0
    }
} if_no_rows {}

template::list::write_output -name gl_term