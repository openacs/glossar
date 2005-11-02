<?xml version="1.0"?>
<queryset>

<fullquery name="get_glossar">
    <querytext>
	select 
		crr.title, 
		crr.description, 
		gl.source_category_id, 
		gl.target_category_id, 
		gl.owner_id 
		gl.etat_id
	from 
		gl_glossars gl, 
		cr_items cr, 
		cr_revisions crr 
	where 
		cr.latest_revision = crr.revision_id 
		and crr.revision_id = gl.glossar_id 
		and cr.item_id = :glossar_id
    </querytext>
</fullquery>

<fullquery name="get_from_default_object">
    <querytext>
        select
                object_id
        from
                acs_objects
        where
                title = '#glossar.from_default_object_id#'
    </querytext>
</fullquery>

<fullquery name="get_to_default_object">
    <querytext>
        select
                object_id
        from
                acs_objects
        where
                title = '#glossar.to_default_object_id#'
    </querytext>
</fullquery>

</queryset>
