# SQL (continued)

## Set Operations

`UNION`, `INTERSECT`, `EXCEPT`

The two select statements must produce the same number of attributes and the corresponding datatypes must be compatible 

``` 
(SELECT a, b FROM r)
UNION
(SELECT a, b FROM s);

```

Postgres also allows `UNION ALL` (intersection and except as well), which doesn't remove duplicates. (Considerably faster)

## Subqueries

A query can be used in various ways to help in the evaluation of another (called a subquery)

Set operations are one example

There are others:
1. Subquery that returns a single constant, which can be compared with another constant in the WHERE clause
2. Subquery that returns a relation, that can be used in various ways in the WHERE clause
3. Subqueries can appear in the FROM clause, followed by a tuple variable 

### Subqueries that produce scalar values

An atomic value that can appear as one component of a tuple is called a *scalar*

A SELECT-FROM-WHERE query can produce any number of attributes

We often only care about one attribute

Using keys, we can limit the result to a single tuple 

We can use that kind of query, surrounded by parentheses, as if it were a constant/scalar value

Example: write a query to find all students who took a class last semester that's in the same room as database systems this semester:

```postgresql
SELECT student_email 
FROM enroll, course 
WHERE enroll.semester = course.semester
AND enroll.course_name = course.name
AND location = (SELECT location
                FROM course
                WHERE name = 'Database Systems'
                AND semester = 'F19');

```

### Subqeries involving relations

There are SQL operators we can apply to a relation R and produce a boolean result

R must be expressed as a subquery (`SELECT * FROM R` will stand for the whole relation)

1. `EXISTS R`: return true if R is not empty
2. `s IN R`: returns true if s is equal to one of the values in r
    - also `s NOT IN R`
3. `s > ALL R`: returns true if s is greater than all the values in r 
    - also have other comparison operators
4. `s > ANY R`: returns true if s is greater than any of the values in r
    - also have other comparison operators


```postgresql
SELECT student_email 
FROM enroll, course 
WHERE enroll.semester = course.semester
AND enroll.course_name = course.name
AND location IN (SELECT location
                FROM course
                WHERE name = 'Database Systems');


SELECT *
FROM course
WHERE capacity > ALL (SELECT capacity
                        FROM course
                        WHERE name = 'Database Systems');

```

### Conditions involving tuples

A tuple in SQL is represented as a parenthesized list of scalar values

If tuple t has the same number (and type) of components as the relation R, then we can compare t to R using the operators above

Example: find everyone taking a course in the DCC

```postgresql
SELECT student_email
FROM enroll
WHERE (course_name, semester) IN (
    SELECT name, semester 
    FROM course 
    WHERE location like 'DCC%'
);
```

Note that order of attributes is assumed

Many queries written with subqueries can be rewritten using multiple relations in the FROM clause

### Correlated Subqueries

In the simplest nested queries, the subquery is evaluated once, and the result is used in the containing query.

More complicated queries require the subquery to be evaluated once for each assignment of a value to some term that comes from a tuple variable outside the subquery

Example: We want to list all students who have failed an assignment

```postgresql
SELECT name 
FROM student 
WHERE .6 > ANY (
    SELECT grade 
    FROM grades
    WHERE student_email = email 
)
```

### Scoping Rules

In general, an attribute is assumed to come from a relation in the FROM clause

If none exists, look in the surrounding query and so on

We can force the surrounding query to be used by using a dot and the tuple variable

### Subqueries in the FROM clause

We can also use subqueries as relations in the FROM clause

Surround them with parentheses. We're required to specify a tuple variable

```postgresql
SELECT name
FROM student, (SELECT student_email FROM grades WHERE grade < .6) failing_students
WHERE student.email = student_email;
```

## Full Relation Operations 

Some operators act on full relations, rather than individual tuples 

### Duplicate Elimination

SQL doesn't remove duplicates by default 

Use `DISTINCT` keyword

`SELECT DISTINCT a, b, c FROM R WHERE ...`

Remember that duplicate elimination is a very expensive operation. Use it judiciously 

### Grouping and Aggregation

SQL supports the grouping operator from relational algebra

SQL supports the same five aggregator operators:
- SUM
- MIN
- MAX
- AVG
- COUNT

Usually apply them to scalar values, often an attribute in the SELECT clause

Exception is `COUNT(*)` which counts all the tuples in the relation generated by the FROM and WHERE clause 

We can eliminate duplicates in the column before the aggregation is done using the `DISTINCT` keyword

`SELECT COUNT(DISTINCT x)` will produce a count of the distinct values for attribute x 

Note `SELECT COUNT(X)` produces the same result as `SELECT COUNT(*)`, because the former will count duplicates 

For grouping, use the key words `GROUP BY <attributes>`

The list of attributes is only the grouping attributes 

The aggregated attributes appear in the SELECT clause

Only two kinds of attributes can appear in a SELECT clause once you have a `GROUP BY` clause:
1. Aggregations 
2. Attributes that appear in the `GROUP BY` list

There's no requirement to have both. We could just have aggregated attributes, or just grouping attributes

```postgresql
SELECT AVG(grade), course_name
FROM grades
GROUP BY course_name, semester 
```

