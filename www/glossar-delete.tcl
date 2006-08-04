ad_page_contract {
    Delete a glossar with confirmation

    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-03
} {
    glossar_id:integer
    return_url
} -properties {
    context:onevalue
    page_title:onevalue
}

# i18n
# glossar.Delete_Glossar
# glossar.Delete_Glossar_irreversibly
# glossar.continue_with_delete
# glossar.cancel_and_return

set user_id [auth::require_login]

set page_title "[_ glossar.Delete_Glossar]"

set context [list $page_title]

set confirm_options [list [list "[_ glossar.continue_with_delete]" t] [list "[_ glossar.cancel_and_return]" f]]

set glossar_name [content::item::get_title -item_id $glossar_id]

ad_form -name delete_confirm -action glossar-delete -form {
    {glossar_id:key}
    {glossar_name:text(inform) {label "[_ glossar.Delete_Glossar_irreversibly]"}}
    {confirmation:text(radio) {label " "} {options $confirm_options} {value f}}
    {return_url:text(hidden)}
} -edit_request {
} -on_submit {
    if {$confirmation == "t"} {
	glossar::glossary::delete -glossar_item_id $glossar_id
    }
} -after_submit {
    if {$confirmation == "t"} {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect $return_url
    }
    ad_script_abort
}

ad_return_template
