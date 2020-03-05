# Secondary Storage Management

Database systems always involve secondary storage to store large amounts of data over time 

## Memory Hierarchy

Multiple components for data storage
- Amount of data stored varies over 7 (or more) orders of magnitude
- Cost per byte varies over 3 (or more) orders of magnitude
- Speed of access varies over 7 orders of magnitude

**Cache**: on-board cache of memory (on the chip itself)
- Sometimes there's a level-2 cache on another chip

**Main Memory**: RAM 

All of the operations we consider a computer doing (in this class) work on information at this level

Transfer to cache takes 10-100 nanoseconds 

**Secondary Storage**: Disk 

Often (still) a spinning magnetic disk (increasingly is a solid state drive)

Time to transfer to memory is around 10 msec. 

Large amounts of data can be transferred at a time, so speed of transfer is complex

**Tertiary Storage**: magnetic tape, optical drives

Large retrieval times

Much longer persistence, and lower cost per byte. 

### transfer between levels

Data moves between adjacent levels

Data on disk is organized into *blocks*. Blocks generally 4-64 kb.

Entire blocks are transferred at once, to or from a contiguous section of memory called a *buffer*. 

An implication is that we can improve performance if data that is accessed is on the same block other data that is needed at the same time. 

### Volatile vs Non-volatile storage

Volatile storage "forgets" what is stored when the power is shut off.

Much of the complexity of a DBMS comes from the fact that a change can't be considered final until it's written to non-volatile storage. 

### Virtual Memory

A system to increase the size of memory address space beyond what's physically available in RAM 

It's a feature of operating systems and is not typically applicable to a DBMS

## Disks

For the purposes of this class, we'll focus on spinning magnetic disks, not solid state drives.

Magnetic disks are still used for databases, though it's becoming less common. 

Some of the principles surrounding the organization of data on magnetic disks may apply at a more macro level to databases that are more broadly distributed

A magnetic disk consists of a *disk assembly* and a *head assembly*.

The disk assembly consists of one or more circular platters that rotate around a central spindle. 

Upper and lower surfaces of each platter are covered in a magnetic material on which bits are stored. 

The disk is organized into *tracks*, which are concentric circles of a platter

The tracks at a given distance from the center, across all the surfaces form a *cylinder*. Density of data is greater along a track than radially. 

Tracks are separated into *sectors* by gaps in the magnetic material. A sector is an indivisible unit, as far as reading and writing are concerned. 

Blocks are logical units of data and are stored on one or more sectors. 

The head assembly holds the disk heads, one head for each surface.

The head reads (or writes) the data as the disk spins beneath it.

The head assembly moves as a single unit. 

#### Disk Controller

Disk drives are controlled by a disk controller, a small processor capable of:
1. Controlling the activator to move the head assembly
2. Selecting a sector from all those in a given cylinder. 
3. Transferring bits between the desired sector and main memory
4. Buffering a track or more, in local memory, anticipating its use 

### Disk Access Characteristics

Accessing a disk block requires 3 steps, each with an associated delay:
1. Disk controller moves the head to the right cylinder: seek time
2. Controller waits until the right sector moves under the head: rotational latency
3. All sectors (and gaps) pass under the head: transfer time

The sum of seek time, rotational latency, and transfer time equal the latency of the drive 

Seek time is usually between 0 and 10 msec

Rotational Latency is between 0 and 10 msec (average around 5msec)

Transfer times are usually sub-msec range

Typical latency averages around 10 msec.

Disk latency isn't the only delay

If there's more than one disk, requests may have to wait, and *scheduling latency* becomes an issue 

In the worst case, requests arrive faster than they can be filled, and scheduling latency becomes infinite

There are things we can do to improve throughput (the number of disk accesses per second)
- Place blocks that are accessed together on the same cylinder, reducing seek time 
- Divide data among multiple smaller disks instead of one large one
- "Mirror" a disk, so we can access multiple blocks simultaneously
- Use disk scheduling algorithm to adjust the order in which requests are filled 
- Pre-fetch blocks into main memory 

