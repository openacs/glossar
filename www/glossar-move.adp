<master>
<property name="title">Move glossar</property>
<property name="context">@context@</property>

<h1>Move glossar</h1>
 
<p>Search for <b>Customers</b> who's name contains: </p>
<p>
<formtemplate id="search" style="../../../contacts/resources/forms/inline"></formtemplate>
</p>

<if @query@ not nil>
<listtemplate name="customers"></listtemplate>
</if>