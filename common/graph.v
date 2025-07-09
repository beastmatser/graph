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
	adjacency map[int]map[int]int
	node_to_index map[voidptr]int
}

pub fn Graph.create[T](nodes []&Node[T], edges []&Edge[T]) Graph[T] {
	mut adj := map[int]map[int]int{}
	mut node_to_index := map[voidptr]int{}
	for i, node in nodes {
		node_to_index[node] = i
		adj[i] = {}
	}

	for edge in edges {
		adj[node_to_index[edge.node1]][node_to_index[edge.node2]] = edge.weight
		adj[node_to_index[edge.node2]][node_to_index[edge.node1]] = edge.weight
	}

	return Graph[T]{nodes, edges, adj, node_to_index}
}

// Creates a clone of the graph, changes made in a clone will not affect the original graph.
pub fn (graph Graph[T]) clone[T]() Graph[T] {
	nodes := []&Node[T]{len: graph.nodes.len, init: &Node[T]{graph.nodes[index].val}}
	mut edges := []&Edge[T]{}

	mut node_to_index := map[voidptr]int{}
	for i, node in nodes {
		node_to_index[node] = i
	}

	for edge in graph.edges {
		edges << &Edge[T]{nodes[node_to_index[edge.node1]], nodes[node_to_index[edge.node2]], edge.weight}
	}

	return Graph[T]{nodes, edges, graph.adjacency, node_to_index}
}