We can have GROUP BY in a query involving multiple relations. The query is evaluated in this order:
1. Evaluate the relation R created by the FROM and WHERE clauses 
2. Group the tuples of R according to the attributes in the GROUP BY list
3. Produce the result specified in the SELECT clause as if R were a stored relation relation 


```postgresql
SELECT AVG(grades), student_email
FROM grades, student 
WHERE grades.student_email = student.email 
GROUP BY student_email
```

#### Handling NULLS

- The "value" NULL is ignored in any aggregation, including `COUNT(a)` (`COUNT(*)` will still count all the tuples in the relation)
- `NULL` is treated as an ordinary value when it comes to building groups 
- When we perform any aggregation exception count over an empty bag, the result is NULL
    - The count of an empty bag is 0

### `HAVING` clauses

What if we don't want to include every tuple in our grouping result?

One option is to restrict which tuples are included using the WHERE clause 

But sometimes we want to limit which groups appear based on the result of some aggregation 

Example: build a list of students with an average grade above 90%

```postgresql
SELECT student_email 
FROM grades 
GROUP BY student_email
HAVING AVG(grade) > .9
```

We use `HAVING <condition`> to restrict which groups appear in the result

Several rules to remember:
- An aggregation in a HAVING clause applies only to the tuples in the group being tested
- Any attribute in a relation in the FROM clause may be aggregated in the HAVING clause, but only those attributes that appear in the GROUP BY list may appear unaggregated in the HAVING clause (same as the SELECT clause)

## One more note on INSERT

```postgresql
INSERT INTO course(name, semester, time, location, capacity)  
VALUES ('More Databases', 'F20', 'w8-10', 'DCC-337', 50);
```

We can use a subquery to insert more than one row at a time

```postgresql
INSERT INTO course(name, semester) VALUES ('Internet Security', 'F19');

INSERT INTO enroll(student_email, course_name, semester)
SELECT email, 'Internet Security', 'F19'
FROM student 
WHERE major = 'CSCI';

SELECT * FROM enroll;
```

# Transactions in SQL

So far, we've only considered one user modifying the database. In reality it's more complicated

SQL provides some tools to help deal with the common situation where multiple users are making changes concurrently, or where operations fail to fully execute

## Serializability

In many application (web applications, banking, reservations, etc.) we might need to support hundreds or thousands of operations per second.

It's possible that some of these operations will overlap on the same data.

Consider a course registration system:

We want to check the availability of a course, and register if there's space

```   
User A          User B
------          -------
Checks open
                Checks open 
Registers
                Registers 
                (problem)


```

SQL allows a database programmer to state that a certain set of commands must execute as if they were performed serially

This is commonly implemented by locking certain data elements, so that only one function can access them at a time

## Atomicity

It's possible for a crash or interruption to leave the database in an unacceptable state

Example: bank transfer

We want to send $100 from A to B

``` 
command         A           B
check A         $200        $50
deduct from A   $100        $50
----Failure Here -----
add to B        $100        $150
```

SQL provides us with a way to state that a set of commands should execute atomically (all or nothing)

## Transactions

SQL supports both with Transactions

A transaction is a collection of one or more SQL statements that must be executed Atomically

SQL also requires that, by default, transactions be executed in a serial manner 

When we use a generic SQL interface, each statement is in a transaction by itself 

Use the SQL command: `START TRANSACTION` (or `BEGIN` in postgres) to start a transaction

From there, there are two ways to end:
- `COMMIT` ends the transaction successfully: SQL makes its effects permanent
    - Prior to that, any changes are tentative and may or may not be visible to other transactions
- `ROLLBACK` aborts all the modifications made during the transaction

Note that in Postgres, if any statement throws an error, the transaction must be rolled back.  

### Read Only Transactions

Previous examples (registration and bank) required a read and a write

Difficult to parallelize 

If a transaction only reads data, we can parallelize 

Example: a query that checks the availability of a class without making changes 

If we can mark a transaction as Read Only, SQL can potentially leverage that information

`SET TRANSACTION READ ONLY` sets the next transaction to read only 

This must be done before the transaction begins

(In postgres, it's the opposite) 

`SET TRANSACTION READ WRITE` is the default

### Dirty Read

*Dirty Data* is the common term for data that has been written by a transaction that hasn't yet committed

A *dirty read* is a read of dirty data by another transaction

The risk in a dirty read is that the transaction that wrote it may abort 

Dirty reads avoid:
- Time consuming work of the DBMS needed to avoid them 
- Loss of parallelism that results from waiting 

We can indicate that dirty reads are acceptable:

`SET TRANSACTION READ WRITE SET ISOLATION LEVEL READ UNCOMMITTED`

Note that we still specify `READ WRITE` because otherwise setting the isolation level to `READ UNCOMMITTED` overrides the default and makes it `READ ONLY` 

Other isolation levels:
- `READ COMMITTED`
- `REPEATABLE READ`
- `SERIALIZABLE`

Postgres doesn't implement `READ UNCOMMITTED`

`READ COMMITTED` will execute each query using data that was committed before execution began. It can change if other transactions commit between executions

`REPEATABLE READ` will use a snapshot of the database the way it was before the statement execution began. It's possible that other transactions will add "phantom tuples" to the result between executions 

`SERIALIZABLE` will execute as if it were the only thing running