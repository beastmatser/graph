module graph

// Adds a node to the graph.
// It will fail when you try to add a node that is already present in the graph.
pub fn (mut gr Graph[T]) add_node[T](node &Node[T]) ! {
	if node in gr.adjacency {
		return error('Tried to add node that is already present in the graph')
	}

	gr.nodes << node
	gr.adjacency[node] = map[voidptr]&Edge[T]{}
}

// Add a list of nodes to the graph.
// It will fail when there is a single node in the given list that is already present in the graph,
// in that case no nodes will be added to the graph.
pub fn (mut gr Graph[T]) add_nodes[T](nodes []&Node[T]) ! {
	for node in nodes {
		if node in gr.adjacency {
			return error('Tried to add node that is already present in the graph')
		}
	}
	for node in nodes {
		gr.add_node(node) or {}
	}
}

// Removes a node from the graph,
// if the node is not present in the graph then this removal will fail.
// The time complexity for removing a node is O(d*m),
// where d is the degree of the node and m the number of edges of the graph.
pub fn (mut gr Graph[T]) remove_node[T](node &Node[T]) ! {
	index := gr.nodes.index(node)
	if index == -1 {
		return error('Cannot remove node since it is not present in the graph')
	}
	gr.nodes.delete(index)

	for neighbour, edge in gr.adjacency[node] or { return } {
		unsafe { gr.adjacency[neighbour].delete(node) }
		gr.edges.delete(gr.edges.index(edge))
	}

	gr.adjacency.delete(node)
}

// Removes a list of nodes from the graph, internally `.remove_node` is used.
// If this list contains a single node not present in the graph, this will fail.
// Then none of the nodes will be added.
pub fn (mut gr Graph[T]) remove_nodes[T](nodes []&Node[T]) ! {
	for node in nodes {
		if node !in gr.adjacency {
			return error('Cannot remove node since it is not present in the graph')
		}
	}
	for node in nodes {
		gr.remove_node(node) or {}
	}
}

// Adds an edge to the graph.
// It will fail if you try to add an edge that connects at least one node not in the graph
// or when you try to add an edge between nodes that are already connected.
pub fn (mut gr Graph[T]) add_edge[T](edge &Edge[T]) ! {
	if edge.node1 !in gr.adjacency || edge.node2 !in gr.adjacency {
		return error('Tried adding edge with at least one node not present in the graph')
	}

	if edge.node2 in unsafe { gr.adjacency[edge.node1] }
		|| edge.node1 in unsafe { gr.adjacency[edge.node2] } {
		return error('Tried adding an edge that already exists')
	}

	gr.edges << edge

	gr.adjacency[edge.node1][edge.node2] = edge
	gr.adjacency[edge.node2][edge.node1] = edge
}

// Adds a list of edges to the graph.
// If one edge in the list contains a node not in the graph, no edges will be added to the graph,
// and this process will fail.
// It will also fail when the given list contains a single edge that is already contained in the graph.
pub fn (mut gr Graph[T]) add_edges[T](edges []&Edge[T]) ! {
	for edge in edges {
		if edge.node1 !in gr.adjacency || edge.node2 !in gr.adjacency {
			return error('Tried adding edge with at least one node not present in the graph')
		}

		if edge.node2 in unsafe { gr.adjacency[edge.node1] }
			|| edge.node1 in unsafe { gr.adjacency[edge.node2] } {
			return error('Tried adding an edge that already exists')
		}
	}
	for edge in edges {
		gr.add_edge(edge) or {}
	}
}

// Removes an edge from the graph,
// the time complexity is given by O(m), with m the number of edges in the graph.
// This will fail when you try to remove an edge that is not an element of the edges list of the graph.
pub fn (mut gr Graph[T]) remove_edge[T](edge &Edge[T]) ! {
	index := gr.edges.index(edge)
	if index == -1 {
		return error('Cannot remove edge since it is not present in the graph')
	}
	gr.edges.delete(index)

	unsafe {
		gr.adjacency[edge.node1].delete(edge.node2)
		gr.adjacency[edge.node2].delete(edge.node1)
	}
}

// Removes a list of edges, internally `.remove_edge` is used.
// If a singular edge does not exist in the graph then this will fail and no edges will be removed.
pub fn (mut gr Graph[T]) remove_edges[T](edges []&Edge[T]) ! {
	for edge in edges {
		if edge.node1 !in gr.adjacency[edge.node2] or {
			map[voidptr]&Edge[T]{}
		} || edge.node2 !in gr.adjacency[edge.node1] or {
			map[voidptr]&Edge[T]{}
		} {
			return error('Cannot remove edge since it is not present in the graph')
		}
	}
	for edge in edges {
		gr.remove_edge(edge) or {}
	}
}
