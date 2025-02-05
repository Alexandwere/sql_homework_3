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
			execute 'insert into ' || create_table_name || ' (client_name, amount) '
									|| ' select client_name, amount from bid where bid.product_type = $1 and bid.is_company = $2'  
									 using result_row.product_type, result_row.is_company;
		end loop;
	end;
$$

--Скрипт №2 - Начисление процентов по кредитам за день
--Создать скрипт, который:
--1. Создаст(если нет) таблицу credit_percent для начисления процентов по кредитам: имя клиента, сумма начисленных процентов
--2. Имеет переменную - базовая кредитная ставка со значением "0.1" 
--3. Возьмет значения из таблиц person_credit и company_credit и вставит их в credit_percent:
-- необходимо выбрать id клиента и (сумму кредита * базовую ставку) / 365 для компаний
-- необходимо выбрать id клиента и (сумму кредита * (базовую ставку + 0.05) / 365 для физ лиц
--4. Печатает на экран общую сумму начисленных процентов в таблице
insert into credit_percent (id, amount)
select * from company_credit join bid on company_credit.client_name = bid.client_name union bid join person_credit on person_credit.client_name = bid.client_name
select (select id from )

do $$
	declare
	result_row record;
	base_rate numeric := 0.1;
	create_table_name varchar := 'first_credit_percent';
		
	begin
		execute 'create table if not exists ' || create_table_name || ' (client_id int, client_name varchar, total_amount numeric);';

		create view amount_of_company as (
			select id, client_name, (select(cc.amount * 0.1 / 365) from company_credit cc) as amount 
			from company_credit
		);
		-- select* from amount_of_company;

		create view amount_of_person as (
			select id, client_name, (select(pc.amount * (0.1 + 0.05) / 365) from person_credit pc) as amount 
			from person_credit
		);
		-- select * from amount_of_person;
		for result_row in (select * from amount_of_company) loop
			execute 'insert into ' || create_table_name
									|| ' select id, client_name, amount from amount_of_company where id = $1;'  
									 using result_row.id;
		end loop;
		for result_row in (select * from amount_of_person) loop
			execute 'insert into ' || create_table_name
									|| ' select id, client_name, amount from amount_of_person where id = $1;'  
									 using result_row.id;
		end loop;
		
		create table credit_percent (client_name varchar, total_amount numeric);
		insert into credit_percent (client_name, total_amount)
		select bid.client_name, total_amount
		from first_credit_percent fcp join bid on fcp.client_name = bid.client_name;
	end;
$$

-- delete from credit_percent;
-- drop view  amount_of_person, amount_of_company;

select * from person_credit;
select * from company_credit;
select * from company_deposit;
select * from person_credit_card;
select * from credit_percent;
drop table credit_percent;

create view bid_company as (
	select *
	from bid
	where is_company is true
)
