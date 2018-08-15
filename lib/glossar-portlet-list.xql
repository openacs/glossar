<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-portlet-list.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-29 -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="gl_glossar_portlet">
    <querytext>  

      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id, org.name , 1 as query_number
      FROM gl_glossars gl, cr_items cr, cr_revisions crr , organizations org  
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id = org.organization_id
      AND org.organization_id = :customer_id 
      ORDER BY [template::list::orderby_clause -name gl_glossar_portlet]

    </querytext>
</fullquery>

  <fullquery name="gl_glossar_portlet_rel">
    <querytext>  

      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id, org.name , 1 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr , organizations org  
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id = org.organization_id
      AND org.organization_id = :customer_id 
      UNION
      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id, org.name , 2 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr, organizations org    
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id =  org.organization_id
      AND org.organization_id IN ($where_etat_ids)
      ORDER BY query_number asc , 
      [template::list::orderby_clause -name gl_glossar_portlet]

    </querytext>
</fullquery>

  <fullquery name="gl_glossar_portlet_customer">
    <querytext>  

      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id as gl_owner_id, org.name , 1 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr , organizations org  
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id = org.organization_id
      AND org.organization_id = :customer_id 
      UNION
      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id as gl_owner_id, org.name , 2 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr, organizations org    
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id =  r.rel_id
      AND r.object_id_one = :customer_id
      AND r.object_id_two = org.organization_id
      AND r.rel_type = 'contact_rels_agent'
      ORDER BY query_number asc , 
      [template::list::orderby_clause -name gl_glossar_portlet]

    </querytext>
</fullquery>

  <fullquery name="gl_glossar_portlet_etat">
    <querytext>  

      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id as gl_owner_id, org.name , 1 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr , organizations org  
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id = org.organization_id
      AND org.organization_id = :etat_id 
      UNION
      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id as gl_owner_id, org.name , 2 as query_number ,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr, organizations org    
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id =  r.rel_id
      AND r.object_id_one = org.organization_id
      AND r.object_id_two = :etat_id
      AND r.rel_type = 'contact_rels_agent'
      ORDER BY query_number asc , 
      [template::list::orderby_clause -name gl_glossar_portlet]

    </querytext>
</fullquery>
</queryset>
