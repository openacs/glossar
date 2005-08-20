#
#  Copyright (C) 2005 Cognovis
#  Author: Bjoern Kiesbye (kiesbye@theservice.de)

#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_library {

    Procedures to support the Glossar Package
    

    @author kiesbye@theservice.de
    @cvs-id $Id: glossar-portlet-procs.tcl

}

namespace eval glossar_portlet {

    ad_proc -private my_package_key {
    } {
        return "glossar-portlet"
    }

    ad_proc -private get_my_name {
    } {
        return "glossar_portlet"
    }

    ad_proc -public get_pretty_name {
    } {
        return "Glossar Portlet"
    }

    ad_proc -public link {
    } {
	return [site_node::get_package_url -package_key glossar]
    }

    ad_proc -public add_self_to_page {
	{-portal_id:required}
	{-package_id:required}
	{-param_action "overwrite"}
        {-page_name ""}
        {-pretty_name ""}
        {-force_region ""}
	{-scoped_p ""}

    } {
	Adds a Contact Portlet to the given page.

	@param portal_id The page to add self to
	@return element_id The new element's id

    } {
        
        # allow overrides of pretty_name and force_region
        if {[empty_string_p $pretty_name]} {
            set pretty_name [get_pretty_name]
        }

        if {[empty_string_p $force_region]} {
            set force_region [parameter::get_from_package_key \
                                  -package_key [my_package_key] \
                                  -parameter "force_region"
            ]
        }

        set extra_params ""

        
        return [portal::add_element_parameters \
                    -portal_id $portal_id \
                    -page_name $page_name \
                    -portlet_name [get_my_name] \
		    -value $package_id \
                    -pretty_name $pretty_name \
                    -force_region $force_region \
		    -param_action $param_action

        ]
    }




    ad_proc -public remove_self_from_page {
	{-portal_id:required}

    } {
        Removes a Contacts Portlet from the given page.

	  @param portal_id The page to remove self from
	  @param project_manager_id
    } {
        portal::remove_element_parameters \
            -portal_id $portal_id \
            -portlet_name [get_my_name] \
    }



    ad_proc -public show {
	 cf
    } {
    } {
        portal::show_proc_helper \
            -package_key [my_package_key] \
            -config_list $cf \
	    -template_src glossar-list
	
    }

}
