CREATE TABLE hotel (
	name VARCHAR(255),
	address VARCHAR(255),
	zip VARCHAR(5),
	discount INT,
	check_in DATE,
	check_out DATE,
	rooms INT,
	location VARCHAR(255),
	PRIMARY KEY (address, location)
);

CREATE TABLE sponsors (
	name VARCHAR(255),
	conference_name VARCHAR(255),
	location VARCHAR(255),
	start_date DATE,
	amount NUMERIC(9,2),
	swag_type VARCHAR(255),
	swag_amount INT,
	PRIMARY KEY (conference_name, location, start_date)
);

CREATE TABLE meal (
	type VARCHAR(255),
	meal_date DATE,
	cost NUMERIC(3,2),
	meat BIT,
	diet VARCHAR(255),
	PRIMARY KEY (type, meal_date)
);