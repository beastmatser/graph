# module graphs


## Contents
- [complete_bipartite_graph](#complete_bipartite_graph)
- [complete_graph](#complete_graph)
- [cycle_graph](#cycle_graph)
- [path_graph](#path_graph)
- [star_graph](#star_graph)
- [wheel_graph](#wheel_graph)
- [Graph.from_adjacency](#Graph.from_adjacency)
- [Graph.from_adjacency_matrix](#Graph.from_adjacency_matrix)
- [Graph.from_graph6](#Graph.from_graph6)
- [Graph[T]](#Graph[T])
  - [bfs](#bfs)
  - [complement](#complement)
  - [degeneracy](#degeneracy)
  - [degree_list](#degree_list)
  - [degree_map](#degree_map)
  - [density](#density)
  - [dfs](#dfs)
  - [diameter](#diameter)
  - [eccentricity](#eccentricity)
  - [girth](#girth)
  - [has_eulerian_path](#has_eulerian_path)
  - [is_acyclic](#is_acyclic)
  - [is_bipartite](#is_bipartite)
  - [is_complete](#is_complete)
  - [is_connected](#is_connected)
  - [is_cycle](#is_cycle)
  - [is_eulerian](#is_eulerian)
  - [is_regular](#is_regular)
  - [is_tree](#is_tree)
  - [line_graph](#line_graph)
  - [max_degree](#max_degree)
  - [min_degree](#min_degree)
  - [num_connected_components](#num_connected_components)
  - [num_edges](#num_edges)
  - [num_nodes](#num_nodes)
  - [num_spanning_trees](#num_spanning_trees)
  - [num_triangles](#num_triangles)
  - [radius](#radius)
  - [to_adjacency](#to_adjacency)
  - [to_adjacency_matrix](#to_adjacency_matrix)
  - [to_graph6](#to_graph6)
- [Edge](#Edge)
- [Graph](#Graph)
- [Node](#Node)

## complete_bipartite_graph
```v
fn complete_bipartite_graph(n int, m int) Graph[int]
```

Generates a complete bipartite graph on $n \times m$ nodes, with respectively $n$ and $m$ nodes in the two partitions of the graph. The nodes of the graph are integers, from 0 to $n \times m -1$.

[[Return to contents]](#Contents)

## complete_graph
```v
fn complete_graph(n int) Graph[int]
```

Generates a complete graph on $n$ nodes. The nodes of the graph are integers, from 0 to $n-1$.

[[Return to contents]](#Contents)

## cycle_graph
```v
fn cycle_graph(n int) Graph[int]
```

Generates a cycle graph on $n$ nodes. The graph's nodes are integer values from 0 to $n-1$.

[[Return to contents]](#Contents)

## path_graph
```v
fn path_graph(n int) Graph[int]
```

Generates a path graph on $n$ nodes. The nodes of the graph are integers, from 0 to $n-1$.

[[Return to contents]](#Contents)

## star_graph
```v
fn star_graph(n int) Graph[int]
```

Generates a star graph on $n$ nodes. In this case a star graph on $n$ nodes has $n-1$ leaves and a center. The nodes of the graph are integers, from 0 to $n-1$.

[[Return to contents]](#Contents)

## wheel_graph
```v
fn wheel_graph(n int) Graph[int]
```

Generates a wheel graph on $n$ nodes. In this case a wheel graph on $n$ nodes has $n-1$ nodes with degree three and one node with degree $n-1$. The nodes of the graph are integers, from 0 to $n-1$.

[[Return to contents]](#Contents)

## Graph.from_adjacency
```v
fn Graph.from_adjacency[T](adj map[T][]T) Graph[T]
```

Generates a graph from a mapping with the following signature: `map[T][]T`, with `T` any type. The keys of the map become the nodes of the graph. The values of the map represent the neighbours of their corresponding key.

Note: if a node is present as a neighbour of another node but not the other way around, then some edges can be missing. For example, the map `{0: [], 1: [0]}` will result in a graph with two nodes but no edges. This is because any node that was already seen in the key values will be skipped if they appear in the list of neighbours of another node, in an effort to avoid adding duplicate edges.

[[Return to contents]](#Contents)

## Graph.from_adjacency_matrix
```v
fn Graph.from_adjacency_matrix(adj [][]int) Graph[int]
```

Generate a graph from an integer matrix, returns a graph with integer values for the nodes. Note that only the upper triangle is checked, since any adjacency matrix of an undirected graph should be symmetric. So, it is not required to fill in the whole matrix, only the upper triangle is needed to create the graph.

[[Return to contents]](#Contents)

## Graph.from_graph6
```v
fn Graph.from_graph6(g6 string) Graph[int]
```

Generates a graph from a graph6 string, any invalid string will panic. For more info visit: https://users.cecs.anu.edu.au/~bdm/data/formats.html.

[[Return to contents]](#Contents)

## Graph[T]
## bfs
```v
fn (graph Graph[T]) bfs[T]() Graph[T]
```

Runs a breadth-first search (bfs) on the first node in nodes list of the Graph object. It returns a spanning forrest of the graph.

[[Return to contents]](#Contents)

## complement
```v
fn (graph Graph[T]) complement[T]() Graph[T]
```

Gives the complement of a graph. The list of (references to) nodes is copied, so that a change in the original graph not appears in the complement. This has the drawback that the complement of the complement not thr original graph is.

[[Return to contents]](#Contents)

## degeneracy
```v
fn (graph Graph[T]) degeneracy() int
```

Returns the degeneracy the graph. It implements the algorithm described by Matula and Beck, described [here](https://doi.org/10.1145/2402.322385)

[[Return to contents]](#Contents)

## degree_list
```v
fn (graph Graph[T]) degree_list[T]() []int
```

Returns a list of the degrees of the graph, not necessarily ordered.

[[Return to contents]](#Contents)

## degree_map
```v
fn (graph Graph[T]) degree_map[T]() map[int]int
```

Returns a map of the degrees of the graph. The keys are the indices of the nodes in the node list of the graph and the values are the degrees of the nodes.

[[Return to contents]](#Contents)

## density
```v
fn (graph Graph[T]) density[T]() f32
```

Returns the density of the graph.

[[Return to contents]](#Contents)

## dfs
```v
fn (graph Graph[T]) dfs[T]() Graph[T]
```

Runs a depth-first search (dfs) on the first node in nodes list of the Graph object. It returns a spanning forrest of the graph.

[[Return to contents]](#Contents)

## diameter
```v
fn (graph Graph[T]) diameter[T]() int
```

Returns the diameter of the graph, this implementation only works for connected graphs.

[[Return to contents]](#Contents)

## eccentricity
```v
fn (graph Graph[T]) eccentricity[T](node &Node[T]) int
```

Returns the eccentricity of a given node.

[[Return to contents]](#Contents)

## girth
```v
fn (graph Graph[T]) girth[T]() int
```

Returns the girth of the graph.

[[Return to contents]](#Contents)

## has_eulerian_path
```v
fn (graph Graph[T]) has_eulerian_path[T]() bool
```

Checks whether the graph contains an Eulerian path.

[[Return to contents]](#Contents)

## is_acyclic
```v
fn (graph Graph[T]) is_acyclic[T]() bool
```

Checks whether the graph is acyclic, i.e. does not contain a cycle. This differs from checking if a graph is a tree, since a graph can be a forrest.

[[Return to contents]](#Contents)

## is_bipartite
```v
fn (graph Graph[T]) is_bipartite[T]() bool
```

Checks whether the graph is bipartite.

[[Return to contents]](#Contents)

## is_complete
```v
fn (graph Graph[T]) is_complete[T]() bool
```

Checks whether the graph is a complete graph.

[[Return to contents]](#Contents)

## is_connected
```v
fn (graph Graph[T]) is_connected[T]() bool
```

Checks whether the graph is connected.

[[Return to contents]](#Contents)

## is_cycle
```v
fn (graph Graph[T]) is_cycle[T]() bool
```

Checks whether the graph is a cycle.

[[Return to contents]](#Contents)

## is_eulerian
```v
fn (graph Graph[T]) is_eulerian[T]() bool
```

Checks whether the graph is Eulerian.

[[Return to contents]](#Contents)

## is_regular
```v
fn (graph Graph[T]) is_regular[T]() bool
```

Checks whether the graph is regular.

[[Return to contents]](#Contents)

## is_tree
```v
fn (graph Graph[T]) is_tree[T]() bool
```

Checks whether the graph is a tree.

[[Return to contents]](#Contents)

## line_graph
```v
fn (graph Graph[T]) line_graph[T]() Graph[int]
```

Gives the line graph of a graph. The list of (references to) nodes is copied, so that a change in the original graph not appears in the line graph.

[[Return to contents]](#Contents)

## max_degree
```v
fn (graph Graph[T]) max_degree[T]() int
```

Returns the maximum degree of the graph.

[[Return to contents]](#Contents)

## min_degree
```v
fn (graph Graph[T]) min_degree[T]() int
```

Returns the minimum degree of the graph.

[[Return to contents]](#Contents)

## num_connected_components
```v
fn (graph Graph[T]) num_connected_components[T]() int
```

Returns the number of connected components of the graph.

[[Return to contents]](#Contents)

## num_edges
```v
fn (graph Graph[T]) num_edges[T]() int
```

Returns the number of edges of a graph, also accesible through `graph.edges.len`.

[[Return to contents]](#Contents)

## num_nodes
```v
fn (graph Graph[T]) num_nodes[T]() int
```

Returns the number of nodes of a graph, also accesible through `graph.nodes.len`.

[[Return to contents]](#Contents)

## num_spanning_trees
```v
fn (graph Graph[T]) num_spanning_trees[T]() f64
```

Returns the number of spanning trees of the graph.

[[Return to contents]](#Contents)

## num_triangles
```v
fn (graph Graph[T]) num_triangles[T]() int
```

Returns the number of triangles of the graph.

[[Return to contents]](#Contents)

## radius
```v
fn (graph Graph[T]) radius[T]() int
```

Returns the radius of the graph, this implementation only works for connected graphs.

[[Return to contents]](#Contents)

## to_adjacency
```v
fn (graph Graph[T]) to_adjacency[T]() map[int][]int
```

Formats a graph into an adjacency mapping of the graph. The keys represent the index of the node in the list of nodes of the graph. A value corresponding to a key is a list with all indices of the neighbours of this key. For example, if the nodes are given by `[&Node{'a'}, &Node{'b'}]` and there exists an edge between these two nodes. Then the resulting map will look like this: `{0: [1], 1: [0]}`, so here zero and one correspond to the nodes `&Node{'a'}` and `&Node{'b'}` respectively.

[[Return to contents]](#Contents)

## to_adjacency_matrix
```v
fn (graph Graph[T]) to_adjacency_matrix[T]() [][]int
```

Gives the (symmetric) adjacency matrix of the graph. The order of the rows and columns is exactly the same as the order of the nodes list in the graph object.

[[Return to contents]](#Contents)

## to_graph6
```v
fn (graph Graph[T]) to_graph6[T]() string
```

Returns the graph6 format of the given graph.

[[Return to contents]](#Contents)

## Edge
```v
struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
}
```

An edge contains two references to nodes of type `T`.

[[Return to contents]](#Contents)

## Graph
```v
struct Graph[T] {
pub:
	nodes []&Node[T]
	edges []&Edge[T]
}
```

A graph is a list of references to nodes and a list of references to edges made up of these nodes.

[[Return to contents]](#Contents)

## Node
```v
struct Node[T] {
pub mut:
	x T
}
```

A node that contains a value of type `T` in the mutable field `x`. Nodes are stored on the heap to ensure stable references to it.

[[Return to contents]](#Contents)

#### Powered by vdoc. Generated on: 3 Jul 2025 22:31:17
