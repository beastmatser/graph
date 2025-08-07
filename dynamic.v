module graph

// Adds a node to the graph.
pub fn (mut gr Graph[T]) add_node[T](node &Node[T]) {
	gr.nodes << node
}

// Add a list of nodes to the graph.
pub fn (mut gr Graph[T]) add_nodes[T](nodes []&Node[T]) {
	gr.nodes << nodes
}

// Removes a node from the graph.
// The time complexity for removing a node is O(d*m),
// where d is the degree of the node and m the number of edges of the graph.
pub fn (mut gr Graph[T]) remove_node[T](node &Node[T]) {
	gr.nodes.delete(gr.nodes.index(node))

	for neighbour, edge in gr.adjacency[node] or { return } {
		unsafe { gr.adjacency[neighbour].delete(node) }
		gr.edges.delete(gr.edges.index(edge))
	}

	gr.adjacency.delete(node)
}

// Removes a list of nodes from the graph, internally `.remove_node` is used.
pub fn (mut gr Graph[T]) remove_nodes[T](nodes []&Node[T]) {
	for node in nodes {
		gr.remove_node(node)
	}
}

// Adds an edge to the graph.
pub fn (mut gr Graph[T]) add_edge[T](edge &Edge[T]) {
	gr.edges << edge

	gr.adjacency[edge.node1][edge.node2] = edge
	gr.adjacency[edge.node2][edge.node1] = edge
}

// Adds a list of edges to the graph.
pub fn (mut gr Graph[T]) add_edges[T](edges []&Edge[T]) {
	for edge in edges {
		gr.add_edge(edge)
	}
}

// Removes an edge from the graph,
// the time complexity is given by O(m), with m the number of edges in the graph.
pub fn (mut gr Graph[T]) remove_edge[T](edge &Edge[T]) {
	gr.edges.delete(gr.edges.index(edge))
}

// Removes a list of edges, internally `.remove_edge` is used.
pub fn (mut gr Graph[T]) remove_edges[T](edges []&Edge[T]) {
	for edge in edges {
		gr.remove_edge(edge)
	}
}
