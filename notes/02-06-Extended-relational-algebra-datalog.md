# More Relational Algebra

Start by applying relational algebra to *bags*, not just sets

Bags (multisets) are similar to sets but allow duplicates

Why bags?

Most commercial DBMS implement relations as bags rather than sets.

Some relational operators are considerably more efficient using the bag model (e.g., Union or Projection)

There are also some situations where a correct answer cannot be obtained using sets (e.g., average of a column)

## Operations on Bags

### Set operations

Suppose R and S are relations where tuple t appears n times in R, and m times in S

In bag union, t appears n+m times

In bag intersection, t appears min(n, m) times

In bag difference (R - S), t appears max(0, n-m) times.

### Projection of Bags

Project each tuple. Duplicates are allowed, so nothing else needs to be done

### Selection of Bags

Apply the selection criteria to each tuple independently. Duplicates are allowed, so nothing else needs to be done. (No difference from relations as sets)

### Joins of Bags

R ⨝ S

No surprises. We compare each tuple of R to each tuple of S, and if they join, we add them to the result. Duplicate tuples will each join

``` 
R(a, b)
1   2
1   3
1   3
2   3

S(b, c)
2   5
2   6
3   1

R ⨝ S
(a, b, c)
1   2   5
1   2   6
1   3   1
1   3   1
2   3   1

```

## Extended operators of Relational Algebra

Some additional operators, applicable to bags, commonly implemented by SQL

**Duplicate Elimination*  

![1]()

### Aggregation Operators

Operators that apply to sets/bags of numbers or strings. Used to "aggregate" the values in one column of a relation
- SUM
- AVG
- MIN
- MAX
- COUNT

Count isn't the number of distinct values, it's the number of elements 

### Grouping

We don't always want to aggregate an entire column. We need to consider a relation in groups, and then aggregate within the groups.

Grouping operator g L (R)

![1]()

L is a list of elements, each of which is either:
- An attribute of R
    - Called a grouping 
- An aggregation operator, applied to an attribute of R
    - Includes a new name for the result
    - Called an aggregated attribute

To construct g L (R):
1. Partition R into groups, where each group consists of tuples that agree on all of the grouping attributes
2. For each group, produce a single tuple that has:
    - The shared grouping attribute values for the group
    - Aggregrations, over the group, for the aggregated attributes

Note that duplicate elimination is a special case of grouping 

### Extended Projection operator

Previously π L (R), where L was a list of attributes

We extend it so that L can contain:
- Individual attributes of R
- Expressions X -> Y, where X and Y are names for attributes
- Expressions E -> Z, where 
    - E is an expression involving:
        - Attributes of R,
        - Constants
        - Arithmetic operators
        - String operators
    - Z is a name for the result of E

We compute the result by considering each tuple in turn.

Each tuple of R will produce one tuple in the result.

Duplicates in R are considered multiple times

The result can have duplicates even if R does not

![3]()

### Sorting operator 

We sort over a list of attributes A1, A2, ..., An

Sort by A1, ties are broken by A2, and so on 

![4]()

### Joins

Outer Joins: it's possible for tuples to be "dangling" (they didn't join with anything)

As dangling tuples aren't included in the result, the join may not have complete information

R Outer Join S starts with R ⨝ S, and adds all tuples that didn't join. Dangling tuples will be padded with NULL. 

```
R(a, b)
1   2
1   3
1   3
2   3
1   4

S(b, c)
2   5
2   6
3   1
5   7

R Outer Join S
a, b, c
1   2   5
1   2   6
1   3   1
1   3   1
2   3   1
1   4   N
N   5   7


```

There are also Left and Right Joins. Similar, but include dangling tuples from only one or the other relation

```
R(a, b)
1   2
1   3
1   3
2   3
1   4

S(b, c)
2   5
2   6
3   1
5   7

R Left Join S
a, b, c
1   2   5
1   2   6
1   3   1
1   3   1
2   3   1
1   4   N

R Right Join S
a, b, c
1   2   5
1   2   6
1   3   1
1   3   1
2   3   1
N   5   7
```

![5]()

All outer joins have a theta join equivalent.

Start with the join condition, add tuples that didn't join

# Logic for Relations

We can use logic to build queries, rather than relational algebra

Query language called Datalog, which consists of if-then rules
- Subset of Prolog
- Implementations in a number of other languages
- Declarative, not procedural 

Relations in Datalog are represented by *Predicates*

Each predicate takes a fixed number of arguments

A predicate followed by its arguments is called an *atom*

Think of a predicate as a function that returns a boolean value


### Relational Atom 

If relation R has n attributes in some order, we use R as the name of a predicate

R(a1, a2, ..., an) is TRUE if (a1, a2, ..., an) is a tuple in R 

Assume for now that the relations are sets

There are approaches to working with bags, but in general datalog deals with sets

``` 
R(a, b)
1   2
2   3

R(1, 2) -> True
R(2, 3) -> True
R(5, 6) -> False
R(x, y) -> False, for any other values of x and y

```

### Arithmetic Atoms

An arithmetic atom is a comparison between two arithmetic expressions (e.g., x < y))

Note that both atoms take as arguments the variables that appear, and return boolean values

Think of arithmetic atoms as relations that contain all true tuples

x < y contains all possible values (x, y) where the condition is true (x < y))

## Datalog Rules and Queries

A datalog rule consists of
1. A relational atom, called the *head*, followed by
2. the symbol <- often read as "if", followed by
3. A *body* consisting of one or more atoms, called *subgoals*, which may be either relational or arithmetic.
    - Subgoals are connected by AND or OR
    - May be preceded by NOT


Example: 

``` 
BigCourse(name, semester) <- Course(name, semester, location, time, capacity) AND capacity > 100
```

Two subgoals:
- `Course(name, semester, location, time, capacity)`
- `capacity > 100`

We can use any value for location and time

We can use `_` instead of naming every variable

``` 
 BigCourse(name, semester) <- Course(name, semester, _, _, capacity) AND capacity > 100
 ```

A query in Datalog is one or more rules

## Meaning of Datalog Rules

Imagine the variables of the rule ranging over all possible values

Whenever those values together make the subgoals true, we see what values are in *head*, and add that to our result set

There are some restrictions: we need the result to be a finite relation, and we want the arithmetic subgoals and negated relational goals to make intuitive sense

We apply a "safety condition"
- Every variable that appears anywhere in the rule must appear in some non-negated relational subgoal in the body


`Infinite(a, b) <- a > b AND a*2 < 5`
`SpecialCourse(name, semester) <- NOT Course(name, semester, _, _, _)`

`P(x, y) <- Q(x, z) AND NOT R(w, x, z) AND X < Y`

There's another way to think about the meaning of rules

Rather than considering every possible value, we consider every possible combination of sets of tuples existing in non-negated relational subgoals. 

If some assignment (combination) is consistent (it assigns the same values to each variable), then we look at what was assigned, and consider if it's true

``` 
R(a, b)
1   2
2   3
3   3

S(c, d)
2   2
4   5

P(x, y) <- R(x, y) AND S(y, z) AND x < y

x = 1, y = 2, y = 2, z = 2
P(1, 2) -> True

x = 1, y = 2, y = 4, z = 5

```

## Datalog with Bags

As long as there are no negated relational subgoals, we can apply datalog rules to bags as well

Conceptually similar to the second approach above

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
