module common

// A node that contains a value of type `T` in the mutable field `val`.
// Nodes are stored on the heap to ensure stable references to them.
@[heap]
pub struct Node[T] {
pub mut:
	val T
}

// An edge contains two references to nodes of type `T`.
pub struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
pub mut:
	weight int = 1
}

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
pub struct Graph[T] {
pub:
	nodes []&Node[T]
	edges []&Edge[T]
}

// Creates a clone of the graph, changes made in a clone will not affect the original graph.
pub fn (graph Graph[T]) clone[T]() Graph[T] {
	nodes := []&Node[T]{len: graph.nodes.len, init: &Node[T]{graph.nodes[index].val}}
	mut edges := []&Edge[T]{}

	mut node_to_int := map[voidptr]int{}
	for i, node in nodes {
		node_to_int[node] = i
	}

	for edge in graph.edges {
		edges << &Edge[T]{nodes[node_to_int[edge.node1]], nodes[node_to_int[edge.node2]], edge.weight}
	}

	return Graph[T]{nodes, edges}
}
