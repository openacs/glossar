<?xml version="1.0"?>
<queryset>

<fullquery name="check_translation_p">
    <querytext>
    SELECT case when g.target_category_id is null then 'f' else 't' end as translation_p, g.owner_id,
           g.source_category_id as source_cat_id, g.target_category_id as target_cat_id
    FROM   gl_glossars g,
           cr_items i
    WHERE  i.item_id = :glossar_id
    AND    g.glossar_id = i.latest_revision
    </querytext>
</fullquery>

<fullquery name="get_glossar">
    <querytext>
    SELECT r.title,
           r.description,
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

<fullquery name="check_rel_owner">
    <querytext>
    select case when object_id_one = :contact_id then object_id_two else object_id_one end as rel_target_id,
           :contact_id as owner_id
    from acs_rels
    where rel_id = :owner_id
    and rel_type = 'contact_rels_etat'
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

<fullquery name="get_rel_id">
    <querytext>
	SELECT :contact_id as owner_id
	FROM  acs_rels ar
	WHERE ar.rel_id = :owner_id
	AND   ar.rel_type = 'contact_rels_etat'
    </querytext>
</fullquery>

<fullquery name="get_rel_id2">
    <querytext>
	SELECT ar.rel_id as owner_id
	FROM  acs_rels ar
	WHERE ((object_id_one = :owner_id and object_id_two = :target_id)
	OR  (object_id_one = :target_id and object_id_two = :owner_id))
	AND   ar.rel_type = 'contact_rels_etat'
    </querytext>
</fullquery>

</queryset>
