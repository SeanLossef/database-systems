SELECT title, isbn, name FROM book
LEFT JOIN checkout ON checkout.barcode = book.barcode
LEFT JOIN patron ON checkout.card_number = patron.card_number
AND checkout.branch = patron.branch
ORDER BY title ASC, name DESC;