module graph

// A node that contains a value of type `T` in the mutable field `val`.
// Nodes are stored on the heap to ensure stable references to them.
@[heap]
pub struct Node[T] {
pub mut:
	val T
}

// An edge contains two references to nodes of type `T` and an integer weight.
// The weights default to length one to emulate unweighted graphs.
// Edges are, just as nodes, stored on the heap to ensure stable references to them.
@[heap]
pub struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
pub mut:
	weight int = 1
}

pub fn (gr Graph[T]) get_edge[T](node1 &Node[T], node2 &Node[T]) !&Edge[T] {
	if node1 !in gr.adjacency {
		return error('${node1} does not exist')
	}

	return unsafe { gr.adjacency[node1] }[node2] or {
		return error('There exists no edge between ${node1} and ${node2}')
	}
}

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
// It must be constructed through `Graph.create`.
// The attributes `nodes` and `edges` must be accessed through `.nodes()` and `.edges()` respectively.
// This is to ensure the user does not change the nodes or edges list without fixing the adjacency mapping.
@[noinit]
pub struct Graph[T] {
mut:
	adjacency map[voidptr]map[voidptr]&Edge[T]
	nodes     []&Node[T]
	edges     []&Edge[T]
}

pub fn (gr Graph[T]) nodes[T]() []&Node[T] {
	return gr.nodes
}

pub fn (gr Graph[T]) edges[T]() []&Edge[T] {
	return gr.edges
}

// Factory function to create an Graph from a list of nodes
// and a list of edges containing these nodes.
// Example:
// ```v
// nodes := []&Node[int]{len: 6, init: &Node{index}}
// // Be sure that the edges contain nodes that are available from the nodes list!
// edges := [&Edge[int]{nodes[0], nodes[1], 1}, &Edge[int]{nodes[1], nodes[2], 1}, &Edge[int]{nodes[2], nodes[5], 1}]
// Graph.create[int](nodes, edges)
// ```
pub fn Graph.create[T](nodes []&Node[T], edges []&Edge[T]) Graph[T] {
	mut adj := map[voidptr]map[voidptr]&Edge[T]{}

	for edge in edges {
		adj[edge.node1][edge.node2] = edge
		adj[edge.node2][edge.node1] = edge
	}

	return Graph[T]{adj, nodes, edges}
}

// Creates a clone of the graph, changes made in a clone will not affect the original graph.
pub fn (gr Graph[T]) clone[T]() Graph[T] {
	mut nodes := []&Node[T]{cap: gr.nodes.len}
	mut edges := []&Edge[T]{cap: gr.edges.len}

	mut adj := map[voidptr]map[voidptr]&Edge[T]{}
	mut node_to_index := map[voidptr]int{}
	for i in 0 .. gr.nodes.len {
		node := &Node[T]{gr.nodes[i].val}
		node_to_index[gr.nodes[i]] = i
		nodes << node
	}

	for edge in gr.edges {
		new_edge := &Edge[T]{nodes[node_to_index[edge.node1]], nodes[node_to_index[edge.node2]], edge.weight}
		edges << new_edge
		adj[edge.node1][edge.node2] = new_edge
		adj[edge.node2][edge.node1] = new_edge
	}

	return Graph[T]{adj, nodes, edges}
}
