#
# Lists all Terms from one Glossar
#
# @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
# @creation-date 2005-07-10
# @cvs-id $Id$
# 2006/08/03 nfl/cognovis: with delete term functionality
# 2006/08/14 nfl/cognovis: new alternative layout for printing

foreach required_param {glossar_id contact_id searchterm} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {page orderby format customer_id} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

if {![info exists layout_for_printing]} {
  set layout_for_printing 0
}

# Get glossar info
set glossar_info [db_1row get_glossar_info { }]

set glossar_language [category::get_name $source_category_id]
set glossar_target_lan [category::get_name $target_category_id]
set user_id [ad_conn user_id]
#set return_url [ad_conn url]
set return_url [export_vars -base [ad_conn url] {glossar_id contact_id}]
set locale [lang::user::site_wide_locale -user_id $user_id]
set time_format "[lc_get -locale $locale d_fmt] %X"
set freelancer_p [group::member_p -user_id $user_id -group_name Freelancer]

if {[empty_string_p $glossar_language] } {
    set glossar_language "<div align=\"center\"> - - - - - - - - -</div>"
}

# get all the files
db_multirow files get_files {}

if {![info exists format]} {
    set format "normal"
}

if {![info exists page_size]} {
    #set page_size "25"
    # 2006/08/14 the line above was never used, because 10 was hard coded below! (nfl)
    #2006/09/26 set page_size 10
    # 2006/09/26 Customer want's it all on one page. So trick it like the print version.
    set page_size 10000000
}
if {$layout_for_printing==1} {
    set page_size ""
    # no pagination when printing (layout)
    set page_size 10000000
    # okay, trick it... 10 million entries per page... ;-)
}



if {[empty_string_p $user_id]} {
    ad_redirect_for_registration
}

set edit_p [permission::permission_p -object_id $glossar_id -party_id $user_id -privilege create]

if {$edit_p} {
    set row_list [list source_text {} target_text {} dont_text {} description {} owner {} last_modified {} creation_user {} edit {} delete {} history {}]
} else {
    set row_list [list source_text {} target_text {} dont_text {} description {} owner {} last_modified {} creator_name {}] 
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

if {![empty_string_p $target_category_id]} {

    set target_where_clause "AND g.target_category_id = :target_category_id"
    set source_text_lable [_ glossar.glossar_source_text]
    if {$layout_for_printing!=1} {
	set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id contact_id}] "[_ glossar.glossar_New_term]" ]
    } else {
	set actions ""
    }

} else {

    set target_where_clause ""
    set row_list [lreplace $row_list 2 3]
    set source_text_lable [_ glossar.glossar_singel_text]
    if {$layout_for_printing!=1} {
	set actions [list "[_ glossar.glossar_New_term]" [export_vars -base glossar-term-add {glossar_id contact_id}] "[_ glossar.glossar_New_term]"]
    } else {
	set actions ""
    }
}

# get glossars with matching languages that belongs to the relationships
db_foreach $glossar_query_name {} {
    lappend glossar_ids $item_id
    set owners($owner_id) $name
}



if {[permission::permission_p -object_id $glossar_id -privilege admin]} {

    if {$format == "normal"} {
	
	set where_format " AND  "
	if {$layout_for_printing!=1} {
	    lappend actions "[_ glossar.glossar_Format_CSV]" [export_vars -base glossar-term-list {glossar_id contact_id {format csv}}] "[_ glossar.glossar_New2]"
	}

    } else {

	set where_format "   "
	if {$layout_for_printing!=1} {
	    lappend actions "[_ glossar.glossar_Format_Normal]" [export_vars -base glossar-term-list {glossar_id contact_id {format normal}}] "[_ glossar.glossar_New2]"
	}
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
	    label {[_ glossar.glossar_comment]}
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
	creator_name {
	    label {[_ glossar.glossar_creation_user]}
	} 
	edit {
	    label " "
	    display_template {<if @gl_term.layout_for_printer@ not eq 1><a href="@gl_term.edit_url@"><img border="0" src="/shared/images/Edit16.gif" alt="#acs-kernel.common_Edit#" /></a></if>}
	}
        delete {
            label " "
            display_template {<if @gl_term.layout_for_printer@ not eq 1><a href="@gl_term.delete_url@"><img border="0" src="/shared/images/Delete16.gif" alt="\#acs-kernel.common_Delete\#" /></a></if>}
        }
	history {
	    label " "
	    display_template {<if @gl_term.layout_for_printer@ not eq 1><a href="@gl_term.history_url@">#glossar.glossar_term_history#</a></if>}
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
	description {
	    label {[_ glossar.glossar_comment]}
	    orderby_desc {lower(crr.description) desc}
	    orderby_asc {lower(crr.description) asc}
	    default_direction asc
	}
	owner {
	    label {[_ glossar.glossar_owner]}
	    orderby_desc {g.owner_id desc}
	    orderby_asc {g.owner_id asc}
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
	contact_id {}
	searchterm {
	    label "[_ glossar.glossar_term_search]"
	    where_clause $search_where_clause
	}
    } -page_size_variable_p 0 \
    -page_size $page_size \
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



set hidden_vars [export_vars -form {glossar_id gl_translation_p orderby format page owner_id customer_id contact_id }] 

db_multirow  -extend {gl_translation_p creator_url creator_name edit_url delete_url history_url owner layout_for_printer} gl_term gl_term  {} {
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

    set creator_name "$first_names $last_name"
    set last_modified [lc_time_fmt $last_modified $time_format]
    set creator_url [acs_community_member_url -user_id $creation_user]
    set edit_url [export_vars -base glossar-term-add {glossar_id term_id contact_id}]
    set delete_url [export_vars -base glossar-term-delete {term_id return_url}]
    set history_url [export_vars -base glossar-term-rev-list {glossar_id term_id contact_id}]
    set layout_for_printer $layout_for_printing
} if_no_rows {}

template::list::write_output -name gl_term
