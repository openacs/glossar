<master>
  <property name="title">#glossar.Glossars#</property>
  <property name="context">#glossar.index#</property>
<if @admin_p@>
    <div align="right"><a href="admin/">#glossar.Glossar_Administration#</a></div>  
</if>

 <include src="../lib/glossar-list" owner_id=@owner_id@ orderby=@orderby@ customer_id=@customer_id@ format=@format@></include>