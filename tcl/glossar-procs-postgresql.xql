<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/tcl/glossar-procs-postgresql.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-06 -->
<!-- @arch-tag: c2d9a186-8625-4bbf-af01-038ae50a8dca -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="gl_glossar::new.glossar_new">
    <querytext>
      SELECT gl_glossar__new(
      	null , 
      	:owner_id , 
      	:title , 
      	:comment , 
      	:source_category_id , 
      	:target_category_id , 
      	'gl_glossar' ,  
      	current_timestamp , 
      	:user_id ,
	'' ,
	null ,
      	:package_id	
      ) as glossar_id
      </querytext>
</fullquery>

<fullquery name="gl_glossar::edit.glossar_edit">
    <querytext>
      UPDATE gl_glossars 
      SET 
      title = :title , 
      comment = :comment , 
      source_category_id = :source_category_id , 
      target_category_id = :target_category_id 
      WHERE glossar_id = :glossar_id
      </querytext>
</fullquery>

<fullquery name="gl_glossar::term_new.glossar_term_new">
    <querytext>
	SELECT gl_glossar_term__new(null, :glossar_id , :comment , :source_text , :target_text , :dont_text , null , current_timestamp , :user_id , :user_ip , null , :package_id ) as term_id 
    </querytext>
</fullquery>

<fullquery name="gl_glossar::term_edit.glossar_term_edit_who">
    <querytext>
      UPDATE acs_objects 
      SET modifying_user = :user_id ,
      last_modified = current_timestamp
      WHERE acs_object_id = :term_id
    </querytext>
</fullquery>

<fullquery name="gl_glossar::term_edit.glossar_term_edit_data">
    <querytext>
      UPDATE gl_glossar_terms 
      SET 
      source_text = :source_text , 
      target_text = :target_text , 
      dont_text = :dont_text , 
      comment = :comment 
      WHERE term_id = :term_id
    </querytext>
</fullquery>



</queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>
  
