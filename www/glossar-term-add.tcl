ad_page_contract {
    
    Create a new term
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-09
    @cvs-id $Id$
} {
    glossar_id:notnull
    term_id:optional
    {source_text ""}
    {target_text ""}
    {dont_text ""}
    {description ""}
    {__new_p 0}
    contact_id:notnull
} -properties {
}

db_1row glossar_title {}

if {![info exists term_id] || $__new_p} {
    set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] [list [export_vars -base "glossar-term-list" {glossar_id contact_id}] $glossar_title] "[_ glossar.glossar_term_add]"]
    set page_title "[_ glossar.Add_a_Term_to_a_Glossar]"
} else {
    set context [list [list "/contacts/$contact_id" [contact::name -party_id $contact_id]] [list [export_vars -base "glossar-term-list" {glossar_id contact_id}] $glossar_title] "[_ glossar.Edit_Term]"]
    set page_title "[_ glossar.Edit_Term]"
}

db_1row get_glossar_data {
    select g.target_category_id
    from gl_glossars g, cr_items gi
    where g.glossar_id = gi.latest_revision
    and gi.item_id = :glossar_id
}


set edit_buttons [list]

lappend edit_buttons [list "[_ acs-kernel.common_Save]" "ok" ]

if {![exists_and_not_null term_id]} {
    lappend edit_buttons [list "[_ acs-kernel.common_Next] >" "next" ]
}

ad_form -name glossar-term-add -edit_buttons $edit_buttons -export {glossar_id contact_id} -form {
    {term_id:key}
}

if {![empty_string_p $target_category_id]} {

    ad_form -extend -name glossar-term-add -form {
	{source_text:text(textarea),optional {label "[_ glossar.glossar_source_text]"} {html {rows 4 cols 50}}}
	{target_text:text(textarea),optional {label "[_ glossar.glossar_target_text]"} {html {rows 4 cols 50}}}
    }    
} else {

    ad_form -extend -name glossar-term-add -form {
	{source_text:text(textarea),optional {label "[_ glossar.glossar_singel_text]"} {html {rows 4 cols 50}}}
    }
}


ad_form -extend -name glossar-term-add -form {

    {dont_text:text(textarea),optional {label "[_ glossar.glossar_dont_text]"} {html {rows 4 cols 50}}}
    {description:text(textarea),optional {label "[_ glossar.glossar_comment]"} {html {rows 4 cols 50}}}

} -new_request {


    set source_text ""
    set target_text ""
    set dont_text ""
    set description ""

} -edit_request {
    
    db_1row get_term {
	SELECT crr.item_id as term_id, glt.source_text, glt.target_text, glt.dont_text, glt.owner_id as customer_id, crr.description  
	FROM gl_glossar_terms glt, cr_items cr , cr_revisions crr 
	WHERE  cr.latest_revision = crr.revision_id 
	AND crr.revision_id = glt.term_id
	AND crr.item_id = :term_id
	}	

} -new_data {
    

	set term_id [glossar::term::new -term_id $term_id -glossar_id $glossar_id -source_text "$source_text" -target_text "$target_text" -dont_text "$dont_text" -description "$description"]
    
} -edit_data {
        glossar::term::edit  -term_id $term_id -source_text $source_text -target_text $target_text -dont_text $dont_text -description $description
} -after_submit {

    set button [form::get_button glossar-term-add]

    if { ![string equal $button "ok"] } {
	set return_url  "[export_vars -base glossar-term-add {glossar_id contact_id}]"
    } else {
	set return_url "[export_vars -base glossar-term-list {glossar_id contact_id}]"
    }

    ad_returnredirect $return_url
    ad_script_abort
}

