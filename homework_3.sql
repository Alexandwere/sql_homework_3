do $$
	declare
		result_row record;
		create_table_name varchar;
		is_company_type varchar;
	begin
		for result_row in (
			select distinct product_type, is_company 
			from bid
			)
		loop
			continue when result_row.product_type is null or result_row.is_company is null;
			is_company_type = case
				when result_row.is_company is true 
					then 'company' 
					else 'person' 
				end;
			create_table_name := concat(is_company_type, '_', result_row.product_type);
			execute concat('create table if not exists ', create_table_name, 
				' (id serial primary key, client_name varchar(50), amount numeric(12, 2));');
			execute concat('insert into ', create_table_name, ' (client_name, amount) ',
				' select client_name, amount 
				from bid 
				where bid.product_type = $1 and bid.is_company = $2;')
				using result_row.product_type, result_row.is_company;
		end loop;
	end;
$$


do $$
	declare
		result_row record;
		base_rate numeric := 0.1;
		create_table_name varchar := 'credit_percent';
		
	begin
		execute 'create table if not exists ' || create_table_name || ' (client_name varchar, amount numeric);';
		execute concat('insert into ', create_table_name, ' (client_name, amount) ',
			'select client_name, (amount * $1 / 365)
			from company_credit
			union all
			select client_name, (amount * ($1 + 0.05) / 365)
			from person_credit') using base_rate;
		raise notice 'Общая сумма: %', (select sum(amount) from credit_percent);
	end;
$$


select * from credit_percent;
create view bid_company as (
	select *
	from bid
	where is_company is true
)
