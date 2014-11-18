etoile
======

*etoile* is a tool to transform a textual description of dependent task
set into a constraint programming model for partitioning and off-line
scheduling.

Prerequisites
-------------

*etoile* is written in OCaml and consequently requires an OCaml compiler
for building. The output is targets the constraint solver OPL.

Building
--------

*etoile* is built with `make`; `make opt` builds an optimized binary
`etoile.opt`.

Usage
-----

`etoile -cores $CORES -tilecores $TILECORES -mpbsize $MPBSIZE -cachesize $CACHESIZE -maxcont $MAXCONT $TASKSET.txt > $TASKSET.dat`
`oplrun opl.mod $TASKSET.dat`

For a description of the available options, use
`etoile -help