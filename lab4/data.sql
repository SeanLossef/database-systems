INSERT INTO patron(card_number, branch, name, phone_number, email)
VALUES (256, 'Troy', 'Bill Smith', 5185551234, 'bsmith@example.com'),
	(562, 'Troy', 'Annie Rivera', 5185557384, 'ar@example.com');
	
INSERT INTO book(barcode, isbn, title, author)
VALUES (5837239683, '978-0618640157', 'The Lord of the Rings', 'J. R. R. Tolkien'),
	(234, '0131873253', 'Database Systems: The Complete Book', 'Hector Garcia-Molina'),
	(488329, '978-1608872770', 'Ender''s Game', 'Orson Scott Card');
	
INSERT INTO checkout(barcode, card_number, branch, checkout_time, due_date)
VALUES (5837239683, 562, 'Troy', '2020-02-15 14:35 EST', '2020-03-14'),
	(5837239683, 256, 'Troy', '2019-12-01 10:01 EST', '2019-12-29'),
	(234, 256, 'Troy', '2004-04-02 9:37 EST', '2004-04-30');