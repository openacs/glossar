<?xml version="1.0"?>
<queryset>

<fullquery name="get_customers_from_prefix">      
      <querytext>

	SELECT	o.name , o.organization_id
	FROM 	organizations o, parties p
	WHERE 	o.organization_id = p.party_id
	AND 	o.organization_id in ([template::util::tcl_to_sql_list [group::get_members -group_id [group::get_id -group_name "Customers"]]])
	[contact::search_clause -and -search_id $search_id -query $query -party_id "o.party_id" -revision_id "revision_id"]

      </querytext>
</fullquery>

 
</queryset>
