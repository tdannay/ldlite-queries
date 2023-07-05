--This query returns a list of unique MHC Undergraduate users who have checked out at least one course reserve within the given date range.
--Created by Tim Dannay on 2023-04-07

--These parameters make the LDLite Query App display fields that the user can enter for start/end date, which determine the date range applied to the query.
with
	parameters as (
    	select
      	'{Start Date (YYYY-MM-DD)}':: VARCHAR AS start_date, --To run this query in DBeaver, replace the section in quotes with the desired start date in YYYY-MM-DD format.
      	'{End Date (YYYY-MM-DD)}':: VARCHAR AS end_date --To run this query in DBeaver, replace the section in quotes with the desired end date in YYYY-MM-DD format.
  	)
select 
	u.personal__last_name as last_name,
	u.personal__first_name as first_name,
	u.barcode as user_barcode,
	count(l.id) as reserve_loan_count
from
	users.users__t u
	inner join circulation.loan__t l on l.user_id = u.id 
	inner join inventory.item__t it on it.id = l.item_id
	inner join inventory.location__t loc on loc.id = l.item_effective_location_id_at_check_out
	inner join users.groups__t gt on l.patron_group_id_at_checkout = gt.id
where
	loc.name in ('MH Reserve', 'MH Pratt Reserve', 'MH LRC Reserve')
	and gt.group = 'Undergraduate'
	and u.personal__email LIKE '%mtholyoke.edu'
	and l.loan_date >= (select start_date from parameters)
	and l.loan_date < (select end_date from parameters)
group by 
	u.personal__last_name, 
	u.personal__first_name, 
	u.barcode
order by 
	u.personal__last_name;