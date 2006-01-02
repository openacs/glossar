# packages/glossar/www/index.tcl

ad_page_contract {
    
    Index page displays all existing glossars for agiven object_id (currently its the user_id in future it will be the etat_id )
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @arch-tag: 2581ef43-4729-4f1a-951a-8222894330e2
    @cvs-id $Id$
} {
    {owner_id ""}
    {orderby ""}
    {customer_id ""}
    {format "normal"}
} 

set owner_id [ad_conn user_id]

# If we do not have a customer, set the customer to the user
# this way it will be a "personal" glossar.

if {[empty_string_p $customer_id]} {
    set customer_id $owner_id
}

set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -party_id $owner_id -privilege "admin"]



