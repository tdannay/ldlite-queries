--This query returns information about records whose holdings call number contains a line break, so that those fields can be cleaned up.
--Created by Tim Dannay on 2023-01-19

select
	ins.title,
	replace(holding.call_number, chr(10), ''),
	item.barcode as item_barcode,
	ins.id as instance_uuid,
	holding.hrid as holding_hrid
from
	inventory.instance__t ins 
	inner join inventory.holdings_record__t holding on ins.id = holding.instance_id 
	inner join inventory.item__t item on holding.id = item.holdings_record_id
where
	holding.call_number like '%'||chr(10)||'%'
