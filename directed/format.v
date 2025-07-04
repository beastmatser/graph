module directed

import undirected

// Formats a directed graph into an adjacency mapping of the graph.
// The keys represent the index of the node in the list of nodes of the graph.
// A value corresponding to a key is a list with all indices of the outgoing neighbours of this key.
// For example, if the nodes are given by `[&Node{'a'}, &Node{'b'}]`
// and there exists an edge between these two nodes from 'a' to 'b'.
// Then the resulting map will look like this: `{0: [1], 1: []}`,
// so here zero and one correspond to the nodes `&Node{'a'}` and `&Node{'b'}` respectively.
pub fn (graph DirectedGraph[T]) to_adjacency[T]() map[int][]int {
	mut adj := map[int][]int{}

	mut node_to_int := map[voidptr]int{}
	for i, node in graph.nodes {
		node_to_int[node] = i
		adj[i] = []
	}

	for edge in graph.edges {
		mut list := adj[node_to_int[edge.node1]]
		list << node_to_int[edge.node2]
		adj[node_to_int[edge.node1]] = list
	}

	return adj
}

// Formats a directed graph into an adjacency mapping with weights of the graph.
// The keys represent the index of the node in the list of nodes of the graph.
// A value corresponding to a key is a list of maps with keys the indices of the outgoing neighbours.
// For example, if the nodes are given by `[&Node{'a'}, &Node{'b'}]`
// and there exists an edge with weight 3 between these two nodes from 'a' to 'b'.
// Then the resulting map will look like this: `{0: {1: 3}, 1: {}}`,
// so here zero and one correspond to the nodes `&Node{'a'}` and `&Node{'b'}` respectively.
pub fn (graph DirectedGraph[T]) to_adjacency_weights[T]() map[int]map[int]int {
	mut adj := map[int]map[int]int{}

	mut node_to_int := map[voidptr]int{}
	for i, node in graph.nodes {
		node_to_int[node] = i
		adj[i] = {}
	}

	for edge in graph.edges {
		adj[node_to_int[edge.node1]][node_to_int[edge.node2]] = edge.weight
	}

	return adj
}

// Creates an undirected graph from a directed graph by making all edges undirected.
pub fn (graph DirectedGraph[T]) to_undirected[T]() undirected.UndirectedGraph[T] {
	return undirected.UndirectedGraph.create[T](graph.nodes, graph.edges)
}
