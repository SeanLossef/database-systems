# Design Theory for Relational Databases (continued)

## Projecting Functional Dependencies

We also need to be able to answer the following:
- Given a relation R with FDs S, if we project R: R1 = π L (R) for some list of attributes L, What functional dependencies hold in R1?

We compute the Projection of Functional Dependencies, which is the set of FDs:
- follow from S
- contain only attributes of R1

We can simply S first by removing redundancies. But in general the complexity of the process is exponential based on the number of attributes in R1. 

**Algorithm: Projecting Functional Dependencies**

Input: 
- Relations R and R1 = π L (R)
- Set of FDs S that hold in R

Output:
- Set of FDs that hold in R1

1. Let T = {}, the eventual output
2. For each set of attributes X that is a subset of the attributes of R1, compute X+ with respect to S
    - Add to T all nontrivial FDs X -> A, such that A is in both X+ and R1
3. Now T is a basis for the FDs in R1, but it may not be minimal
    - If there is a FD F in T that follows from the other FDs in T, remove F from T
    - Let Y -> B be a FD in T with at least two attributes in Y, let Z -> B be Y -> B with one attribute removed
        - If Z->B follows from the FDs in T, remove Y->B and replace it with Z->B
    - Repeat until no further changes can be made

Example:

R(a, b, c, d), a->b, b->c c->d

R1 = π acd (R)

T = {a->c, c->d}

a+ = abcd
c+ = cd
d+ = d
ac (ignore)
ad (ignore)
cd+ = cd

# Design of Relational Database Schema

*Anomalies* are problems, such as redundancy, that arise when we try to put too much into a single relation. 

3 main types of anomalies:
1. Redundancy: Information may be repeated in multiple tuples
2. Update Anomalies: we may change the information in one tuple, but leave the same information unchanged in another
3. Deletion Anomalies: if a set of values becomes empty; we may lose other information as a side-effect

Example

Class(name, semester, location, time, capacity, student, major, professor, textbook)

## Decomposing Relations

We eliminate anomalies by *decomposing* relations: splitting them into smaller relations

Given a relation R(a1, a2, ..., an)

We decompose R into two relations: S(b1, b2, ..., bm) and T(c1, c2, ..., ck) such that
1. {a1, a2, ..., an} = {b1, b2, ..., bm) ∪ {c1, c2, ..., ck}
2. S = π b1, b2, ..., bm (R)
3. T = π c1, c2, ..., ck (R)

Class(name, semester, location, time, capacity, student, major, professor, textbook)

becomes

Course(name, semester, location, time, capacity, professor, textbook) and
Enroll(student, name, semester)

It's not quite that simple. We need to be able to reconstruct the original relation. 

## Boyce Codd Normal Form (BCNF)

A condition under which the anomalies above can be guaranteed not to exist

A relation R is in BCNF if and only if whenever there is a non-trivial FD A->B for R, it is the case that A is a superkey of R

Or: the left side of every FD of R is a superkey

### Decomposing into BCNF

By repeatedly choosing suitable decompositions, we can break any relation schema into a collection of subsets of its attributes with the following properties:
- The subsets are all in BCNF 
- The data in original relation is faithfully represented by the data in the relations that are the result of the decomposition. 

The strategy is to look for a non-trivial FD A->B that violates BCNF

We optionally add to the right side as many attributes as are determined by A

Then we break R into two subsets:
- R1 = A ∪ B
- R2 = A ∪ everything else that's not B

**BCNF Decomposition Algorithm**

Input: A relation R with its functional dependencies S

Output: a decomposition of R into relations, each of which is in BCNF

1. Check if R is in BCNF
    - If yes, return {R}
2. Let X->Y be a FD that violates BCNF
    - Compute X+
    - Choose X+ as R1
    - Choose X and all attributes not in X+ as R2
    - Compute the projection of Functional Dependencies for R1 and R2
    - Recursively decompose R1 and R2 using the algorithm. 


Example: 

R(abcde) ab->c, de->c, b->d
keys: abe

{ab}+ = {abcd}

R1 = abcd
T = {b->d, ab->c, c->d}
a+ = a
b+ = bd
c+ = c
d+ = d
ab+ = abcd
ac+ = ac
ad+ = ad
bc+ = bcd
bd+ = bd
cd+ = cd
bcd+ = bcd

R11 = bd
T = {b -> d}

R12 = bac
T = {ab->c}

R2 = abe
T {}
a+ = a
b+ = b
e+ = e
ab+ = abcd
be+ = be
ae+ = ae

R11 = bd
R12 = abc
R2 = abe


## Properties we want a decomposition to have

1. Elimination of anomalies
2. Recoverability of information
3. Preservation of dependencies
    - When we reconstruct the original relation, will the original FDs be satisfied

BCNF gives us 1 and 2
(Nothing gives us all three)

Note that any two-attribute relation is in BCNF 

So why not break relations down into multiple 2-attribute relations?

