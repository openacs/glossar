<master src="/packages/contacts/lib/contact-master" />
  <property name="party_id">@contact_id@</property>
  <property name="context">@context;noquote@</property>
  <property name="title">@page_title;noquote@</property>

<p>#glossar.glossar_move_search#</p>
<p>
<formtemplate id="search" style="/packages/contacts/resources/forms/inline"></formtemplate>
</p>

<if @query@ not nil>
<listtemplate name="customers"></listtemplate>
</if>
