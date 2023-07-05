--This query is intended to help find mismatches between an inventory record and its attached order record.
--Created by Tim Dannay, 2023-06-07
select
	it.id as "Instance UUID",
	it.hrid as "Instance HRID",
	hrt.id as "Holdings UUID",
	hrt.hrid as "Holdings HRID",
	it2.id as "Item UUID",
	it2.hrid as "Item HRID",
	plt.po_line_number,
	plt.title_or_package as "Order Title",
	it.title as "Instance Title",
	concat(ut.personal__first_name, ' ', ut.personal__last_name) as "Ins Last Updated By",
	it.metadata__updated_date as "Ins Date of Last Update",
	pot.order_type,
	it2.barcode,
	lt.name as "Holding Effective Location",
	mtt.name as "Item Material Type"
from 
	inventory.instance__t it 
	left join inventory.holdings_record__t hrt on it.id = hrt.instance_id 
	left join inventory.item__t it2 on it2.holdings_record_id = hrt.id
	left join orders.po_line__t plt on plt.instance_id = it.id
	left join orders.purchase_order__t pot on plt.purchase_order_id = pot.id
	left join users.users__t ut on it.metadata__updated_by_user_id = ut.id
	left join inventory.location__t lt on lt.id = hrt.effective_location_id
	left join inventory.material_type__t mtt on mtt.id = it2.material_type_id 
where 
	position('MH' in plt.po_line_number) = '1' --ensures just MH POLs
	and (position('3102035' in it2.barcode) = '1' OR (it2.barcode like '%MH' and not it2.barcode like '%AMH')) --ensures just MH items
	and pot.order_type = 'One-Time' --or 'Ongoing' for the serials query
	and plt.title_or_package != it.title; --remove this line to get the full list of MHC items with POLs, instead of just those with mismatched titles between the instance/order.