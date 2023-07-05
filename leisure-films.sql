--This query returns information about items in the 'MH Leisure Films' location
--Created by Tim Dannay on 2023-02-24

--I had to adjust the query to account for the 5-hour time zone difference between our time and FOLIO’s GMT. 
--In the future, if FOLIO or LDLite starts to automatically adjust for the time zone difference, this query will need to be updated accordingly.
--To do this, remove "- interval '5 hours'" from the 'item_created_date' line of the SELECT statement.

select
	item.barcode,
	ins.title,
	item.status__name,
	count(distinct clt.id) as circ_count,
	max(note.notes__note) filter (where nt.name = 'Legacy Circ Count') as legacy_circ_count,
	max(note.notes__note) filter (where nt.name = 'Note') as note,
	max(itcn.circulation_notes__note) filter (where itcn.circulation_notes__note_type = 'Check in') as checkin_note,
	max(itcn.circulation_notes__note) filter (where itcn.circulation_notes__note_type = 'Check out') as checkout_note,
	to_char(to_timestamp(item.metadata__created_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours', 'YYYY-MM-DD"T"HH24:MI:SS') as item_created_date,
	min(clt.loan_date) as first_loan_date,
	max(clt.loan_date) as last_loan_date,
	item.last_check_in__date_time as last_returned_date,
	cntt.name as call_number_type,
	(case when loc2.name is null then 0 else 1 end)::boolean as in_temporary_location,
	mtt.name as material_type,
	ins.discovery_suppress as instance_suppressed,
	iti.identifiers__value as oclc_control_number,
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
	left join circulation.loan__t clt on item.id = clt.item_id
	left join inventory.item__t__notes note on item.id = note.id
	left join inventory.item_note_type__t nt on note.notes__item_note_type_id = nt.id
	left join inventory.instance__t__identifiers iti on iti.id = ins.id 
	inner join inventory.identifier_type__t itt on iti.identifiers__identifier_type_id = itt.id and itt.name = 'OCLC'
	left join inventory.call_number_type__t cntt on cntt.id = holding.call_number_type_id 
	left join inventory.material_type__t mtt on item.material_type_id = mtt.id
	left join inventory.item__t__circulation_notes itcn on item.id = itcn.id
where 
	loc.code = 'MLEIF'
group by 
	item.barcode,
	ins.title,
	item.status__name,
	item.metadata__created_date,
	item.last_check_in__date_time,
	cntt.name,
	in_temporary_location,
	mtt.name,
	ins.discovery_suppress,
	iti.identifiers__value,
	ins.id,
	holding.id,
	item.id,
	loc.name;