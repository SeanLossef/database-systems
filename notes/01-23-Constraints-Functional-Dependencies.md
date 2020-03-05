# Relational Algebra (continued)

## Combining expressions to form queries

Example: Find an expression of relational algebra that produces a relation representing all of the classes in Spring 2020 that take place in classrooms with space for 50 or more students

Assumptions:

Course(name, semester, time, location, capacity)
Student(name, email, major)
Enroll(email, course_name, semester)
Classroom(location, capacity, av_capable)

![example](resources/01-23/photo.jpeg)

There might be multiple ways of achieving the same result. The query optimizer has to find the optimal one. 

There can be equivalences between operators. 

![example](resources/01-23/photo.jpeg)

## Constraints on Relations

Two ways to express constraints in relational algebra.

1. If R is an expression, then R = ∅ is a constraint that says that the value of R must be empty, or there are no tuples in R.
2. If R and S are expressions, then R ⊆ S is a constraint that says every tuple in R must also be in S. 

Ultimately both express the same concept:

R ⊆ S is the same as R − S = ∅
R = ∅ is the same as R ⊆ ∅

### Referential Integrity Constaints

A referential integrity constraint asserts that a value appearing in one context must also appear in another related context. 

In general, we can express this as 

![example](resources/01-23/photo.jpeg)

Note that this is often called a "Foreign Key Constraint."

We can use more than one attribute in our constraints. 

### Key Constraints

Key constraints can also be expressed this way. 

(name, semester) is the key for the Course relation

Therefore, if two tuples agree on both name and semester, they also agree on location. 

![example](resources/01-23/photo.jpeg)

### Additional Constraints

We can use this approach to express other constraints as well

Example: no course may be held in a classroom with insufficient space for the capacity of the course

![example](resources/01-23/photo.jpeg)

# Design Theory for Relational Databases

There are lots of approaches to designing a schema for a relational database in an application. 

It's common for the initial attempt to have room for improvement, especially by eliminating redundancy. Problems are often caused by trying to fit too much into one relation. 

There's a well-developed theory for relational databases, "dependencies" their implications for what makes a good relational database schema, and what can be done about potential flaws. 

## Functional Dependencies

We start by looking at the constraints that apply to a relation. The most common is the "functional dependency," which generalizes the idea of a key for a relation. 

A Functional Dependency is a statement of the form that:
- If two tuples of R agree on some set attributes a1, a2, ..., an, then they must also agree on some other set of attributes b1, b2, ..., bm

We write this as a1, a2, ..., an -> b1, b2, ..., bm

We say that the As *functionally determine* the Bs.

The As and Bs may appear anywhere in the schema: there's no requirement that the As appear first. 

If we can be sure that every instance of R will be one where the FD is true, then we say that R *satisfies* the FD.

Remember that we are asserting a constraint on R, not just making a descriptive observation. 

It's common, though not a requirement, for the right hand side of a FD to be a single attribute

a1, a2, ..., an -> b1

a1, a2, ..., an -> b2

a1, a2, ..., an -> bm

Example:

Course(name, semester, location, time, capacity, student, major, professor, textbook)

What are some Functional Dependencies:
- semester, location, time -> name, capacity, professor, textbook
- professor, name -> textbook
- student -> major
- name, semester -> professor 
- professor, time, semester -> location
- professor, time, semester -> capacity
- professor, time, semester -> name

## Keys of Relations

We say that a set of attributes X is a *key* for a relation R if:
1. The set of attributes functionally determine all other attributes 
2. No proper subset functionally determines all other attributes (the key must be minimal)

Example: Keys for the above Course relation:
- professor, time, semester, student
- name, semester, student 
- time, location, semester, student

A relation may have more than one key. It's common to designate one "primary key" but it has no meaning in relational theory. 

A set of attributes that contains a key is called a *superkey*. 

Every key is a superkey, but not every superkey is a key (it might not minimal).

Other texts may refer to a key as a *candidate key* and a superkey as just *key*

## Rules about Functional Dependencies

We can reason about FDs.

Assume R(a, b, c) and a -> b, and b -> c.

Does R satisfy a -> c

We need to show that two tuples that agree in a also agree in c

