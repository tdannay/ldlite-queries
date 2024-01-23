--This query returns a list of books a the "MH New Books" location, sorted by receipt date and in call number order.
--Created by Tim Dannay on 2023-01-17

--I had to adjust the query to account for the 5-hour time zone difference between our time and FOLIO’s GMT. 
--In the future, if FOLIO or LDLite starts to automatically adjust for the time zone difference, this query will need to be updated accordingly.
--To do this, remove "- interval '5 hours'" from the last line of the SELECT statement and the first ORDER BY statement.

with
  parameters AS (
    SELECT
      '{Number of Results}'::int AS number_of_results --To run in DBeaver, replace "{Number of Results}" with the desired number.
  )
select 
	item_barcode, title, call_number, item_status, effective_location, permanent_location, instance_uuid, item_uuid, holding_uuid, item_received_date
from
	(select distinct
		item.barcode as item_barcode,
		ins.title,
		holding.call_number_prefix, 
		replace(concat_ws(' ', holding.call_number_prefix, holding.call_number, holding.call_number_suffix), chr(10), '') as call_number, --concatenates the call number with the prefix/suffix
		itcn.effective_shelving_order as effective_shelving_order,
		item.status__name as item_status,
		loc.name as effective_location,
		loc2.name as permanent_location,
		ins.id as instance_uuid,
		item.id as item_uuid,
		holding.id as holding_uuid,
		to_char(to_timestamp(plt.receipt_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours', 'YYYY-MM-DD"T"HH24:MI:SS') as item_received_date
	from 
		inventory.instance__t ins 
		inner join inventory.holdings_record__t holding on ins.id = holding.instance_id 
		inner join inventory.item__t item on holding.id = item.holdings_record_id 
		inner join inventory.location__t loc on loc.id = item.effective_location_id
		inner join inventory.location__t loc2 on loc2.id = holding.permanent_location_id
		inner join orders.po_line__t plt on item.purchase_order_line_identifier = plt.id
		inner join inventory.item__t__circulation_notes itcn on item.id = itcn.id
	where
		loc.name = 'MH New Books'
	order by
		to_char(to_timestamp(plt.receipt_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours', 'YYYY-MM-DD"T"HH24:MI:SS') --order by receipt date
	limit 
		(select 
			number_of_results 
		 from 
		 	parameters)) q
order by q.call_number_prefix desc, q.effective_shelving_order; --Can remove "desc" so that it puts the records with a 'Folio' prefix in the call number at the top instead of the bottom
