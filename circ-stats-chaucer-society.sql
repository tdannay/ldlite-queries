--This query returns circlation stats (both FOLIO and pre-FOLIO) for items in the Chaucer Society series
--Created by Tim Dannay, 2023-06-30
select 
	it.title as "Title",
	its.series as "Series", 
	hrt.call_number as "Call Number",
	it2.barcode as "Item Barcode",
	count(lt.id) as "Loan Count since FOLIO",
	itn.notes__note as "Loan Count before FOLIO"
from 
	inventory.instance__t it
	left join inventory.holdings_record__t hrt on hrt.instance_id = it.id 
	left join inventory.item__t it2 on hrt.id = it2.holdings_record_id 
	left join inventory.instance__t__series its on it.id = its.id
	left join circulation.loan__t lt on lt.item_id = it2.id
	left join inventory.item__t__notes itn on itn.id = it2.id
	left join inventory.item_note_type__t intt on itn.notes__item_note_type_id = intt.id
where 
	its.series like '%Chaucer Society%' --returns only items with "Chaucer Society" in the series statement of the instance record
	and (position('3102035' in it2.barcode) = '1' OR (it2.barcode like '%MH' and not it2.barcode like '%AMH')) --Ensures only MHC items are included
	and intt.name = 'Legacy Circ Count' --pre-FOLIO stats are stored in a note field with this name
group by 
	it.title,
	its.series,
	hrt.call_number,
	it2.barcode,
	itn.notes__note 