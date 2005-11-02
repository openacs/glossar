# packages/glossar/tcl/glossar-install-procs.tcl

ad_library {
    
    
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-07-13
    @arch-tag: 52912475-f200-4cac-a89f-c4db0e7df38c
    @cvs-id $Id$
}



namespace eval gl_glossar::install {}

ad_proc -public gl_glossar::install::create_install {
} {
    Creates the content types and adds the attributes.
} {
    content::type::new -content_type {gl_glossar} -supertype {content_revision} -pretty_name {[_ glossar.Glossar]} -pretty_plural {[_ glossar.Glossars]} -table_name {gl_glossars} -id_column {glossar_id}
    content::type::new -content_type {gl_glossar_term} -supertype {content_revision} -pretty_name {[_ glossar.Glossar_Term]} -pretty_plural {[_ glossar.Glossar_Terms]} -table_name {gl_glossar_terms} -id_column {term_id}

    # Glossar attribs
    content::type::attribute::new -content_type {gl_glossar} -attribute_name {owner_id} -datatype {number} -pretty_name {[_ glossar.glossar_owner]} -column_spec {interger}
    content::type::attribute::new -content_type {gl_glossar} -attribute_name {source_category_id} -datatype {number} -pretty_name {[_ glossar.glossar_source_category]} -column_spec {interger}
    content::type::attribute::new -content_type {gl_glossar} -attribute_name {target_category_id} -datatype {number} -pretty_name {[_ glossar.glossar_target_category]} -column_spec {interger}
    content::type::attribute::new -content_type {gl_glossar} -attribute_name {etat_id} -datatype {number} -pretty_name {[_ glossar.glossar_etat]} -column_spec {integer}

# Glossar Term Attribs.

    content::type::attribute::new -content_type {gl_glossar_term} -attribute_name {source_text} -datatype {string} -pretty_name {[_ glossar.glossar_source_text]} -column_spec {varchar(4000)}
    content::type::attribute::new -content_type {gl_glossar_term} -attribute_name {target_text} -datatype {string} -pretty_name {[_ glossar.glossar_target_text]} -column_spec {varchar(4000)}
    content::type::attribute::new -content_type {gl_glossar_term} -attribute_name {dont_text} -datatype {string} -pretty_name {[_ glossar.glossar_dont_text]} -column_spec {varchar(4000)}
    content::type::attribute::new -content_type {gl_glossar_term} -attribute_name {owner_id} -datatype {number} -pretty_name {[_ glossar.glossar_customer_id]} -column_spec {integer}

}

ad_proc -public gl_glossar::install::package_instantiate {
    -package_id:required
} {
    Define folders
} {
    # create a content folder
    set folder_id [content::folder::new -name "glossar_$package_id" -package_id $package_id]
    # register the allowed content types for a folder
    content::folder::register_content_type -folder_id $folder_id -content_type {gl_glossar} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {gl_glossar_term} -include_subtypes t
    
    # Create the default objects to map the category trees using the admin UI
    package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "#glossar.from_default_object_id#"]] acs_object
    package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "#glossar.to_default_object_id#"]] acs_object


}


ad_proc -public gl_glossar::install::package_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    Procedure for upgrade Glossar package
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
	-spec {
	    0.3d1 0.3d2 {
		# Create the default objects to map the category trees using the admin UI
		set package_id [ad_conn package_id]

		package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "#glossar.from_default_object_id#"]] acs_object
    
	        package_instantiate_object -package_name acs_object -var_list [list [list new__context_id $package_id] [list new__package_id $package_id] [list new__title "#glossar.to_default_object_id#"]] acs_object

	    }
	    0.3d2 0.3d3 {
		content::type::attribute::new -content_type {gl_glossar} -attribute_name {etat_id} -datatype {number} -pretty_name {[_ glossar.glossar_etat]} -column_spec {integer}
	    }
	}
}