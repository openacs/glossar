<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-term-rev-list.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-15 -->
<!-- @arch-tag: f4506527-2078-479c-9c55-d6dc8f5cd5a8 -->
<!-- @cvs-id $Id$ -->

<queryset>
  

  
<fullquery name="gl_term_rev">
    <querytext>
       SELECT  crr.item_id as term_id, crr.revision_id , crr.description , glt.source_text , glt.target_text , glt.dont_text, aco.creation_user , to_char(aco.last_modified , 'DD.MM.YY HH24:MI') as last_modified , p.first_names , p.last_name 
      FROM gl_glossar_terms glt, cr_revisions crr, cr_items cr,  acs_objects aco, persons p 
      WHERE crr.item_id = :term_id
      AND crr.revision_id = glt.term_id
      AND crr.item_id = cr.item_id
      AND aco.object_id = crr.revision_id
      AND aco.creation_user = p.person_id
      [template::list::filter_where_clauses -and -name gl_term_rev]
	AND [template::list::page_where_clause -name gl_term_rev]
	[template::list::orderby_clause -orderby -name gl_term_rev]
    </querytext>
</fullquery>

<fullquery name="gl_term_rev_page">
    <querytext>
       SELECT  crr.revision_id
      FROM   cr_revisions crr , gl_glossar_terms glt, acs_objects aco , persons p 
      WHERE crr.item_id = :term_id
      AND crr.revision_id = glt.term_id
      AND crr.revision_id = aco.object_id
      AND aco.creation_user = p.person_id	
      [template::list::filter_where_clauses -and -name gl_term_rev]
    </querytext>
</fullquery>

</queryset>