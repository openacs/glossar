<master>
<property name="title">@title;noquote@</property>
<property name="context">@context;noquote@</property>
<property name="header_stuff">
  <link href="/resources/contacts/contacts.css" rel="stylesheet" type="text/css">
</property>
<property name="navbar_list">@navbar;noquote@</property>
<if @focus@ not nil>
<property name="focus">@focus@</property>
</if>

<slave>
