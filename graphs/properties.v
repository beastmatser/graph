module graphs

import arrays

pub fn (graph Graph[T]) num_nodes[T]() int {
	return graph.nodes.len
}

pub fn (graph Graph[T]) num_edges[T]() int {
	return graph.edges.len
}

pub fn (graph Graph[T]) degree_map[T]() map[voidptr]int {
	mut degrees := map[voidptr]int{}
	for node in graph.nodes {
		degrees[node] = 0
	}

	for edge in graph.edges {
		degrees[edge.node1] += 1
		degrees[edge.node2] += 1
	}

	return degrees
}

pub fn (graph Graph[T]) degree_list[T]() []int {
	return graph.degree_map().values()
}

pub fn (graph Graph[T]) min_degree[T]() int {
	return arrays.min(graph.degree_list()) or {0}
}

pub fn (graph Graph[T]) max_degree[T]() int {
	return arrays.max(graph.degree_list()) or {0}
}

pub fn (graph Graph[T]) density[T]() f32 {
	n := graph.nodes.len
	return 2*f32(graph.edges.len) / f32(n*(n - 1))
}

pub fn (graph Graph[T]) is_regular[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or {0} == arrays.max(degrees) or {0}
}
