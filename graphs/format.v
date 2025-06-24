module graphs

pub fn (graph Graph[T]) to_adjacency[T]() map[voidptr][]&Node[T] {
	mut adj := map[voidptr][]&Node[T]{}

	for edge in graph.edges {
		mut list1 := adj[edge.node1] or { []&Node[T]{} }
		list1 << edge.node2
		adj[edge.node1] = list1

		mut list2 := adj[edge.node2] or { []&Node[T]{} }
		list2 << edge.node1
		adj[edge.node2] = list2
	}

	return adj
}

pub fn (graph Graph[T]) to_adjacency_matrix[T]() [][]bool {
	mut matrix := [][]bool{len: graph.nodes.len, init: []bool{len: graph.nodes.len}}

	mut ptr_to_index := map[voidptr]int{}
	for i, node in graph.nodes {
		ptr_to_index[node] = i
	}

	for edge in graph.edges {
		i := ptr_to_index[edge.node1]
		j := ptr_to_index[edge.node2]
		matrix[i][j] = true
		matrix[j][i] = true
	}

	return matrix
}

pub fn (graph Graph[T]) to_graph6[T]() string {
	matrix := graph.to_adjacency_matrix()
	mut x := []bool{cap: graph.nodes.len * (graph.nodes.len - 1) / 2}
	for j in 1 .. matrix.len {
		for i in 0 .. j {
			x << matrix[i][j]
		}
	}
	return to_string(int_repr(graph.nodes.len)) + to_string(bit_vector_repr(x))
}
