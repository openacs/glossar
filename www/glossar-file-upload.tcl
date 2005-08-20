# packages/glossar/www/glossar-file-upload.tcl

ad_page_contract {
    
    Uploding files for a Glossar into cr.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-21
    @arch-tag: ec515574-bf31-4d15-8a3f-536c4dca63a3
    @cvs-id $Id$
} {
    glossar_id:notnull
    {upload_count "1"}
    {order_by  "file,asc"}
} -properties {
    glossar_id
    upload_count
    order_by
} -validate {
} -errors {
}

