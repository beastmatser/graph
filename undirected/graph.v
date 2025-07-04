module undirected

import common { Node, Edge }

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
pub struct UndirectedGraph[T] {
	common.Graph[T]
	adjacency map[int]map[int]int
	degrees map[int]int
}

pub fn UndirectedGraph.create[T](nodes []&Node[T], edges []&Edge[T]) UndirectedGraph[T] {
	mut adj := map[int]map[int]int{}
	mut degrees := map[int]int{}

	mut node_to_int := map[voidptr]int{}
	for i, node in nodes {
		node_to_int[node] = i
		adj[i] = {}
		degrees[i] = 0
	}

	for edge in edges {
		adj[node_to_int[edge.node1]][node_to_int[edge.node2]] = edge.weight
		adj[node_to_int[edge.node2]][node_to_int[edge.node1]] = edge.weight
		degrees[node_to_int[edge.node1]] += 1
		degrees[node_to_int[edge.node2]] += 1
	}

	return UndirectedGraph[T]{common.Graph[T]{nodes, edges}, adj, degrees}
}
