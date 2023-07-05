--This query returns a list of student employees with the number of hours they worked in the time period given in the parameters
--Created by Tim Dannay on 2022-10-19

--These parameters make the LDLite Query App display fields that the user can enter for start/end date, which determine the date range applied to the query.

with
  parameters AS ( 
    SELECT
      '{Start Date (YYYY-MM-DD)}':: VARCHAR AS start_date, --To run this query in DBeaver, replace the section in quotes with the desired start date in YYYY-MM-DD format.
      '{End Date (YYYY-MM-DD)}':: VARCHAR AS end_date --To run this query in DBeaver, replace the section in quotes with the desired end date in YYYY-MM-DD format.
  )

--I had to adjust the query to account for the 5-hour time zone difference between our time and FOLIO’s GMT. 
--In the future, if FOLIO or LDLite starts to automatically adjust for the time zone difference, this query will need to be updated accordingly.
--To do this, remove "- interval '5 hours'" from the first two lines of the SELECT statement.

SELECT 
	to_char(to_timestamp(circulation.loan__t.loan_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours','YYYY-MM-DD"T"HH24:MI:SS') as loan_date, 
	to_char(to_timestamp(circulation.loan__t.return_date, 'YYYY-MM-DD"T"HH24:MI:SS"+0000"') - interval '5 hours','YYYY-MM-DD"T"HH24:MI:SS') as return_date, 
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
and loan_date >= (select start_date from parameters)
and loan_date < (select end_date from parameters)
order by last_name, first_name, loan_date, item_barcode;