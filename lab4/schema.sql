CREATE TABLE book (
	barcode BIGINT PRIMARY KEY,
	isbn VARCHAR(21),
	title VARCHAR(127),
	author VARCHAR(127)
);

CREATE TABLE patron (
	card_number INT,
	branch VARCHAR(63),
	name VARCHAR(127),
	phone_number BIGINT,
	email VARCHAR(255),
	PRIMARY KEY (card_number, branch)
);

CREATE TABLE checkout (
	barcode BIGINT,
	card_number INT,
	branch VARCHAR(63),
	checkout_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
	due_date DATE
);