using CP;

include "oplcommon.mod";

dvar int p[t in Tasks] in Cores;
dvar interval s[j in Jobs]
     in JobProps[j].release..JobProps[j].deadline
     size TaskProps[JobProps[j].task].WCET;

// Compute number of cores
// dexpr int n_cores = max(t in Tasks) p[t];
dexpr int n_cores = sum(q in Cores) (max(t in Tasks) (p[t] == q));

// Buffers are placed at the destination (or the source)
dexpr int m[b in Bufs] = (p[BufProps[b].dst] - 1) div (nbCores div nbTiles) + 1;

// The source and destination tasks may access a buffer
dexpr int x[q in Tiles][r in Cores] = maxl(0, max(b in Bufs) ((m[b] == q) && (p[BufProps[b].src] == r || p[BufProps[b].dst] == r)));

// Compute contention
dexpr int n_cont = maxl(minCont, max(q in Tiles) sum(r in Cores) x[q][r]);

execute {
  cp.param.Workers = 1;
  cp.param.TimeLimit = 900;
  var f = cp.factory;
  var phase1 = f.searchPhase(p);
  cp.setSearchPhases(phase1);
}

int level = 1;

// minimize n_cores;

constraints {
  // Jobs start after their predecessors have finished
  forall (<src,dst> in Deps) {
    if (level > 0) {
      endBeforeStart(s[src], s[dst]);
    }
  }

  // Bound the utilization on each core
  forall (q in Cores) {
    // sum (t in Tasks) (p[t] == q) * (TaskProps[t].WCET / TaskProps[t].period) <= 1;
    sum (t in Tasks) (p[t] == q) * (TaskProps[t].WCET * hyper div TaskProps[t].period) <= hyper;

    sum (t in Tasks) (p[t] == q) * (TaskProps[t].taskSize) <= maxTaskSize;
  }

  // All cores in a clique must be different
  forall (c in Cliques) {
    allDifferent(all (t in Tasks : t in c.clq) p[t]);
  }

  // Pre-map first task to first core
  p[first(Tasks)] == 1;

  // Jobs for which we can imply an ordering
  forall (<j,l> in Ordered) {
    if (level > 0) {
      (p[JobProps[j].task] == p[JobProps[l].task]) =>
      (startOf(s[l]) >= endOf(s[j]));
    }
  }
  // Jobs for which there is no ordering
  forall (<j,l> in Unordered) {
    if (level > 0) {
      (p[JobProps[j].task] == p[JobProps[l].task]) =>
      ((startOf(s[j]) >= endOf(s[l])) || (startOf(s[l]) >= endOf(s[j])));
    }
  }

  // Jobs which might span the hyper-period boundaries
  forall (<j, l> in Hypers) {
    if (level > 0) {

      // if first job is executed in the offset-part, the other must be executed in the hyper part
      (endOf(s[j]) <= maxOff) =>
      (endOf(s[l]) <= maxOff+hyper);

      // first job crosses hyper-period boundary or is in hyper-part, second must fit in
      (endOf(s[j]) > maxOff) =>
      (startOf(s[l]) == startOf(s[j])+hyper);
    }
  }

  // Buffers must fit onto the tile's memory
  forall (q in Tiles) {
    sum (b in Bufs) (m[b] == q) * BufProps[b].bufsize <= maxBufSize;
  }

  // Bound contention
  minCont <= n_cont <= maxCont;
  // Bound number of cores, upper bound only valid when using precise n_cont
  minCores <= n_cores <= maxCores;
  // minCores <= n_cores;
}

execute {
//  for (t in Tasks)
//    writeln("p(",t,") = ", p[t]);
//  for (b in Bufs)
//    writeln("m(",b,") = ", m[b]);
//  for (j in Jobs)
//    writeln("s(",j,") = ", s[j]);
  writeln("n_cores = ", n_cores);
  writeln("n_cont = ", n_cont);
}