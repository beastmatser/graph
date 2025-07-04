module common

// Returns the number of nodes of a graph, also accessible through `Graph.nodes.len`.
pub fn (graph Graph[T]) num_nodes[T]() int {
	return graph.nodes.len
}

// Returns the number of edges of a graph, also accessible through `Graph.edges.len`.
pub fn (graph Graph[T]) num_edges[T]() int {
	return graph.edges.len
}
