module graphs

// Gives the complement of a graph.
// The list of (references to) nodes is copied,
// so that a change in the original graph not appears in the complement.
// This has the drawback that the complement of the complement not thr original graph is.
pub fn (graph Graph[T]) complement[T]() Graph[T] {
	adj := graph.to_adjacency()
	nodes := graph.nodes.clone()
	mut edges := []&Edge[T]{}

	for node1, neighbours in adj {
		for node2, _ in adj {
			if node1 < node2 && node2 !in neighbours {
				edges << &Edge[T]{nodes[node1], nodes[node2]}
			}
		}
	}

	return Graph[T]{nodes, edges}
}

// Gives the line graph of a graph.
// The list of (references to) nodes is copied,
// so that a change in the original graph not appears in the line graph.
pub fn (graph Graph[T]) line_graph[T]() Graph[int] {
	nodes := []&Node[int]{len: graph.edges.len, init: &Node[int]{index}}
	mut edges := []&Edge[int]{}

	for i, edge1 in graph.edges {
		for j, edge2 in graph.edges[i + 1..] {
			if edge1.node1 == edge2.node1 || edge1.node1 == edge2.node2
				|| edge1.node2 == edge2.node1 || edge1.node2 == edge2.node2 {
				edges << &Edge[int]{nodes[i], nodes[j + i + 1]}
			}
		}
	}

	return Graph[int]{nodes, edges}
}
