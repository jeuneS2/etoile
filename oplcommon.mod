tuple task {
  int period;
  int WCET;
  int taskSize;
}

tuple job {
  string task;
  int release;
  int deadline;
}

tuple dep {
  string src;
  string dst;
}

tuple buf {
  string src;
  string dst;
  int bufsize;
}

tuple pair {
  string first;
  string second;
}

tuple clique {
  {string} clq;
}

int nbCores = ...;
int nbTiles = ...;
int minCores = ...;
int maxCores = ...;
int minCont = ...;
int maxCont = ...;
int maxBufSize = ...;
int maxTaskSize = ...;

range Cores = 1..nbCores;
range Tiles = 1..nbTiles;

int maxOff = ...;
int hyper = ...;

{string} Tasks = ...;
task TaskProps[Tasks] = ...;
{string} Jobs = ...;
job JobProps[Jobs] = ...;
{dep} Deps = ...;
{string} Bufs = ...;
buf BufProps[Bufs] = ...;

{pair} Hypers = ...;

{clique} Cliques = ...;

{pair} Unordered = ...;
{pair} Ordered = ...;