Assume the existence of two tuples (a1, b1, c1) and (a1, b2, c2)

Since they agree on a, they also agree on b, therefore b1 = b2

(a1, b1, c1) and (a1, b1, c2)

Since we now know that they agree on b, they must also agree on c, therefore c1 = c2

Therefore R satisfies a -> c.

FDs can be presented in a variety of different ways without changing the set of legal instances of the relation

- Two sets of FDs S and T are *equivalent* if the set of relation instances satisfying S is exactly the same as the set satisfying T
- A set of FDs S *follows* from a set T if every instance that satisfies T also satisfies S
- Two sets of FDs S and T are equivalent if S follows from T and T follows from S

### Splitting/Combining Rule

a1, a2, ..., an -> b1, b2, ..., bm

is the same as

a1, a2, ..., an -> b1

a1, a2, ..., an -> b2

a1, a2, ..., an -> ...

a1, a2, ..., an -> bm

We can split the attributes of the right hand side.

We can do the reverse as well, combining FDs that have the same left side. 

No splitting left side

### Trivial FDs

A constraint of any kind is said to be *trivial* if it holds true for every instance the relation, regardless of what other constraints are assumed.

It's easy to determine for FDs:

a1, a2, ..., an -> b1, b2, ..., bm is trivial when
{b1, b2, ..., bm} ⊆ {a1, a2, ..., an}

A trivial FD has a right side that is is a subset of its left side

ab -> a

#### Trivial Dependency Rule

The FD a1, a2, ..., an -> b1, b2, ..., bm is equivalent of

a1, a2, ..., an -> c1, c2, ..., ck where the c's are all those b's that are not also a's.

Example:

abcdef -> bcghi is equivalent to abcdef -> ghi

### Computing the closure of attributes

Suppose {a1, a2, ..., an} is a set of attributes and S is a set of FDs.

The *closure* of {a1, a2, ..., an} under S is the set of attributes B such that every relation that satisfies all the FDs in S also satisifies {a1, a2, ..., an} -> B

We compute the closure by starting with the set of attributes and "pushing out" by adding the right hand side of FDs in S as soon as we've added their left hand side.

We denote this as {a1, a2, ..., an}+

**Algorithm**: Closure of a set of attributes

Input: a set of attributes A and FDs S

Output the closure of A+

1. If necessary, split the FDs in S so that each has a single attribute on its right hand side
2. Let X be the set of attributes that will eventually become the closure.
    - Initialize X to be A 
3. Repeatedly search for some FD B -> C, such that B ⊆ X, but C is not. 
    - Add C to X, and repeat
    - When nothing more can be added to X, stop

Example: 

R(abcde), ab->c, bc->ad (bc -> a, bc->d), d->e

Compute {ab}+

X = {abcde}

Example 2:

R(abcdefg), cd->e, c->f, g->abc (g->a, g->b, g->c), b->c

Compute {fg}+

{fgbca}

By computing the closure of a set of attributes, we can determine whether any given FD A->B follows from S

Compute A+. If B is in A+, then A->B follows from S.

#### Closures and Keys

If A+ contains all of the attributes for a relation, then A is a superkey for that relation

We can test if A is a key by first checking that A+ contains all attributes of the relation, and then checking that no subset of A has a closure that contains all attributes of a relation.

### Closing sets of Functional Dependencies

For a given set of FDs S, any set of FDs that's equivalent to S is called a *basis*.

A *minimal basis* for a relation is a basis B that satisfies three conditions:
1. All the FDs in B have a singleton right side
2. If any FD is removed from B, the result is not longer a basis
3. If for any FD in B we remove one or more elements from its left side, the result is no longer a basis

*No trivial FD can be part of a minimal basis, as it would be removed by (2)*

*Armstrong's Axioms* are used to derive any FD that follows from a given set of FDs

- Reflexivity: if B ⊆ A, then A -> B (trivial dependencies)
- Augmentation: if A -> B, then AC -> BC, for any set of attributes C. 
    - Since some C's may be A's or B's, we should remove duplicates
- Transitivity: If A->B, and B->C, then A->C

We can compute the closure of a set of functional dependencies by repeated applications of Armstrong's Axioms'


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