We need to be able to reconstruct the original information. If our decomposition allows us to do that, we say it provides a *lossless join*.

Does our algorithm provide for a lossless join?

Example: R(ABC) B->C

Decompose to R1(BC) and R2(BA)

Let t be a tuple of R: t = (a, b, c)

When we decompose, t becomes (b, c) and (b, a) 

When we do a natural join, these tuples will join, restoring the original data (a, b, c)

Is that enough? No. We need to know that we're not creating any new data with our join

t = (a, b, c) and v = (d, b, e)

When we decompose t and v, we get u = (a, b), and w = (b, e), which join to x = (a, b, e)

Is x in the original relation?

Remember that B -> C, therefore if two tuples share a value for B, they also share a value for C

Therefore, since b = b, c = e

Therefore, x = (a, b, c), which was in the original relation

This argument works generally. We assumed A, B, and C were single attributes, but they could have been sets of attributes. 

### The Chase Test for Lossless Join

Consider a more general situation

We decompose R into sets of attributes, S1, S2, ..., Sk

We have a set of FDs F that hold in R

Is it true that if we project R onto the relations of the decomposition, then we can recover R by taking a natural join?

Does S1 ⨝ S2 ⨝ ... ⨝ Sk = R ?

Three things to remember:
1. Natural Join is associative and commutative: order doesn't matter
2. Any tuple t in R is in: π S1 (R) ⨝ π S2 (R) ⨝ ... ⨝ π SK (R)
    - A projection of t onto Si is π Si (R), which is in the join 
3. Therefore π S1 (R) ⨝ π S2 (R) ⨝ ... ⨝ π SK (R), when the FDs in F hold, if every tuple in the join is also in R 

The *Chase Test* for a lossless join is a way to check if a tuple t in π S1 (R) ⨝ π S2 (R) ⨝ ... ⨝ π SK (R) can be proved using the FDs in F, to be a tuple in R

If t is in the join, then there must a tuple in R: (t1, t2, ..., tk) such that t is the join of the projections of each ti onto the attributes of Si for i=1, 2, ..., k

We know that ti agrees with t for the values in the attributes of si, but it has unknown values for the attributes not in i

We draw a picture of what we know, called a *tableau*

Assume R has attributes A, B, C, ... and we use values a, b, c, for the components of t

Example:

R(A, B, C, D) FDs A->B, B->C, CD -> A

s1 = AD, s2 = AC, s3= BCD

Tableau is

``` 
A   B   C   D
a   b1  c1  d
a   b2  c   d2
a3  b   c   d

Apply A->B therefore b1=b2
A   B   C   D
a   b1  c1  d
a   b1  c   d2
a3  b   c   d

Apply B->C therefore c1 = c
A   B   C   D
a   b1  c   d
a   b1  c   d2
a3  b   c   d

Apply CD->A, therefore a = a3
a   b1  c   d
a   b1  c   d2
a   b   c   d


```

Assume (a, b, c, d) was in R.


## Dependency Preservation

It might not always be possible to decompose a relation into BCNF such that we provide for a lossless join and preserve all the original dependencies

Assume R(A, B, C), B->C, AC->B
Keys: AC, AB
B->C violates BCNF, so we decompose:
BC and AB

now we lose the AC->B

``` 
B   C
b1  c1
b2  c1

B   A
b1  a1
b2  a1

When we join:

A   B   C
a1  b1  c1
a1  b2  c1

```


## Third Normal Form (3NF)

The solution to the problem illustrated above is to relax the BCNF requirement slightly in situations where a dependency cannot be preserved

The relaxed condition is called 3NF

A relation is in 3NF whenever for any non-trivial FD A->B either
- A is a superkey or
- every member of B is a member of some key (each member of B is "prime")

We can decompose a relation R into a set of relations such that:
- The relations are all in 3NF
- The decomposition has a lossless join
- The decomposition preserves dependencies

**Algorithm for decomposing into 3NF**

Input: a relation R and a set of FDs F that hold in R

Output: a decomposition of R into a set of relations, each of which if in 3NF, such that the decomposition has a lossless join and preserves dependencies

1. Find a minimal basis for F, called G
2. For each FD X->A in G, use XA as the schema of one of the decomposed relations
3. If none of the relation schemas from (2) is a superkey for R, add an additional relation whose schema is a key for R

Example: R(a, b, c, d, e) ab->c, c->b, a->d
keys: abe, ace

Check if it's a minimal basis:

Compute the closure of the left side of each FD, using the other two
- If the closure contains the right side, the FD wasn't necessary and the basis isn't minimal

Then provde that we can't drop any elements from the left side of a FD
Example: ab->c
    - Compute the closure of b, and the closure of a. If either closure contains c, we can use the simplified FD

Therefore F is minimal.

One decomposed relation for each FD in F

R1 = a, b, c
R2 = c, b (subset of R1: we can drop it)
R3 = a, d
R4 = a, b, e (or a, c, e)

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
