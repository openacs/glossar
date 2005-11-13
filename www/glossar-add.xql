<?xml version="1.0"?>
<queryset>

<fullquery name="get_glossar">
    <querytext>
	select 
		crr.title, 
		crr.description, 
		gl.source_category_id, 
		gl.target_category_id, 
		gl.owner_id,
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

<fullquery name="check_if_is_etat">
    <querytext>
    select count(*)
    from group_member_map
    where group_id = :group_id
    and member_id = :owner_id
    </querytext>
</fullquery>

<fullquery name="get_etats">
    <querytext>
	SELECT 	name, organization_id as etat_id
	FROM 	organizations
	WHERE 	organization_id in (SELECT CASE	WHEN object_id_one = :owner_id
						THEN object_id_two
						ELSE object_id_one END as organization_id
				    FROM  acs_rels ar, acs_rel_types art
				    WHERE ar.rel_type = art.rel_type
				    AND  (object_id_one = :owner_id or object_id_two = :owner_id)
				    AND   ar.rel_type = 'contact_rels_etat')
    </querytext>
</fullquery>

</queryset>
