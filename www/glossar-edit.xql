<?xml version="1.0"?>
<queryset>

<fullquery name="get_glossar">
    <querytext>
    SELECT r.title,
           r.description as comment,
           g.source_category_id,
           g.target_category_id,
           g.etat_id,
           g.owner_id
    FROM   gl_glossars g,
           cr_revisions r,
           cr_items i
    WHERE  i.item_id = :glossar_id
    AND    r.revision_id = i.latest_revision
    AND    g.glossar_id = r.revision_id
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

</queryset>
