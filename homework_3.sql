do $$
	declare
	result_row record;
	create_table_name varchar;
	is_company_type varchar;
	begin
		for result_row in (select distinct product_type, is_company from bid) loop
			is_company_type = case when result_row.is_company is true then 'company' else 'person' end;
			create_table_name := is_company_type || '_' || result_row.product_type;
			execute 'create table if not exists ' || create_table_name || ' (id serial primary key, 
																client_name varchar(50), 
																amount numeric(12, 2));';
			execute 'insert into ' || create_table_name || ' (client_name, amount) values (select client_name, amount from result_row)';
		end loop;
	end;
$$

