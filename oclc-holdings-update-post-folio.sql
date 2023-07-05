--This query returns information about records that need to be updated with OCLC since migration to FOLIO. 
--The date range of the query can be edited as needed - see comments below.
--Created by Tim Dannay on 2023-04-28
select
	plt.id as "POL UUID",  
	plt.details__receiving_note as "POL Receiving Note",
	pt.received_date as "Piece Received Date",
	ot.name as "Vendor Name",
	it.barcode as "Item Barcode",
	it.status__name as "Item Status",
	it2.title as "Instance Title",
	lt.name as "Location Name",
	lt.code as "Location Code",
	max(iti.identifiers__value) as "OCLC Control Number", --uses the MAX function to eliminate duplicates from having both prefixed and un-prefixed OCLC numbers
	itt.name as "Identifier Type"
from
	orders.po_line__t plt 
	inner join orders.pieces__t pt on pt.po_line_id = plt.id 
	inner join orders.purchase_order__t pot on pot.id = plt.purchase_order_id
	inner join organizations.organizations__t ot on ot.id = pot.vendor
	inner join inventory.item__t it on it.id = pt.item_id
	inner join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id
	inner join inventory.instance__t it2 on it2.id = hrt.instance_id
	inner join inventory.location__t lt on lt.id = hrt.effective_location_id
	inner join inventory.instance__t__identifiers iti on iti.id = it2.id
	inner join inventory.identifier_type__t itt on itt.id = iti.identifiers__identifier_type_id
where 
	position('MH' in ot.name) = 1 -- vendor name starts with 'MH'
	and position('ME' in lt.code) != 1 --location code does not start with 'ME'
	and lt.code not in ('MMPER', 'MPPER', 'MMPDS', 'MMSTP') -- more excluded location codes
	and itt.name = 'OCLC' --only returns OCLC identifier, not others like ISBN
	and pt.received_date between '2023-01-01' and '2023-02-01' --date range for piece received date
group by --group by everything in the select statement that is not an aggregate function
	plt.id,  
	plt.details__receiving_note,
	pt.received_date,
	ot.name,
	it2.title,
	it.barcode,
	it.status__name,
	lt.name,
	lt.code,
	itt.name;