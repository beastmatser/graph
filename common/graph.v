module common

// A node that contains a value of type `T` in the mutable field`val`.
// Nodes are stored on the heap to ensure stable references to them.
@[heap]
pub struct Node[T] {
pub mut:
	val T
}

// An edge contains two references to nodes of type `T` and an integer weight.
pub struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
pub mut:
	weight int = 1
}

pub fn (graph Graph[T]) get_edge[T](node1 &Node[T], node2 &Node[T]) &Edge[T] {
	node1_index := graph.node_to_index[node1]
	node2_index := graph.node_to_index[node2]
	edge_index := graph.adjacency[node1_index][node2_index]
	return graph.edges[edge_index]
}

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
// In addition, it holds an adjacency mapping, the keys are the nodes.
// The values are maps where its keys are nodes adjacent to the original node with value
// the index of the edge between these adjacent nodes in the edges list of the graph.
// Lastly, a mapping from the references of nodes to its index in the nodes list.
pub struct Graph[T] {
pub:
	nodes         []&Node[T]
	edges         []&Edge[T]
	adjacency     map[int]map[int]int
	node_to_index map[voidptr]int
}

// Creates a Graph object from a list of references to nodes and
// a list of references to edges.
pub fn Graph.create[T](nodes []&Node[T], edges []&Edge[T]) Graph[T] {
	mut adj := map[int]map[int]int{}
	mut node_to_index := map[voidptr]int{}
	for i, node in nodes {
		node_to_index[node] = i
		adj[i] = {}
	}

	for i, edge in edges {
		adj[node_to_index[edge.node1]][node_to_index[edge.node2]] = i
		adj[node_to_index[edge.node2]][node_to_index[edge.node1]] = i
	}

	return Graph[T]{nodes, edges, adj, node_to_index}
}

// Creates a clone of the graph, changes made in a clone will not affect the original graph.
pub fn (graph Graph[T]) clone[T]() Graph[T] {
	nodes := []&Node[T]{len: graph.nodes.len, init: &Node[T]{graph.nodes[index].val}}
	mut edges := []&Edge[T]{}

	mut adj := map[int]map[int]int{}
	mut node_to_index := map[voidptr]int{}
	for i, node in nodes {
		node_to_index[node] = i
	}

	for i, edge in graph.edges {
		new_edge := &Edge[T]{nodes[node_to_index[edge.node1]], nodes[node_to_index[edge.node2]], edge.weight}
		edges << new_edge
		adj[node_to_index[edge.node1]][node_to_index[edge.node2]] = i
		adj[node_to_index[edge.node2]][node_to_index[edge.node1]] = i
	}

	return Graph[T]{nodes, edges, graph.adjacency, node_to_index}
}
