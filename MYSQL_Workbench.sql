USE coursework;

DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS copy;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS loan;
DROP VIEW IF EXISTS cmp_view;
DROP PROCEDURE IF EXISTS display_loan;
DROP TRIGGER IF EXISTS loanupdate;


CREATE TABLE book (
isbn CHAR (17) NOT NULL,
title VARCHAR (30) NOT NULL,
author VARCHAR(30) NOT NULL,
CONSTRAINT pri_book PRIMARY KEY (isbn),
CONSTRAINT uni_title UNIQUE (title));

CREATE TABLE copy (
code INT NOT NULL,
isbn CHAR(17) NOT NULL,
duration TINYINT NOT NULL,
CONSTRAINT pri_copy PRIMARY KEY (code),
CONSTRAINT for_copy FOREIGN KEY (isbn)
 REFERENCES book (isbn) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT Checking CHECK (duration IN (7, 14, 21)));
    


CREATE TABLE student(
no INT NOT NULL,
name VARCHAR(30) NOT NULL,
school CHAR(3) NOT NULL,
embargo BIT NOT NULL,
CONSTRAINT pri_student PRIMARY KEY (no) );

CREATE TABLE loan (
code INT NOT NULL,
no INT NOT NULL,
taken DATE NOT NULL,
due DATE NOT NULL,
loan_return DATE NULL,
CONSTRAINT pri_loan PRIMARY KEY (code, no , taken),
CONSTRAINT for1_loan FOREIGN KEY (code)
      REFERENCES copy (code) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT for2_loan FOREIGN KEY (no)
      REFERENCES student (no) ON UPDATE CASCADE ON DELETE CASCADE);

INSERT INTO book (isbn, title, author)
   VALUES ('111-2-33-444444-5', 'Pro JavaFX', 'Dave Smith');
INSERT INTO book (isbn, title, author)
   VALUES ('222-3-44-555555-6', 'Oracle Systems', 'Kate Roberts');
INSERT INTO book (isbn, title, author)
   VALUES ('333-4-55-666666-7', 'Expert jQuery', 'Mike Smith');
   
INSERT INTO copy (code, isbn, duration)
   VALUES (1011, '111-2-33-444444-5', 21);
INSERT INTO copy (code, isbn, duration)
   VALUES (1012, '111-2-33-444444-5', 14);
INSERT INTO copy (code, isbn, duration)
   VALUES (1013, '111-2-33-444444-5', 7);
INSERT INTO copy (code, isbn, duration)
   VALUES (2011, '222-3-44-555555-6', 21);
INSERT INTO copy (code, isbn, duration)
   VALUES (3011, '333-4-55-666666-7', 7);
INSERT INTO copy (code, isbn, duration)
   VALUES (3012, '333-4-55-666666-7', 14);

INSERT INTO student (no, name, school, embargo)
   VALUES (2001, 'Mike', 'CMP', 0);
INSERT INTO student (no, name, school, embargo)
   VALUES (2002, 'Andy', 'CMP', 1);
INSERT INTO student (no, name, school, embargo)
   VALUES (2003, 'Sarah', 'ENG', 0);
INSERT INTO student (no, name, school, embargo)
   VALUES (2004, 'Karen', 'ENG', 1);
INSERT INTO student (no, name, school, embargo)
   VALUES (2005, 'Lucy', 'BUE', 0);
   
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (1011, 2002, '2020.01.10' , '2020.01.31', '2020.01.31');
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (1011, 2002, '2020.02.05' , '2020.02.26', '2020.02.23');   
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (1011, 2003, '2020.05.10' , '2020.05.31',NULL); 
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (1013, 2003, '2019.03.02' , '2019.03.16', '2019.03.10'); 
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (1013, 2002, '2019.08.02' , '2019.08.16', '2019.08.16');
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (2011, 2004, '2018.02.01' , '2018.02.22', '2018.02.20');  
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (3011, 2002, '2020.07.03' , '2020.07.10',NULL);
INSERT iNTO loan (code, no, taken, due, loan_return)
   VALUES (3011, 2005, '2019.10.10' , '2019.10.17','2019.10.20');
   
