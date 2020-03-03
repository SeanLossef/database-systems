SELECT email, title, due_date FROM checkout
JOIN book ON checkout.barcode = book.barcode
JOIN patron ON checkout.card_number = patron.card_number
AND checkout.branch = patron.branch
ORDER BY due_date DESC;