--This query returns records that need to be updated in OCLC from before the migration to FOLIO.
--It uses the Aleph Bib Sys number to determine which records fall within the date range (starting from March 2020)
--Created by Tim Dannay on 2023-05-02
select
	m.content as "998$a",
	m2.content as "998$b Aleph Bib Sys Number",
	iti.identifiers__value as "OCLC Control Number",
	it.title as "Instance Title",
	item.status__name as "Item Status",
	item.barcode,
	lt.name as "Location",
	lt.code as "Location Code"
from 
	folio_source_record.marctab m
	inner join folio_source_record.marctab m2 on m.srs_id::uuid = m2.srs_id::uuid
	inner join inventory.instance__t it on m.instance_id::uuid = it.id::uuid
	inner join inventory.holdings_record__t hrt on it.id = hrt.instance_id 
	inner join inventory.item__t item on item.holdings_record_id = hrt.id
	inner join inventory.location__t lt on lt.id = hrt.effective_location_id
	inner join inventory.instance__t__identifiers iti on iti.id = it.id 
	inner join inventory.identifier_type__t itt on iti.identifiers__identifier_type_id = itt.id
where
	m.field = '998'
	and m.sf = 'a'
	and m.content = 'MH'
	and m2.field = '998'
	and m2.sf = 'b'
	and m2.content >= '017400700' --to capture records starting from March 2020
	and m.ord = m2.ord --This is how to ensure that the query only returns 998$b when it's from the same line as the 998$a (so you don't get 998$b from other schools)
	and itt.name = 'OCLC'
	and position('MH' in lt.name) = 1 --MH locations only
	and position('ME' in lt.code) != 1 --location code does not start with 'ME'
	and lt.code not in ('MMPER', 'MPPER', 'MMPDS', 'MMSTP'); -- more excluded location codes