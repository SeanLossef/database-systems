# SQL

We saw part of SQL back in chapter 2: that focused on the Data Definition Language part of it.

SQL also supports Querying and Modifying the data: "Data Manipulation Language"

## Simple Queries in SQL

Most basic queries ask for tuples of some relation that satisfy a basic condition

`SELECT * FROM relation WHERE condition`

`FROM` clause specifies to the relation

`WHERE` clause clause defines a condition (similar to the selection operator)

`SELECT` clause specifies which attributes (similar to projection operator)

Useful when examining a query to start with the FROM clause, then look at the WHERE clause, and finally the SELECT

```postgresql
SELECT * 
FROM course 
WHERE semester='S20';
```

### Projection in SQL 

We use the SELECT keyword to accomplish projection

Use `*` or define a list of attributes

Note that this includes the extended projection operator

- `SELECT x as y` 
- `SELECT 'constant'`
- `SELECT 'string' || 'concatenation'`

```postgresql
SELECT '1' || '2' as x ;
```

### Selection in SQL

The selection operator is available via the WHERE clause

Six comparison operators: `= <> < > <= >=`

Values are constants and attributes from the relations mentioned in the FROM clause

Arithmetic operators: `+ - * / ()`

String concatenation: `||`

Result of a comparison is a boolean `TRUE` or `FALSE` (or `UNKNOWN`)

Can combine with `AND` `OR`, and `NOT` 

Strings are compared and matched exactly 

Padding (from fixed length fields) is ignored

Comparison `< >`  is done using lexicographic order 

#### Pattern Matching in SQL

Exact matches for strings are pretty limited 

SQL allows for Pattern Matching

`s LIKE P` where s is a string, and P is a pattern

`%` wildcard matches any number of characters (like .* in regular expressions)
`_` wildcard matches any single character (like . in regex)

`s NOT LIKE P` does the inverse

#### Escape Characters

How do we match the character `%` or `_` in our string?

There's no escape character like \ in c or python

We can choose any character as the escape:

`s LIKE 'xx%%xx%' ESCAPE 'xx'`

`xx%abc%`
`%abc%`

```postgresql


SELECT * 
FROM course 
WHERE name NOT ILIKE '%data%'
;

```

#### Dates and Times

`DATE'YYYY-MM-DD'` is the standard date format 

`TIME'HH:MM:SS.sss'` is the standard time format

Optionally add a timezone after the time `-X:XX`

We can combine date and time to form a timestamp (or datetime)

Some implementations use `DATETIME` instead, and the `TIMESTAMP` fields are auto-updated to `now()` when their tuple is updated

Postgres also has `INTERVAL` type for comparison

### NULL values in SQL

There are many reasons to support the concept of NULL
- SQL outer joins produce null values
- Certain INSERT operations produce null values

- Value unknown (birthday)
- Value inapplicable (spouse for a single person)
- Value withheld (unlisted phone number/credit card data)

Two important rules to remember when operating on potentially NULL values:
- When we operate on a NULL using arithmetic operators, the result is NULL
- When we compare a NULL to any other value (including another NULL), the result is `UNKNOWN`

NULL may appear as a value, but we can't operate on it as such

To check for NULL: `x IS NULL` or `x IS NOT NULL` (`x=NULL` will not do what you think)

#### Truth values of UNKNOWN 

Helpful to think of:
- TRUE = 1
- UNKNOWN = 1/2
- FALSE = 0

`AND` of any two values is the minimum

`OR` of any two values is the maximum

`NOT` of any value is `1 - value` 

### Ordering Output

We can specify `ORDER BY <attributes>` to sort the output

Defaults to `ASC` (ascending order), but we can use `DESC`

```postgresql
SELECT *
FROM course
ORDER BY semester DESC, location;
```

The sorting is done after the `FROM` and `WHERE`, before the SELECT

That means that all attributes are available for use in ordering, not just attributes in the SELECT

We can also specify expressions, not just attributes


## Queries involving more than one relation

Much of the power of relational algebra comes from being able to combine two or more relations.

We can do the same in SQL

### Products and Joins

The simplest is the list multiple relations in the FROM clause

Effectively gives us the Cartesian product

The WHERE clause gives us a theta-join

```postgresql
SELECT name, course.semester, student_email
FROM course, enroll
WHERE course.name=enroll.course_name
AND course.semester = enroll.semester
;

```

#### Disambiguating attributes

As with relational algebra, we prepend the relation name and a dot to disambiguate

### Tuple Variables

Sometimes we want to use the same relation multiple times in the FROM clause 

We disambiguate by using a "tuple variable"

Each use of R in the FROM clause is followed by a variable name that will be used to reference that instance elsewhere in the query

Example: students with the same major

```postgresql
SELECT *
FROM student s1, student s2
WHERE s1.major = s2.major 
AND s1.email <> s2.email;

```


```postgresql
SELECT name, c.semester, student_email
FROM course c, enroll e
WHERE c.name=e.course_name
AND c.semester = e.semester
;

```

## Interpreting multi-relation queries

There are a few ways we can think of the select-from-where expressions 

First is Nested Loops: each tuple variable loops over the entire relation

Multiple relations give nested loops:

``` 
for tuple c in course
    for tuple e in enroll
        if where clause
            print (c, e)
```

Another is Parallel Assignment: rather than nested loops, we consider, in parallel, all possibles values from the tuple variables, and evaulate the WHERE for each 

Conversion to Relational Algebra:

Start with relations from the tuple variables, take cartesian product, and apply the where clause

Assume relations R, S, and T 

We want to find R ∩ (S ∪ T)

In SQL: `SELECT R.a FROM R, S, T WHERE R.a = S.a OR R.a = T.a`

Consider what happens if T is empty?

Nested Loops: 

``` 
for tuple r in R
    for tuple s in S
        for tuple t in T
            if r.a = s.a OR r.a = t.a
                print (r.a)

```

Parallel assignment: no assigment is possible, because there's nothing in T

Relational algebra: σ R.a = S.a OR R.a = T.a (R×S×T)

## Joins in SQL

SQL supports a number of variants on the JOIN operator: products, natural joins, theta joins, outer joins

More conventional theta-join is: 

``` 
SELECT *
FROM R JOIN S ON (condition)

```

There are also OUTER, LEFT, RIGHT variants

``` 
SELECT *
FROM R LEFT JOIN S ON (condition)

```

## Data Modification

So far, we've considered SQL statements that return tuples

There are others that allow modification of the data

### Insertion

The basic form is `INSERT INTO relation(attributes) VALUES (values)`

```postgresql
INSERT INTO course(name, semester, time, location, capacity)  
VALUES ('Advanced Databases', 'F20', 't8-10', 'DCC 337', 50);

```

The list of attributes is technically optional 

```postgresql
INSERT INTO course
VALUES ('Remedial Databases', 'F20', 't8-10', 'DCC 337', 50);

```

If we don't specify values for all attributes, the default will be used 

### Updates

`UPDATE relation SET attribute=value WHERE condition`

```postgresql
UPDATE course 
SET location = 'DCC-337'
WHERE name = 'Remedial Databases';
```

### Deletion

`DELETE FROM relation WHERE condition`

−
∪
∩
σ
π
×
⨝
θ
ρ
⊆
∅
