ad_page_contract {
    Moves a glossar to a customer
} {
    customer_id:integer,notnull
    glossar_id:integer,notnull,multiple
    {return_url}
}

foreach id $glossar_id {
    set glossar_revision_id [content::item::get_best_revision -item_id $id]
    db_1row get_glossar_info {
	SELECT g.source_category_id, g.target_category_id, g.etat_id, r.title, r.description
	FROM   gl_glossars g, cr_revisions r
	WHERE  g.glossar_id = :glossar_revision_id
	AND    g.glossar_id = r.revision_id
    }
    
    gl_glossar::edit -glossar_item_id $id \
	-owner_id $customer_id \
	-source_category_id $source_category_id\
	-target_category_id $target_category_id\
	-etat_id $etat_id \
	-title $title \
	-description $description
}

ad_returnredirect $return_url