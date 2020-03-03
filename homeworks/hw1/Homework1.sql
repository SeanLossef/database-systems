CREATE TABLE conferences (
	name VARCHAR(255),
	location VARCHAR(255),
	start_date DATE,
	end_date DATE,
	cost NUMERIC(6,2),
	PRIMARY KEY (name, location, start_date)
);

CREATE TABLE people (
	name VARCHAR(255),
	birthday DATE,
	email VARCHAR(255),
	job_title VARCHAR(255),
	employer VARCHAR(127),
	PRIMARY KEY (email),
	UNIQUE (name, birthday)
);

CREATE TABLE registration (
	conference_name VARCHAR(255),
	location VARCHAR(255),
	start_date DATE,
	attendee_email VARCHAR(255)
);

CREATE TABLE sponsors (
	name VARCHAR(255),
	conference_name VARCHAR(255),
	location VARCHAR(255),
	start_date DATE,
	amount NUMERIC(9,2),
	PRIMARY KEY (conference_name, location, start_date)
);