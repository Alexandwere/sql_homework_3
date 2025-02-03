create table bid (
	id serial primary key, 
	product_type varchar(50),
	client_name varchar(100),
	is_company boolean,
	amount numeric(12,2)
);

insert into bid (product_type, client_name, is_company, amount) values
('credit', 'Petrov Petr Petrovich', false, 1000000),
('credit', 'Coca cola', true, 100000000),
('deposit', 'Soho bank', true, 12000000),
('deposit', 'Kaspi bank', true, 18000000),
('deposit', 'Miksumov Anar Raxogly', false, 500000),
('debit_card', 'Miksumov Anar Raxogly', false, 0),
('credit_card', 'Kipu Masa Masa', false, 5000),
('credit_card', 'Popova Yana Andreevna', false, 25000),
('credit_card', 'Miksumov Anar Raxogly', false, 30000),
('debit_card', 'Saronova Olga Olegovna', false, 0);