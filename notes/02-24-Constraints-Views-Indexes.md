# SQL Constraints

Constraints (and Triggers) are both "active" elements: an expression or statement we write once and store in the database, expecting the element to execute at the appropriate time. 

A big problem faced when writing a database application is that new information can be wrong in a variety of ways. 

We could have our application code validate all input, but it's better to have the database do it

- Checks only need to be written once 
- Efficiency improvement 

SQL provides a variety of ways for expressing *integrity constraints* as part of a database schema. 

Constraints on attributes, tuples, relations, various events

## Keys and Foreign Keys

We've already discussed keys: `PRIMARY KEY`, `UNIQUE` 

Foreign keys express referential integrity constraints: they declare that values for certain attributes must make sense. 

The values for some set of attributes of each tuple of some relation R must exist in some tuple in some other relation S

When we declare some set of attributes a foreign key, we make two claims:
1. The referenced attributes of the second relation must be declared `PRIMARY KEY` or `UNIQUE` 
2. Values of the foreign key appearing in the first relation must also appear in the referenced attributes of some tuple in the second relation

Two ways to declare in the `CREATE TABLE` or `ALTER TABLE` statement:
- `attribute type REFERENCES table(attribute)`
- at the end: `FOREIGN KEY (attributes) REFERENCES table(attributes)`

Example:
```postgresql
DROP TABLE enroll;

CREATE TABLE enroll
(
    student_email VARCHAR(255) REFERENCES student(email) ON UPDATE CASCADE ON DELETE SET NULL,
    course_name   VARCHAR(255),
    semester      CHAR(3),
    registered    TIMESTAMP DEFAULT now(),
    FOREIGN KEY (course_name, semester) REFERENCES course(name, semester)
    ON UPDATE CASCADE
    ON DELETE CASCADE
)
;


```

### Maintaining Referential Integrity

Once we declare a foreign key, the DBMS will prevent the following:
1. `INSERT` of a new tuple whose values for the foreign key are not null or present in the referenced table
2. `UPDATE` the value to one that is not present in the referenced table
3. We try to delete the referenced tuple 
4. We try to update the referenced tuple


Can't do:
```postgresql
INSERT INTO enroll (student_email, course_name, semester)
VALUES ('email@example.com', 'American Literature', 'S20');

UPDATE enroll SET course_name='American Literature', semester='S20' WHERE course_name ilike 'data%';

DELETE FROM course WHERE name='Database Systems' AND semester='S20';

UPDATE course SET name='Advanced Database Systems course' WHERE name='Database Systems' AND semester='S20';


```

For the first two situations, there is no alternative but to reject the change. 

However, for the last two situations, there are three approaches that can be taken:
- Default policy: reject the change 
- Cascade policy: changes to the referenced attribute are mimicked at the foreign key
- Set-Null policy: changes are allowed. The referring values are set to NULL

#### Note on foreign keys and dangling tuples

Dangling tuples don't participate in a join. So dangling tuples are those that would violate the foreign key constraint.

### Deferred Checking of Constraints

Example: we want to add a constraint that every course has a professor, and that every professor must teach at least one course.

In case of circular constraints, we can designate a constraint as `DEFERRABLE` telling SQL to defer checking the constraint until the transaction commits

`... REFERENCES table(attributes) DEFERABLE INITIALLY DEFERED `

## Constraints on Attributes and Tuples

In a `CREATE TABLE` statement, we can declare two kinds of constraints:
- Constraints on a single attribute
- Constraints on a tuple as a whole

Simples single-attribute constraint is `NOT NULL` 

### Check contraints

More complex constraints can be attached to an attribute definition using the `CHECK` keyword

`attribute type CHECK(condition)`

- Can refer to the attribute being checked or another attribute on the relation
- Other relations' attributes must be introduced as a subquery 
- Can be anything that would appear in a WHERE clause

We can add to the list of attribute, key, etc. definitions: `CHECK(condition)` of a CREATE TABLE statement

```postgresql
CREATE TABLE enroll(
    student_email VARCHAR(255) CONSTRAINT not_ideal_check CHECK(student_email IN (SELECT email FROM student))
);

ALTER TABLE course ADD CHECK (capacity > 0) ;
```

Note that attribute and tuple-based checks are only done when tuples are inserted into or updated in the relation where the check is defined.  

We use triggers or assertions if more integrity is needed.

## Modifying Constraints

Constraints have names: `attribute type CONSTRAINT name PRIMARY KEY `

If we don't define one, SQL creates one

Once they're name, we can modify:

`ALTER TABLE enroll DROP CONSTRAINT not_ideal_check`

## Assertions

An assertion is a boolean value expression that must be true at all times 

Postgres doesn't support assertions

# Views

Relations defined by `CREATE TABLE` statements actually exist in the database. (Physically stored somewhere on disk)

Another type of relation in SQL (virtual) View.

Views do not exist physically
- Defined by an expression (like a query)
- Can be queried as if they existed
    - Sometimes can be modified/updated 

