# packages/glossar/tcl/glossar-procs.tcl

ad_library {
    
    
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2005-07-06
    @arch-tag: b4f83a02-5128-4d28-a681-b73b7ffdb205
    @cvs-id $Id$
}


#namespace eval gl_glossar {}
# 2006/08/03 cognovis/nfl: namespace change from gl_glossar to glossar
namespace eval glossar {}
namespace eval glossar::glossary {}
namespace eval glossar::term {}

ad_proc -public glossar::glossary::new {

    -owner_id:required
    -source_category_id:required
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-target_category_id [db_null]}
    {-etat_id ""}

} {
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-13

    New Glossar
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }
    set folder_id [content::folder::get_folder_from_package -package_id $package_id]

    set item_id [db_nextval acs_object_id_seq]

    db_transaction {
	if {[empty_string_p $name]} {
	    set name "gl_glossar_$item_id"
	}
	set item_id [content::item::new -parent_id $folder_id -content_type {gl_glossar} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {gl_glossar} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list owner_id $owner_id] \
					 [list source_category_id $source_category_id] \
					 [list target_category_id $target_category_id] \
					 [list etat_id $etat_id] \
					] ]
    }

    return $new_id
}


ad_proc -public glossar::glossary::edit {
    -glossar_item_id:required
    -owner_id:required
    -source_category_id:required
    -target_category_id:required
    -etat_id:required
    {-title ""}
    {-name ""}
    {-description ""}
} {
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-13-07

    Edit Glossar
} {
    set new_rev_id [content::revision::new \
			-item_id $glossar_item_id \
			-content_type {gl_glossar} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list owner_id $owner_id] \
					 [list source_category_id $source_category_id] \
					 [list target_category_id $target_category_id] \
					 [list etat_id $etat_id] \
					] ]
    return $new_rev_id
}




ad_proc -public glossar::term::new {
    -glossar_id:required
    {-term_id ""}
    {-source_text ""}
    {-target_text ""}
    {-dont_text ""}
    {-comment ""}
    {-name ""}
    {-package_id ""}
    {-title ""}
    {-description ""}
    {-customer_id ""}

} {
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-13

    New Glossar Term
} {
    if {[empty_string_p $package_id]} {
	set package_id [ad_conn package_id]
    }


    set item_id [db_nextval acs_object_id_seq]
    db_transaction {
	if {[empty_string_p $name]} {
	    set name "gl_glossar_term_$item_id"
	}
	set item_id [content::item::new -parent_id $glossar_id -content_type {gl_glossar_term} -name $name -package_id $package_id -item_id $item_id]

	set new_id [content::revision::new \
			-item_id $item_id \
			-content_type {gl_glossar_term} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list source_text $source_text] \
					 [list target_text $target_text] \
					 [list dont_text $dont_text] \
					 [list owner_id $customer_id] \
				    ] ]
    }

    return $new_id
}



ad_proc -public glossar::term::edit {
    -term_id:required
    {-source_text ""}
    {-target_text ""}
    {-dont_text ""}
    {-title ""}
    {-name ""}
    {-description ""}
    {-customer_id ""}

} {
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-13-07

    Edit Glossar Term
} {
    set new_rev_id [content::revision::new \
			-item_id $term_id \
			-content_type {gl_glossar_term} \
			-title $title \
			-description $description \
			-attributes [list \
					 [list source_text $source_text] \
					 [list target_text $target_text] \
					 [list dont_text $dont_text] \
					 [list owner_id $customer_id]
				    ] ]
    return $new_rev_id
}



# created 2006/08/03 by cognovis/nfl
ad_proc -public glossar::term::delete {
    -term_id:required
} {
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-03

    Delete Glossar Term
} {      
    db_transaction {
	permission::require_write_permission -object_id $term_id
        ns_log Notice "Deleting glossar term $term_id"
	content::item::delete -item_id $term_id
    }     
}

# created 2006/08/03 by cognovis/nfl
# finished 2006/08/04 by cognovis/nfl  
ad_proc -public glossar::glossary::delete {
    -glossar_item_id:required
} {
    @author Nils Lohse (nils.lohse@cognovis.de)
    @creation-date 2006-08-03

    Delete Glossar
} {
    #db_transaction {
	# First, delete all terms
        # ... it's done automatically by deleting the glossar itself. Cool.
	# Second, delete the Glossar itself
	db_transaction {
	    permission::require_write_permission -object_id $glossar_item_id
	    ns_log Notice "Deleting glossar $glossar_item_id"
	    content::item::delete -item_id $glossar_item_id
	}    
    #}
}
