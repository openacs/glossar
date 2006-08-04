ad_page_contract {
    Moves a glossar to a customer
} {
    customer_id:integer,notnull
    glossar_id:integer,notnull,multiple
    contact_id:notnull
    {return_url}
}

db_transaction {
    foreach id $glossar_id {
	set glossar_revision_id [content::item::get_best_revision -item_id $id]
	set owner_id $customer_id

	db_1row get_glossar_info {
	    SELECT g.source_category_id, g.target_category_id, g.etat_id, r.title, r.description,
	           g.owner_id as old_owner_id
	    FROM   gl_glossars g, cr_revisions r
	    WHERE  g.glossar_id = :glossar_revision_id
	    AND    g.glossar_id = r.revision_id
	}

	db_0or1row check_owner_rel {
	    select rel_id as owner_id
	    from acs_rels
	    where rel_type = 'contact_rels_etat'
	    and object_id_one = :contact_id
	    and object_id_two = :customer_id
	    and exists (select 1 from acs_rels where rel_id = :old_owner_id)
	}
    
	glossar::glossary::edit -glossar_item_id $id \
	    -owner_id $owner_id \
	    -source_category_id $source_category_id\
	    -target_category_id $target_category_id\
	    -etat_id "" \
	    -title $title \
	    -description $description
    }
}

ad_returnredirect "/contacts/$customer_id"