## Declaring Views

Simplest form: `CREATE VIEW name AS query`

Example: all database students:
```postgresql
CREATE VIEW database_students AS
SELECT email, major, name
FROM student, enroll
WHERE email = student_email
AND course_name ilike '%database%'
;


SELECT * FROM database_students;
```

Note the distinction between Relation, Table, and View:
- Both Table and View are relations 
- However, the distinction between them matters both for performance and capability

## Querying views

A view may be queried exactly as if it were a stored table

```postgresql
INSERT INTO enroll(student_email, course_name, semester) 
VALUES('alice@example.com', 'Operating Systems', 'S20');

SELECT * 
FROM enroll, database_students
WHERE email = student_email;
```

**Renaming attributes**: we can specify a different set of attribute names if we want to

`CREATE VIEW myView(a1, a2) AS SELECT b1, b2 FROM ...`

## Modifying/Updating views

Simplest modification is to drop the view: `DROP VIEW name`
- Note the difference between this and `DROP TABLE name` 

Consider:
`INSERT INTO database_students(email, major, name) VALUES('g@example.com', 'ARCH', 'george');`

In may cases, the answer is, we can't do that

A subset of views (updatable views) are simple enough that modification of the view can be translated into updates of actual tuples

When are modifications to a view permitted?

Generally, modifications are permitted on a view that is defined on some attributes of a relation R using a SELECT (not SELECT DISTINCT) statement when:
- The WHERE clause must not involve R in a subquery 
- The FROM clause involves a single instance of R and no other relation
- The list of attributes in the SELECT clause must include enough attributes that for every other attribute, we can fill in using default values and NULL

```postgresql
CREATE VIEW database_courses AS
SELECT name, semester
FROM course
WHERE name ilike '%data%';
```

In this case, an insertion into the view can be applied directly to the underlying relation (similar to an INSERT where not all of the values are specified)

```postgresql
INSERT INTO database_courses(name, semester) VALUES ('Modern Databases', 'F20');

INSERT INTO course(name, semester) VALUES ('Modern Databases', 'F20');

SELECT * FROM database_courses;
SELECT * FROM course;

INSERT INTO database_courses(name, semester) VALUES('English Literature', 'F20');

DELETE FROM database_courses WHERE name='Modern Databases' AND semester='F20';

DELETE FROM course WHERE name='Modern Databases' AND semester='F20' AND name ilike '%data%';

UPDATE database_courses SET name='Ultra Modern Databases' WHERE name = 'Modern Databases' AND semester='F20';
UPDATE course SET name='Ultra Modern Databases' WHERE name = 'Modern Databases' AND semester='F20' AND name ilike '%data%'
```

DELETEs are similar to INSERTS: the statement is passed through to the underlying relation. However, the WHERE clause from the view definition is appended, to make sure that only tuples that were visible in the view are deleted

## Materialized Views

A view describes how a new relation may be constructed from existing base tables 

If a view is used frequently enough, it may be efficient to *materialize* it: to store it all times. As with indexes, there's a cost associated with maintaining it. 

`CREATE MATERIALIZED VIEW name(columns) AS query`

Postgres provides other options, including whether or not the view should be materialized when the statement is run. 

We can configure the view to update itself periodically rather than on every change

# Indexes in SQL

Consider the query `SELECT * FROM course WHERE name='x' AND semester='S20'`

An *index* on an attribute A of a relation is a data structure that makes it easy to find all tuples with a fixed value for A

We could think of an index as a binary search tree of key-value pairs, where the attribute A is the key, and the value is the location of tuples containing A. 

The ky for an index may be any attribute. It doesn't have to be a key for the relation. 

Or consider: 
```postgresql
SELECT * 
FROM course, enroll
WHERE name = course_name AND course.semester = enroll.semester;
```

We indexes we conly need to consider the appropriate tuples from each relation. Otherwise, we'd have to consider the whole cross-product 

## Declaring indexes

Creation of indexes is implementation-specific 

`CREATE INDEX name ON table(columns) [TYPE]`

We can specify more than one column. But the order of the columns matters. You want to put the more used attribute first (generally) 

`DROP INDEX name`

## Selection of Indexes

Creation of indexes involves a tradeoff:

An index will greatly speed up queries involving the key attributes, my improve joins involving those attributes as well

However every index slows down INSERT, UPDATE, and DELETE statements, as the index must be continually maintained 

### Useful indexes:

Often most useful index involves the key for a relation
- Queries involving a specific value for the key are common: the index will be used often
- There is at most one tuple for a given key, so either 0 or 1 page (disk) needs to be retrieved 

When an index is not on the key, there are two situations where it is commonly effective:
1. If the attribute(s) is almost a key: there are relatively few tuples with any given value 
2. If the tuples are "clustered" on that attribute. We "cluster" a relation on an attribute by grouping the tuples that share a value for that attibute into as few pages as possible. 

