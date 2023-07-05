--This query returns information about items in the 'MH Leisure Books' location
--Created by Tim Dannay on 2023-02-24

--I had to adjust the query to account for the 5-hour time zone difference between our time and FOLIO’s GMT. 
--In the future, if FOLIO or LDLite starts to automatically adjust for the time zone difference, this query will need to be updated accordingly.
--To do this, remove "- interval '5 hours'" from the 'item_created_date' line of the SELECT statement.

select
	item.barcode,
	ins.title,
	holding.call_number,
	count(distinct clt.id) as circ_count,
	max(note.notes__note) filter (where nt.name = 'Legacy Circ Count') as legacy_circ_count,
	to_char(to_timestamp(item.metadata__created_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours', 'YYYY-MM-DD"T"HH24:MI:SS') as item_created_date,
	min(clt.loan_date) as first_loan_date,
	max(clt.loan_date) as last_loan_date,
	item.last_check_in__date_time as last_returned_date,
	item.status__name,
	ins.discovery_suppress as instance_suppressed,
	(case when loc2.name is null then 0 else 1 end)::boolean as in_temporary_location,
	item.metadata__updated_date as last_updated_date,
	max(note.notes__note) filter (where nt.name = 'Note') as note,
	ins.id as instance_uuid,
	holding.id as holding_uuid,
	item.id as item_uuid,
	loc.name as effective_location
from 
	inventory.instance__t ins 
	inner join inventory.holdings_record__t holding on ins.id = holding.instance_id 
	inner join inventory.item__t item on holding.id = item.holdings_record_id 
	inner join inventory.location__t loc on loc.id = item.effective_location_id
	left join inventory.location__t loc2 on loc2.id = item.temporary_location_id  
	left join orders.po_line__t__claims pltc on item.purchase_order_line_identifier = pltc.id
	left join circulation.loan__t clt on item.id = clt.item_id 
	left join inventory.item__t__notes note on item.id = note.id
	left join inventory.item_note_type__t nt on note.notes__item_note_type_id = nt.id
where
	loc.code = 'MLEIB'
group by 
	item.barcode,
	ins.title,
	holding.call_number,
	item.last_check_in__date_time,
	item.status__name, 
	loc2.name,
	item.metadata__updated_date,
	item.metadata__created_date,
	ins.discovery_suppress,
	ins.id,
	holding.id,
	item.id,
	loc.name;