CREATE VIEW cmp_student
AS 
  SELECT no, name, school, embargo
     FROM student
     WHERE school = 'CMP' 
     WITH CHECK OPTION;
     
UPDATE cmp_student SET school ='ENG';

DELIMITER $$
CREATE PROCEDURE display_loan (IN book_isbn CHAR(17), IN student_no INT)

BEGIN

DECLARE complete BOOLEAN DEFAULT FALSE;
DECLARE due, cursr DATE;
DECLARE durationOfCopy TINYINT;
DECLARE copyOfCode, loanTesting INT;
DECLARE stateOfEmbargo BIT;
DECLARE CopyOfCode Cursor For

SELECT code FROM copy WHERE isbn = book_isbn;
DECLARE CONTINUE HANDLER FOR NOT FOUND 
SET complete = TRUE;
        OPEN copyOfCode;
        SET stateOfEmbargo = (SELECT embargo 
							  FROM student 
                              WHERE no = studentno);
        copyOfCode : LOOP
        
        SELECT stateOfEmbargo;
        IF(stateOfEmbargo IS NULL) THEN SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'DOES NOT WORK';
        END IF;
        
        IF (loanTesting IS NULL) THEN 
        INSERT INTO loan
        (code, no, taken, due, loan_return)
        Values (copyOfCode, Student_no, cursr, due, NULL);
        
        END IF;
        CLOSE copyOfCode;
        END LOOP;
    END$$

    DELIMITER ;

    
    CREATE TABLE auditTrial (
    no INT NOT NULL,
    taken DATE NOT NULL,
    due DATE NOT NULL,
    loan_return DATE NULL);
    
    
      delimiter $$
        CREATE TRIGGER loanupdate AFTER UPDATE ON loan FOR EACH ROW 
        BEGIN
			IF(OLD,loan_return is NULL) AND (CURRENT_DATE() > OLD.due) 
            THEN INSERT INTO auditTrial (no, taken, due, loan_return)
            VALUES (NEW.no, NEW.taken, NEW.due, NEW.loan_return);
        END IF;  
	END$$
DELIMITER ;


SELECT isbn, title, author 
FROM book;

SELECT no,name,school
FROM student
ORDER BY school DESC;

SELECT isbn, title
FROM book 
WHERE author LIKE '%Smith%';


SELECT MAX(due) AS 'latest due date'
FROM loan;


SELECT no
FROM student
WHERE no = ( SELECT loan.no
			 FROM loan
             WHERE loan.due = (SELECT MAX(due)
	                          FROM loan));
             

SELECT name
FROM student
WHERE no = ( SELECT loan.no
			 FROM loan
             WHERE loan.due = (SELECT MAX(due)
	                          FROM loan));
              
              
SELECT no, code, due
FROM loan
WHERE (YEAR (taken) = YEAR (CURRENT_DATE()))
	   AND (loan_return IS NULL);


SELECT DISTINCT STDN.no, STDN.name, BK.isbn, BK.title
FROM copy CD INNER JOIN loan LN ON  LN.code = CD.code
    INNER JOIN student STDN ON LN.no = STDN.no
    INNER JOIN book BK ON CD.isbn = BK.isbn
WHERE CD.duration =7;
                              

             
SELECT student.no, student.name
FROM student INNER JOIN loan ON student.no = loan.no
WHERE loan.due = (SELECT MAX(due)
				   FROM loan);
                   

SELECT BK.title AS 'Book Title', COUNT(BK.title) AS frequency 
FROM book as BK INNER JOIN copy AS CD ON BK.isbn = CD.isbn
	            INNER JOIN loan AS LN ON CD.code = LN. code
GROUP BY BK.title;


SELECT BK.title AS 'Book Title', COUNT(BK.title) AS frequency 
FROM book as BK INNER JOIN copy AS CD ON BK.isbn = CD.isbn
	            INNER JOIN loan AS LN ON CD.code = LN. code
GROUP BY BK.title
     HAVING (COUNT(BK.title))> 2;
