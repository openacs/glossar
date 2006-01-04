# packages/glossar/www/glossar-term-list.tcl

ad_page_contract {
    
    Lists all revisions from one Term, display differs in Common and Translation.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-10
    @arch-tag: d5403149-1be2-467e-b9f6-062dcff4a565
    @cvs-id $Id$
} {
    glossar_id:notnull
    term_id:notnull
    {page ""}
    {orderby ""}
    {searchterm ""}
} -properties {
    glossar_id
    page
    orderby
    searchterm
    term_id
} -validate {
} -errors {
}
