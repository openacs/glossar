<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/glossar/lib/glossar-list-postgresql.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-07-09 -->
<!-- @cvs-id $Id$ -->

<queryset>

<fullquery name="gl_glossar">
    <querytext>  
      SELECT glossar_id , title , comment , source_category_id , target_category_id 
      FROM gl_glossars g 
      WHERE g.owner_id = :owner_id 

    </querytext>
</fullquery>


</queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.2</version>
  </rdbms>
  
