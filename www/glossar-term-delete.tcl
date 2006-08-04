# packages/glossar/www/glossar-term-delete.tcl 

ad_page_contract {
    
    Delete a glossar term and return to the return_url
    
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-03
} {
    term_id
    return_url
} -properties {
} -validate {
} -errors {
}

glossar::term::delete -term_id $term_id

ad_returnredirect $return_url
