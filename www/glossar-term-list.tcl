# packages/glossar/www/glossar-term-list.tcl

ad_page_contract {
    
    Lists all Terms from one Glossary, display differs in Common and Translation.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-10
    @arch-tag: d5403149-1be2-467e-b9f6-062dcff4a565
    @cvs-id $Id$
} {
    glossar_id:notnull
    gl_translation_p:notnull
    owner_id:notnull
    {page ""}
    {orderby ""}
    {searchterm ""}
    {customer_id ""}
    {format "normal"}
} -properties {
    glossar_id
    gl_translation_p
    page
    orderby
    searchterm
    customer_id
    format
    owner_id
} -validate {
} -errors {
}

if {$customer_id == $owner_id} {
    set customer_id ""
}

