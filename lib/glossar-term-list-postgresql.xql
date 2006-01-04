<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-term-list-postgresql.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-10 -->
<!-- @arch-tag: 5a282ebc-0f59-404f-ba8b-3bdf75962607 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
<fullquery name="glossars_rel">
    <querytext>
       SELECT gi.item_id, g.owner_id, o.name
      FROM gl_glossars g, cr_items gi, organizations o, acs_rels r
      WHERE gi.latest_revision = g.glossar_id
      AND g.owner_id = o.organization_id
      AND g.source_category_id = :source_category_id
      AND g.target_category_id = :target_category_id
      AND r.rel_id = :owner_id
      AND r.object_id_one = o.organization_id
      AND r.rel_type = 'contact_rels_etat'
    </querytext>
</fullquery>

<fullquery name="glossars_etat">
    <querytext>
       SELECT gi.item_id, g.owner_id, o.name
      FROM gl_glossars g, cr_items gi, organizations o, acs_rels r
      WHERE gi.latest_revision = g.glossar_id
      AND g.owner_id = r.rel_id
      AND g.source_category_id = :source_category_id
      AND g.target_category_id = :target_category_id
      AND r.object_id_one = :owner_id
      AND r.object_id_two = o.organization_id
      AND r.rel_type = 'contact_rels_etat'
    </querytext>
</fullquery>

<fullquery name="gl_term">
    <querytext>
       SELECT crr.item_id as term_id, crr.description, glt.source_text,
              glt.target_text, glt.dont_text, aco.creation_user, p.first_names, p.last_name,
              to_char(aco.last_modified , 'YYYY-MM-DD HH24:MI:SS') as last_modified, g.owner_id,
              gi.item_id as gl_glossar_id
      FROM gl_glossar_terms glt, cr_items cr, cr_revisions crr , acs_objects aco , persons p,
           gl_glossars g, cr_items gi
      WHERE cr.latest_revision = crr.revision_id
      AND crr.revision_id = glt.term_id
      AND crr.revision_id = aco.object_id
      AND aco.creation_user = p.person_id
      AND cr.parent_id in ([join $glossar_ids ,]) 
      AND g.glossar_id = gi.latest_revision
      AND gi.item_id = cr.parent_id
	$where_customer_id
        [template::list::filter_where_clauses -and -name gl_term]
	$where_format  [template::list::page_where_clause -name gl_term]
	[template::list::orderby_clause -orderby -name gl_term]
    </querytext>
</fullquery>

<fullquery name="gl_term_page">
    <querytext>
       SELECT  crr.item_id
      FROM cr_items cr, cr_revisions crr , gl_glossar_terms glt, acs_objects aco , persons p,
           gl_glossars g, cr_items gi
      WHERE cr.latest_revision = crr.revision_id
      AND crr.revision_id = glt.term_id
      AND crr.revision_id = aco.object_id
      AND aco.creation_user = p.person_id	
      AND cr.parent_id in ([join $glossar_ids ,]) 
      AND g.glossar_id = gi.latest_revision
      AND gi.item_id = cr.parent_id
      [template::list::filter_where_clauses -and -name gl_term]
    </querytext>
</fullquery>

<fullquery name="get_glossar_info">
    <querytext>
    select 
           g.object_id,
           g.owner_id,
           g.title as glossar_title, 
           g.description as glossar_comment,
           g.source_category_id,
           g.target_category_id
    from 
           gl_glossarsx g, 
           cr_items i
    where 
           g.context_id = :glossar_id
           and i.item_id = g.context_id
           and i.latest_revision = g.object_id
    </querytext>
</fullquery>

<fullquery name="get_files">
    <querytext>
	select 
		ci.item_id,
   		cr.title,
    		ci.name
    	from 
		cr_items ci, 
		cr_revisions cr
    	where 
		ci.parent_id = :glossar_id
    		and ci.live_revision = cr.revision_id
    </querytext>
</fullquery>

</queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>
  
