<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-list-postgresql.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-09 -->
<!-- @cvs-id $Id$ -->

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>

<fullquery name="gl_glossar">
    <querytext>  
      SELECT cr_items.item_id as glossar_id, cr_revisions.title, cr_revisions.description,
              gl_glossars.source_category_id, gl_glossars.target_category_id,
              gl_glossars.owner_id as gl_owner_id, organizations.name, 1 as query_number,
              case when gl_glossars.target_category_id is null then 0 else 1 end as sort_key,
              organizations.organization_id, lower(cr_revisions.title) as gl_title
      FROM gl_glossars, cr_items, cr_revisions, organizations
      WHERE cr_items.latest_revision = cr_revisions.revision_id 
      AND cr_revisions.revision_id = gl_glossars.glossar_id	
      AND gl_glossars.owner_id = organizations.organization_id
      AND organizations.organization_id = :owner_id
      UNION
      SELECT cr_items.item_id as glossar_id, cr_revisions.title as gl_title, cr_revisions.description,
              gl_glossars.source_category_id, gl_glossars.target_category_id,
              gl_glossars.owner_id as gl_owner_id, organizations.name, 2 as query_number,
              case when gl_glossars.target_category_id is null then 0 else 1 end as sort_key,
              organizations.organization_id, lower(cr_revisions.title) as gl_title
      FROM gl_glossars, cr_items, cr_revisions, organizations, acs_rels
      WHERE cr_items.latest_revision = cr_revisions.revision_id 
      AND cr_revisions.revision_id = gl_glossars.glossar_id	
      AND gl_glossars.owner_id =  acs_rels.rel_id
      AND ((acs_rels.object_id_one = organizations.organization_id AND acs_rels.object_id_two = :owner_id)
      OR (acs_rels.object_id_two = organizations.organization_id AND acs_rels.object_id_one = :owner_id))
      AND acs_rels.rel_type = 'contact_rels_etat'
      ORDER BY
      -- query_number asc,
      [template::list::orderby_clause -name gl_glossar]
    </querytext>
</fullquery>

<fullquery name="get_files_count">
   <querytext>
	select 
		count(ci.item_id)
	from 
		cr_items ci
    	where 
		ci.parent_id = :glossar_id
		and ci.content_type != 'gl_glossar_term'
                and ci.live_revision is not null
   </querytext>
</fullquery>

</queryset>
