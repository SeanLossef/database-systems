# 1st Midterm

Thursday February 13 

4:00PM in DCC 318

Open book, open note

*No Electronics*

## Format

Combination 
- short answer: similar to homework questions, but more limited
- multiple choice
    - All multiple choice questions will be worth 3 points
    - -1 for wrong answer
    - 0 for blank answer

## Topics

1st five chapters of the textbook

### Overview of Database Systems

Diagram of the database system
- Know the different components and what they do

Purpose of a database

Why we use them

### Relational Model

Understand the relational model

- Schemas 
- Keys

#### Relational Algebra

Know the operators:
- Set Operators
- Operators that remove
    - Selection
    - Projection
- Operators that combine
    - Product
    - Joins

Be able to combine operations to create queries

Be able to apply a query to a relation to produce a result

Understand constraints, how they're defined and what they mean 

#### SQL DDL

`CREATE TABLE` statements

Be able to read them and understand what's going on
- data types
- attribute names
- constraints 

`ALTER TABLE` statements 

### Normalization

Understand Functional Dependencies

Closure of a set of attributes

Use FDs to determine keys

Projection of Functional Dependencies

Minimal Basis

``` 
R(a, b, c, d, e) bc->e, c->d, ab->e

R(a, b, c, d, e)  ca->e, ca->d

```

#### BCNF

Know the definition

Determine when a relation is in BCNF

Decompose into BCNF

Example

```
R(a, b, c, d, e) bc->e, c->d, ab->e
Keys: abc

R1=(b, c, d, e)
T={c->d, bc->e}
b+ = b
c+ = cd
d+ = d
e+ = e
bc+ = bcde
bd+ = bd
be+ = be
cd+ = cd
ce+ = ce
cde+ = cde

R11 = (c, d)
T = {c->d}


R12 = (c, b, e)
T = {bc->e}
c+ = cd
bc+ = bce


R2=(b, c, a)
T = {}
b+ = b
c+ = cd
a+ = a
ba+ = bae
bc+ = bce
ac+ = ac

R11(c, d) c->d
R12(c, b, e) bc->e
R2(b, c, a) 

Was AB->E preserved
(c, b1, e1)
(c2, b1, e2)

(b1, c, a)
(b1, c2, a)

(a, b1, c, e1)
(a, b1, c2, e2)


```

#### 3NF

Know the definition

Determine when a relation is in 3NF

Decompose into 3NF

#### MVDs

Understand what they are

Determine when a relation is 4NF

### E/R Diagrams

Understand what the symbols mean 

(you won't have to draw)

Understand how to convert to a relational schema

### Relational Algebra applied to Bags

Know how the different operators apply to bags

Additional operators:
- extended projection
- grouping/aggregation
- outer joins

#### Datalog

Understand the overall concepts 
- Build rules
    - Head
    - `<-`
    - Body
        - Atoms (relational, arithmetic)