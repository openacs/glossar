<?xml version="1.0"?>
<queryset>

<fullquery name="get_customers_from_prefix">      
      <querytext>

	SELECT	o.name , o.organization_id
	FROM 	organizations o, parties p, group_member_map m
	WHERE 	o.organization_id = p.party_id
	AND 	o.organization_id = m.member_id
        AND     m.group_id = :customer_group_id
	[contact::search_clause -and -search_id $search_id -query $query -party_id "p.party_id" -revision_id "revision_id"]

      </querytext>
</fullquery>

</queryset>
