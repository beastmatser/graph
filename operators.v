module graph

// Gives the complement of a graph.
// The list of (references to) nodes is reused,
// so that a change in the original graph also appears in the complement.
// This implies that the complement of the complement the original graph is.
pub fn (gr Graph[T]) complement[T]() Graph[T] {
	mut edges := []&Edge[T]{cap: gr.nodes.len * (gr.nodes.len - 1) / 2 - gr.edges.len}

	for node1 in 0 .. gr.nodes.len {
		for node2 in 0 .. gr.nodes.len {
			if node1 < node2 && node2 !in gr.adjacency[node1] {
				edges << &Edge[T]{
					node1: gr.nodes[node1]
					node2: gr.nodes[node2]
				}
			}
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

// Gives the line graph of a graph.
// The values of the nodes are the weights of the edges in the original graph.
// So, for a simple graph all nodes will contain the value one.
pub fn (gr Graph[T]) line_graph[T]() Graph[int] {
	nodes := []&Node[int]{len: gr.edges.len, init: &Node[int]{gr.edges[index].weight}}
	mut edges := []&Edge[int]{cap: gr.edges.len}

	for i, edge1 in gr.edges {
		for j, edge2 in gr.edges[i + 1..] {
			if edge1.node1 == edge2.node1 || edge1.node1 == edge2.node2
				|| edge1.node2 == edge2.node1 || edge1.node2 == edge2.node2 {
				edges << &Edge[int]{
					node1: nodes[i]
					node2: nodes[j + i + 1]
				}
			}
		}
	}

	return Graph.create[int](nodes, edges)
}
