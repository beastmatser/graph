module undirected

import common { Node, Edge }

// Gives the complement of a graph.
// The list of (references to) nodes is copied,
// so that a change in the original graph not appears in the complement.
// This has the drawback that the complement of the complement not thr original graph is.
pub fn (graph UndirectedGraph[T]) complement[T]() UndirectedGraph[T] {
	nodes := []&Node[T]{len: graph.nodes.len, init: &Node[T]{graph.nodes[index].val}}
	mut edges := []&Edge[T]{}

	for node1 in 0 .. graph.nodes.len {
		for node2 in 0..graph.nodes.len {
			if node1 < node2 && node2 !in graph.adjacency[node1] {
				edges << &Edge[T]{node1: nodes[node1], node2: nodes[node2]}
			}
		}
	}

	return UndirectedGraph.create[T](nodes, edges)
}

// Gives the line graph of a graph.
// The values of the nodes are the weights of the edges in the original graph.
// So, for a simple graph all nodes will contain the value one.
pub fn (graph UndirectedGraph[T]) line_graph[T]() UndirectedGraph[int] {
	nodes := []&Node[int]{len: graph.edges.len, init: &Node[int]{graph.edges[index].weight}}
	mut edges := []&Edge[int]{}

	for i, edge1 in graph.edges {
		for j, edge2 in graph.edges[i + 1..] {
			if edge1.node1 == edge2.node1 || edge1.node1 == edge2.node2
				|| edge1.node2 == edge2.node1 || edge1.node2 == edge2.node2 {
				edges << &Edge[int]{node1: nodes[i], node2: nodes[j + i + 1]}
			}
		}
	}

	return UndirectedGraph.create[int](nodes, edges)
}
