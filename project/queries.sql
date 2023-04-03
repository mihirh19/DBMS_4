-- Active: 1676287457938@@127.0.0.1@5432@project


SELECT * FROM Librarian;

SELECT * FROM Author;

SELECT * FROM Books;

SELECT * FROM MEMBER;

SELECT * FROM MEMBERMOBILE;


SELECT * FROM REQUEST;


SELECT * FROM EMPLOYEEADD;


SELECT * FROM EMPLOYEEMOBILE;

SELECT * FROM PUBLISHER;

SELECT * FROM Library;



-- Select all columns from the members table where the mobile_no is between 5551111000 and 555111109:





SELECT * FROM membermobile WHERE mobile_no BETWEEN 5551111000 AND 5551111009;



SELECT book_name FROM books WHERE book_id IN (903, 907, 908);



SELECT ea.emp_name, l.Librarian_name
FROM employeeadd AS ea
         JOIN Librarian AS l ON ea.Librarian_id = l.Librarian_id;




SELECT book_name , status, emp_id FROM books;




SELECT p.publisher_name, COUNT(*) AS book_count
FROM books AS b
         JOIN publisher AS p ON b.publisher_code = p.publisher_code
GROUP BY p.publisher_name
ORDER BY book_count DESC;


SELECT b.book_name, a.author_name, p.publisher_name
FROM books b
         INNER JOIN author a ON b.author_code = a.author_code
         INNER JOIN publisher p ON b.publisher_code = p.publisher_code;


SELECT e.emp_name, m.mobile_no
FROM employeeadd e
         LEFT JOIN employeemobile m ON e.emp_id = m.emp_id;


SELECT p.publisher_name, b.book_name
FROM publisher p
         RIGHT JOIN books b ON p.publisher_code = b.publisher_code;


SELECT l.*
FROM librarian l
WHERE l.library_id in (
    SELECT b.library_id
    FROM books b
    WHERE b.status = 'available'
    GROUP BY b.library_id
    ORDER BY COUNT(*) DESC
    LIMIT 2
);


SELECT p.publisher_name, COUNT(*) AS num_books
FROM books b
         INNER JOIN publisher p ON b.publisher_code = p.publisher_code
GROUP BY p.publisher_name, p.publisher_code;




SELECT e.emp_name
FROM books b
INNER JOIN employeeadd e ON b.emp_id = e.emp_id
INNER JOIN library l ON b.library_id = l.library_id
WHERE l.library_name = 'Public Library';



    SELECT * FROM books WHERE book_name LIKE 'T%';






CREATE OR REPLACE FUNCTION insert_request()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO request (emp_id) VALUES (NEW.emp_id);
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER insert_request_trigger
    AFTER INSERT ON books
    FOR EACH ROW
    WHEN (NEW.status = 'not available')
EXECUTE FUNCTION insert_request();

insert into request(mem_id, emp_id) values (301,802);




CREATE OR REPLACE FUNCTION update_book_status()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE books SET status = 'not available' WHERE book_id = NEW.book_id;
    ELSE
        UPDATE books SET status = 'available' WHERE book_id = OLD.book_id;
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER update_book_status_trigger
    AFTER INSERT OR UPDATE ON request
    FOR EACH ROW
EXECUTE FUNCTION update_book_status();







CREATE OR REPLACE FUNCTION display_employees() RETURNS VOID
AS $$
DECLARE
    emp_record employeeadd%ROWTYPE;
    emp_cursor CURSOR FOR SELECT * FROM employeeadd;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO emp_record;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Employee ID: %, Name: %', emp_record.emp_id,
            emp_record.emp_name;
    END LOOP;
    CLOSE emp_cursor;
END;
$$ LANGUAGE plpgsql;
SELECT display_employees();


CREATE OR REPLACE FUNCTION validate_mobile_number()
    RETURNS TRIGGER AS $$
DECLARE
    mobile_length INTEGER;
BEGIN
    mobile_length := length(NEW.mobile_no);
    IF (mobile_length != 10) THEN
        RAISE EXCEPTION 'Mobile number must have 10 digits';
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER validate_mobile_number_trigger
    BEFORE INSERT OR UPDATE ON membermobile
    FOR EACH ROW
EXECUTE FUNCTION validate_mobile_number();




CREATE OR REPLACE FUNCTION get_members_who_issued_books() RETURNS TABLE (member_name VARCHAR) AS $$
DECLARE
    member_cursor CURSOR FOR SELECT f_name FROM member WHERE mem_id IN (SELECT emp_id FROM books WHERE status = 'issued');
    member_name member.f_name%TYPE;
BEGIN
    OPEN member_cursor;
    LOOP
        FETCH member_cursor INTO member_name;
        EXIT WHEN NOT FOUND;
        RETURN NEXT ROW (member_name);
    END LOOP;
    CLOSE member_cursor;
END;
$$
    LANGUAGE plpgsql;

SELECT * FROM get_members_who_issued_books();




CREATE VIEW available_books AS
SELECT book_name, author_name, publisher_name, library_name
FROM books
         INNER JOIN author ON books.author_code = author.author_code
         INNER JOIN publisher ON books.publisher_code = publisher.publisher_code
         INNER JOIN library ON books.library_id = library.library_id
WHERE status = 'available';

select * from  available_books;
