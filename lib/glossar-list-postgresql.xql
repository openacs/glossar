<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-list-postgresql.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-09 -->
<!-- @arch-tag: 7a2fde2f-c68e-4164-9c22-3cb9de2ac468 -->
<!-- @cvs-id $Id$ -->

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>

<fullquery name="gl_glossar">
    <querytext>  
      SELECT cr.item_id as glossar_id , crr.title , crr.description , gl.source_category_id , gl.target_category_id , gl.owner_id,
case when gl.target_category_id is null then 0 else 1 end as sort_key  
      FROM gl_glossars gl, cr_items cr, cr_revisions crr  
      WHERE cr.latest_revision = crr.revision_id 
      AND crr.revision_id = gl.glossar_id	
      AND gl.owner_id = :owner_id 
      [template::list::orderby_clause -orderby -name gl_glossar]
    </querytext>
</fullquery>

</queryset>
