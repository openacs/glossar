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
    contact_id:notnull
} -properties {
    glossar_id
    page
    orderby
    searchterm
    term_id

}

db_1row glossar_title {}
db_1row term_title {}

set page_title "[_ glossar.Glossar_term_history_of] \"$term_title\""
set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] [list [export_vars -base "glossar-term-list" {glossar_id contact_id}] $glossar_title] $page_title]
