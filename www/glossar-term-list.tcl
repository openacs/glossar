ad_page_contract {
    
    Lists all Terms from one Glossary, display differs in Common and Translation.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-10
    @cvs-id $Id$
} {
    glossar_id:notnull
    {page ""}
    {orderby ""}
    {searchterm ""}
    {format "normal"}
    contact_id:notnull
} -properties {
    glossar_id
    gl_translation_p
    page
    orderby
    searchterm
    customer_id
    format
    owner_id
}

db_1row glossar_title {}

set page_title "[_ glossar.Glossars] \"$glossar_title\""
set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] $page_title]
