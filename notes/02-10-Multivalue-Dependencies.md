# Multivalue Dependencies

A *multivalue dependency* is an assertion that two sets of attributes are independent from each other.

Consider a relation: 

``` 
Professor(name, office, department, course, semester)
(Johnson    AE109       CSCI    DBMS            S20)
(Johnson    AE109       CSCI    DBMS            S19)
(Fox        Lally2x     CSCI    xInformatics    S20)
(Fox        Winslow3X   ITWS    xInformatics    S20)
(Fox        Lally2X     CSCI    xInformatics    S19)
(Fox        Winslow3X   ITWS    XInformatics    S19)

```

name ->-> office, department

name ->-> course, semester

Now there's redundancy, but it's still in BCNF

No FDs at all (if we assume that two professors could share a course)

Definition: A *multivalue dependency* (MVD) is a statement about some relation R that holds that if you fix the values for some set of attributes, then the values for a certain other set of attributes are independent of all other attributes of the relation.

A1, A2, ..., An ->-> B1, B2, ..., Bm holds for R if when we consider the tuples that have a particular set of values for the As, then the set of values we find in the Bs is independent of the values in the attributes that are not As or Bs

For each pair tuples t and u that agree on the As, we can find another tuple v that agrees:
1. With t and u on the As
2. With t on the Bs
3. With u on everything else that's not an A or B

Note that we can infer the existence of a fourth tuple w, that agrees with t and u on the As, with u on the Bs, and with t on everything else

## Reasoning about MVDs

### Trivial MVDs

A ->-> B is trivial when B ⊆ A 

### Transitive Rule

A ->-> B, and B->->C, then A->->C

Note that any Cs that are As must be deleted from the right side

### Splitting/Combining Rule

Does not apply as it does for FD

name ->-> office, department

name ->-> office (doesn't follow)

### FD promotion

If A->B, then A->->B

### Complementation Rule

If R satisfies A->->B, then R also satisfies A->->C, where C is all attributes that are not A or B

## Fourth Normal Form (4NF)

We can remove the redundant information in the example above if we use the MVDs for decomposition

4NF eliminates all non-trivial MVDs as well as all FDs that violate BCNF

A relation is in 4NF if for every non-trivial MVD A->->B, A is a superkey

Note that MVDs don't affect the definition of keys. Keys rely on FDs only.

### Decomposition into 4NF

**Algorithm**

Input: Relation R with a set of FDs and MVDs S

Output: A decomposition into subrelations, all in 4NF, which provide for a lossless join back into R

1. Find a violation A->->B, where A is not a superkey
    - Remember that every FD X->Y is also a MVD: X->->Y 
    - If there's no violation, return R
2. Break R into two schemas:
    - R1 is As and Bs
    - R2 is As and everything not Bs
3. Find the FDs and MVDs that hold in R1 and R2. Recursively decompose

Note that every relation in 4NF is also in BCNF, similar to BCNF and 3NF

### Chase Test applied to closure of attributes

We want to show that X->Y

Start with a tableau with two rows
- The rows agree on all attributes in X 
- The rows disagree on all other attributes 

Then we apply the FDs until we find agreement on all the attributes in Y

Example:

R(A, B, C, D, E, F)

AB->C, BC->AD, D->E, CF->B

Does AB->D

``` 
A   B   C   D   E   F
---------------------
a   b   c1  d1  e1  f1
a   b   c2  d2  e2  f2

AB->C, so c1 = c2

A   B   C   D   E   F
---------------------
a   b   c1  d1  e1  f1
a   b   c1  d2  e2  f2

BC->AD, so d1=d2


A   B   C   D   E   F
---------------------
a   b   c1  d1  e1  f1
a   b   c1  d1  e2  f2

now we have two tuples that agree on a and b, and also on d, so AB->D
```

### Apply the Chase test to MVDs

With MVDs, we don't prove equality.

X->->Y allows us to infer the existence of other tuples by swapping components of Y

To X->->Y start with two tuples, equal in all attributes of X, not equal in all else

Then apply FDs to equate symbols

Apply MVDs to swap values, adding new rows


R(A, B, C, D), A->B, B->->C

Does A->->C hold?

``` 
A   B   C   D
--------------
a   b1  c   d1
a   b   c2  d

Trying to prove that (a, b, c, d) exists in the relation

A->B, so b = b1

A   B   C   D
--------------
a   b   c   d1
a   b   c2  d

Apply B->->C

A   B   C   D
--------------
a   b   c   d1
a   b   c2  d
a   b   c2  d1
a   b   c   d
```

### Projecting MVDs

In the worst case, we test every possible FD and MVD of the decomposed relations

We can eliminate a few:
- We don't need to test the trivial FDs and MVDs
- Only look for FDs with singleton right sides 
- A FD whose left side doesn't contain the left side of an existing FD or MVD can't hold, because there's no way to start the chase

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
