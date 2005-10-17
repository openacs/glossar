# /packages/glossar/www/admin/index.tcl

ad_page_contract {
    Glossar Administation Index Page

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {

}

set page_title "[_ glossar.Glossar_Administration]"
set context [list]

set categories_node_id [db_string get_category_node_id {}]
set categories_url [site_node::get_url -node_id $categories_node_id]
set from_object_id [db_string get_from_default_object { }]
set to_object_id [db_string get_to_default_object { }]

set from_url "$categories_url[export_vars -base cadmin/one-object {{object_id $from_object_id}}]"
set to_url "$categories_url[export_vars -base cadmin/one-object {{object_id $to_object_id}}]"


