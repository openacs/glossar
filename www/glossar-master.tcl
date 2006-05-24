#    @author Matthew Geddert openacs@geddert.com
#    @creation-date 2005-05-09
#    @cvs-id $Id$


# Set up links in the navbar that the user has access to
set name [contact::name -party_id $party_id]
if { ![exists_and_not_null name] } {
    ad_complain "[_ contacts.lt_The_contact_specified]"
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set tasks_url [site_node::get_package_url -package_key "tasks"]
set page_url [ad_conn url]
set page_query [ad_conn query]
set title $name
set freelancer_p [group::member_p -user_id $party_id -group_name "Freelancer" -cascade]

if {![exists_and_not_null context]} {
    set context [list $name]
}

if {![empty_string_p $tasks_url]} {
    set prefix "/contacts/${party_id}/"
} else {
    set prefix "${package_url}${party_id}/"
}
set link_list [list]


if { [ad_conn user_id] != 0} {
    lappend link_list "${prefix}" "[_ contacts.Summary]"
    set organization_p [organization::organization_p -party_id $party_id]
    if {$organization_p} {
	lappend link_list [export_vars -base "/invoices/price-list" {{organization_id $party_id}}] "[_ invoices.iv_price_list]"
    }

    if {[empty_string_p $tasks_url]} {
	lappend link_list "${prefix}comments" "[_ contacts.Comments]"
    }

    lappend link_list "${prefix}files" "[_ contacts.Files]"

    if {![empty_string_p $tasks_url]} {
	lappend link_list "${prefix}history" "[_ contacts.History]"
	lappend link_list "/tasks/contact" "[_ contacts.Tasks]"
    }

    if {$freelancer_p} {
	lappend link_list [export_vars -base "/wieners/freelancer-bookings" {party_id}] "[_ contacts.Freelancer_bookings]"
    }

    lappend link_list "${prefix}message" "[_ contacts.Mail]"
    lappend link_list "${prefix}mail-tracking" "[_ mail-tracking.Mail_Tracking]"

    # The following adds a link to all projects of a customer, if the
    # project manager is linked
    if {$organization_p} {
	set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $party_id -to_object_type "dotlrn_club"] 0]

	if {$dotlrn_club_id > 0} {
	    set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]
	    if {![empty_string_p $pm_package_id]} {
		lappend link_list "[export_vars -base "[apm_package_url_from_id $pm_package_id]/index" -url {{assignee_id "-1"}}]" "[_ project-manager.Projects]"
	    }
	    set club_url [dotlrn_community::get_community_url $dotlrn_club_id]
	    lappend link_list "$club_url" "[_ contacts.Visit_Club]"
	} elseif {[group::party_member_p -party_id $party_id -group_name "Customers"]} {
	    lappend link_list "create-club" "[_ contacts.Create_Club]"
	}

    } else {
	set employer_id [lindex [lindex [contact::util::get_employers -employee_id $party_id] 0] 0]
	if {$employer_id > 0} {
	    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $employer_id -to_object_type "dotlrn_club"] 0]
	    if {$dotlrn_club_id > 0} {
		set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]
		if {![empty_string_p $pm_package_id]} {
		    lappend link_list "[export_vars -base "[apm_package_url_from_id $pm_package_id]/index" -url {{assignee_id "-1"} {contact_id $party_id}}]" "[_ project-manager.Projects]"
		}
	    }
	}
    }
}

# not yet implemented
#    lappend link_list "/contacts/contact-files"
#    lappend link_list "Files"
#    lappend link_list "/contacts/contact-history"
#    lappend link_list "History"





# Convert the list to a multirow and add the selected_p attribute
multirow create links label url selected_p

foreach {url label} $link_list {
    set selected_p 0
    if {[string equal $page_url $url]} {
        set selected_p 1
        if { $url != "/contacts/contact" } {
            set context [list [list [contact::url -party_id $party_id] $name] $label]
        }
    }
    # MGEDDERT CUSTOMIZATION
    if { $url == "/tasks/contact" } {
	set url [export_vars -base $url -url {party_id}]
    }
    lappend navbar [list [subst $url] $label]
    multirow append links $label [subst $url] $selected_p
}

if { [contact::type -party_id $party_id] == "user" } {
    set public_url [acs_community_member_url -user_id $party_id]
}

ad_return_template