### I/O Model of Computation

We assume one processor, one disk controller, and one disk, and the database is too large to fit in main memory

The time taken to perform a disk access is much larger than the time spent manipulating data in main memory. The number of block accesses is a good approximation of the time needed by an algorithm

**Organizing data into cylinders**:

Seek time represents about half of disk latency

We can store data likely to be accessed togteher, we can ignore seek time for all but the first block 

If blocks are stored on consecutive sectors, rotational latency can also be ignored. 

#### Using multiple disks**

We can improve performance by replacing one large disk with multiple smaller disks: it gives us multiple independent heads.

Note that there's no change in access time for a single request 

**Striping** can speed up access to objects that occupy a large number of blocks. 

[1]()

**Mirroring** disks involves making identical copies of the data and spreading them over multiple disks.

Helps with resiliency (always have a backup)

For n disks, read time improves by a factor on n 

Write time is not improved (as we still have to write to each disk)

#### Disk Scheduling

We don't have to fill requests in the order in which they are received

Elevator algorithms: If a disk head is passing cylinders it knows contain data that must be read, it can do the read then 

#### Pre-fetching/Buffering

(Sometimes called double-buffering)

Some applications allow us to anticipate what data will needed next. We can pre-fetch that data, allowing for better scheduling. 

## Disk Failures

Forms of Disk Failures:
- Intermittent failure
    - An attempt to read or write a sector is unsuccessful, but subsequent attempts succeed
- Media Decay
    - It becomes impossible to read or write a sector, regardless of how many attempts are made 
- Write failure
    - an attempt to write fails, but the previous data can't be retrieved. 
    - often caused by a loss of power 
- Disk crash
    - Entire becomes unusuable, suddenly and permanently 


### Checksums

An approach used to detect failure

Each sector has some bits that are set depending on the value of the other bits in the sector

It's not perfect, but if we use enough bits for the checksum, the probability of missing a failure is low enough 

The simplest form of checksum is the *parity bit*.

If there are an odd number of 1's in a sector, we say that it has odd parity, and add a 1 parity bit.

If there are an even number of 1's in a sector, we say that it has even parity, and add a 0 parity bit

The number of 1's in a sector and its parity bit is always even

Examples:
``` 
Sector  Parity
--------------
1010    0
1011    1
0010    1
0011    0

```

A parity bit only detects 1 bit failures. 

Multiple bit failures, there's a 50% chance it goes undetected. 

We can use multiple parity bits for a sector

Example: 8 parity bits:
- First parity bit for the first bit in each byte of the sector
- Second parity bit for the second bit in each byte of the sector
- and so on

``` 
Data    0101
        0101
        1011
        1010

Parity  0001

```

A massive failure will likely be detected:

The chance it's missed is 1/2 for each bit (1/256 for 8 parity bits)

In general: 1 / 2^n for n parity bits

## Recovery from Disk Crashes

We use multiple disks to reduce to reduce the risk of data loss. The name for this kind of approach RAID: Redundant Arrays of Independent Disks

The idea is that some disks hold data (data disks). Others hold information determined by the data (redundant disks).

Because disks typically don't fail at the same time, we can use the redundant disks to re-create the data on a failed disk.

### RAID Level 1

The simplest is mirroring. It uses a completely redundant disk.

No data loss unless there's a second failure while the first failure is being repaired. 

RAID 1 is expensive (lots of redundant disks).

### RAID Level 4

RAID 4 uses only 1 redundant disk, regardless of how many data disks are used. 

Assume identical disks.

1 disk holds the parity bits for all the others

``` 

Disk1   Disk2   Disk3   Disk4
0101    1101    0101    1101
0110    1101    1011    0000
0011    0100    1000    1111

```

Reading data is the same as without RAID. 

Writing is more complicated, as the parity bits need to be updated as well. 

Naive approach would be to do the write, and then recalculate the parity

