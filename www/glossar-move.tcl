ad_page_contract {
    glossar-move

    A page to allow the moving of a glossar to other customers.

    @author Al-Faisal El-Dajani (faisal.dajani@gmail.com)
    @creation-date 2005-10-24
    
} {
    {return_url "/"}
    {query ""}
    {glossar_id:notnull,multiple}
}

set context "search"
set search_id ""
set glossar_id [string trim $glossar_id "{}"]


ad_form -name search -export {glossar_id} -form {
    {query:text(text) {label ""} {html {size 24}}}
    {Search:text(submit) {value "Search"}}
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
    set move_url [export_vars -base "move-glossar" {{customer_id $organization_id} glossar_id:multiple return_url}]
}