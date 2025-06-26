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
	return arrays.min(graph.degree_list()) or { 0 }
}

pub fn (graph Graph[T]) max_degree[T]() int {
	return arrays.max(graph.degree_list()) or { 0 }
}

pub fn (graph Graph[T]) density[T]() f32 {
	n := graph.nodes.len
	return 2 * f32(graph.edges.len) / f32(n * (n - 1))
}

pub fn (graph Graph[T]) is_regular[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == arrays.max(degrees) or { 0 }
}

pub fn (graph Graph[T]) is_cycle[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == 2 && arrays.max(degrees) or { 0 } == 2
}

pub fn (graph Graph[T]) is_complete[T]() bool {
	degrees := graph.degree_list()
	n := graph.nodes.len
	return arrays.min(degrees) or { 0 } == n - 1 && arrays.max(degrees) or { 0 } == n - 1
}

pub fn (graph Graph[T]) is_eulerian[T]() bool {
	degrees := graph.degree_list()
	return degrees.all(it % 2 == 0)
}

pub fn (graph Graph[T]) has_eulerian_path[T]() bool {
	degrees := graph.degree_list()
	return degrees.count(it % 2 == 1) == 2
}

pub fn (graph Graph[T]) is_tree[T]() bool {
	if graph.edges.len != graph.nodes.len - 1 {
		return false
	}

	return graph.dfs().edges.len == graph.edges.len
}

pub fn (graph Graph[T]) is_connected[T]() bool {
	span_tree := graph.dfs()
	return span_tree.edges.len == span_tree.nodes.len
}
