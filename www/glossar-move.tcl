ad_page_contract {
    glossar-move

    A page to allow the moving of a glossar to other customers.

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-24
    
} {
    {return_url "/"}
    {query ""}
    {glossar_id:notnull,multiple}
    contact_id:notnull
}

#move glossar
set page_title "[_ glossar.glossar_move]"
set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] $page_title]

set search_id ""
set glossar_id [string trim $glossar_id "{}"]
set customer_group_id [group::get_id -group_name "Customers"]


ad_form -name search -export {glossar_id contact_id} -form {
    {query:text(text) {label ""} {html {size 24}}}
    {search:text(submit) {value 1} {label "[_ glossar.search]"}}
}

template::list::create \
    -name customers \
    -multirow customers \
    -key customer_id \
    -elements {
	name {
	    label {}
	    display_template {
		@customers.name@ <span style="padding-left: 1em; font-size: 80%;">\[<a href="@customers.move_url@">select</a>\]</span>
	    }
	}
    }
db_multirow -extend {move_url} customers get_customers_from_prefix {} {
    set move_url [export_vars -base "move-glossar" {{customer_id $organization_id} glossar_id:multiple return_url contact_id}]
}