``` 

Disk1   Disk2   Disk3   Disk4
0101    1101    0101    1101
0110    0110    1011    1011
0011    0100    1000    1111

Update Disk 2.2
New Data 0110
```

Better approach is to take the modulo 2 sum of the old and new data, and change the parity bits where the sum is 1

``` 

Disk1   Disk2   Disk3   Disk4
0101    1101    0101    1101
0110    0110    1011    1011
0011    0100    1000    1111


Update Disk 2.2
New Data 0110
Old Data 1101
M2 Sum   1011
```

### RAID Level 5

RAID 4 is limited because every write requires an update to the redundant disk

RAID Level 5 spreads the parity blocks out over all the disks

``` 
Disk1   Disk2   Disk3   Disk4
xxxx    0101    1101    0101
0110    xxxx    0110    1011
0011    0100    xxxx    1000
0110    0101    1111    xxxx
xxxx    0101    0111    1011

```

### RAID Level 6

Using error correcting codes called Hamming Codes, we can build systems that can recover from multiple disk failures.

Basics:
``` 
Disk    1   2   3   4 | 5   6   7
        --------------+----------
        1   1   1   0 | 1   0   0
        1   1   0   1 | 0   1   0
        1   0   1   1 | 0   0   1

```

## Arranging Data on Disk 

A data element like a tuple is represented by a record, which is stored in consecutive bytes on disk. 

Collections such as relations are usually stored by placing the records representing their data in one or more blocks. 

Generally a block holds only tuples from one relation (though there are exceptions)

### Fixed-Length Records

Simplest record consists of fixed-length fields, one for each attribute of the represented tuple

In many cases, the system allows more efficient reads/writes when the data begins at an address that's a multiple of 4 or 8. Space not used by a previous field is wasted.

Each record often begins with a header, which might include:
- A pointer to the schema 
- The length of the record
- Timestamps about the last access or update
- Pointers to the fields (this can be a substitute for the schema)

[2]()

Records are stored in Blocks.

There's also a block header:
- Links to one ore more other blocks (as it would for an index structure)
- Information about the role played by the block 
- Information about the relation to which the block's tuples/records belong
- A "directory" giving the offset of each record in the block 
- Timestamp data

### Representing Block and Record Addresses

In memory, a block's address is the memory address of its first byte; a record's address is the address of its first byte

It's different on disk. An address might include Disk ID, cylinder number, etc. A record's address is the block address plus some offset

### Client-server system addresses

We'll think of Main Memory as a client system

The server system manages secondary storage 

Server record addresses:
- Physical address (host, disk, cylinder, track, etc.)
- Logical address: arbitrary string of bytes 

System maintains a map table between logical and physical addresses. Note that physical addresses may be long 

Indirection allows flexibility. As we move records around, we only update their physical location in one place. 

### Pointer Swizzling

Often, pointers are part of records. It's not common for records representing tuples. Very common for objects, usually necessary for index structures

When records are in secondary storage, we use its "database address" (the logical address known by the secondary storage system).

When the record is in main memory, we have the option to use either the memory address or the database address.
- Generally more efficient to use the memory address when possible, because we can just follow the pointer. When we use a database address, it must be translated to a memory address.

We try to avoid the cost of repeatedly translating database addresses by using *pointer swizzling*

Basic idea: when we move a block from secondary storage to main memory, its pointers may be "swizzled" (translated to memory addresses) 

Strategies for Swizzling:
- Automatic: done when the block is brought into memory
- On-demand: leave pointers unswizzled intially. If we end up following a pointer, we swizzle it then. 
- No swizzling
- Programmer Control: there may be cases where an application developer may know in advance if the pointers are likely to be followed. 

When we return blocks to disk, we need to unswizzle its pointers. 

A block in memory may be "pinned" if it can't be safely written back to disk at a given time. 

Pointer Swizzling is one reason blocks may become pinned. Assume Block B1 contains a swizzled pointer to B2. We can't move B2 back before we unswizzle the pointer in B1. 