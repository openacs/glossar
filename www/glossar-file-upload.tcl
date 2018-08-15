ad_page_contract {
    
    Uploding files for a Glossar into cr.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-21
    @cvs-id $Id$
} {
    glossar_id:notnull
    {upload_count "1"}
    {order_by  "file,asc"}
    contact_id:notnull
} -properties {
    glossar_id
    upload_count
    order_by
}

set page_title "[_ glossar.Glossar_Files]"
set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] $page_title]

db_1row glossar_title {}

append page_title ": $glossar_title"
