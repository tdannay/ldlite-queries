SELECT circulation.loan__t.loan_date as loan_date, 
circulation.loan__t.return_date as return_date, 
inventory.service_point__t.name as service_point, 
users.users__t.personal__first_name as first_name, 
users.users__t.personal__last_name as last_name, 
inventory.item__t.barcode as item_barcode, 
inventory.instance__t.title as title,
to_timestamp(circulation.loan__t.return_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - to_timestamp(circulation.loan__t.loan_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') as time_worked
FROM circulation.loan__t
inner join users.users__t on circulation.loan__t.user_id = users.users__t.id
inner join inventory.item__t on circulation.loan__t.item_id = inventory.item__t.id
inner join inventory.holdings_record__t on inventory.item__t.holdings_record_id = inventory.holdings_record__t.id
inner join inventory.instance__t on inventory.holdings_record__t.instance_id = inventory.instance__t.id
inner join inventory.service_point__t on circulation.loan__t.checkout_service_point_id  = inventory.service_point__t.id
where inventory.instance__t.title = 'MHC CIRCULATION Circulation Assistant.'
and loan_date >= '2022-09-01'
and loan_date < '2022-11-01' 
order by last_name, first_name, loan_date, item_barcode;
