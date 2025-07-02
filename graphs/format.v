module graphs

pub fn (graph Graph[T]) to_adjacency[T]() map[int][]int {
	mut adj := map[int][]int{}

	mut node_to_int := map[voidptr]int
	for i, node in graph.nodes {
		node_to_int[node] = i
		adj[i] = []
	}

	for edge in graph.edges {
		mut list1 := adj[node_to_int[edge.node1]] or { []int{} }
		list1 << node_to_int[edge.node2]
		adj[node_to_int[edge.node1]] = list1

		mut list2 := adj[node_to_int[edge.node2]] or { []int{} }
		list2 << node_to_int[edge.node1]
		adj[node_to_int[edge.node2]] = list2
	}

	return adj
}

pub fn (graph Graph[T]) to_adjacency_matrix[T]() [][]int {
	mut matrix := [][]int{len: graph.nodes.len, init: []int{len: graph.nodes.len}}

	mut ptr_to_index := map[voidptr]int{}
	for i, node in graph.nodes {
		ptr_to_index[node] = i
	}

	for edge in graph.edges {
		i := ptr_to_index[edge.node1]
		j := ptr_to_index[edge.node2]
		matrix[i][j] = 1
		matrix[j][i] = 1
	}

	return matrix
}

pub fn (graph Graph[T]) to_graph6[T]() string {
	matrix := graph.to_adjacency_matrix()
	mut x := []bool{cap: graph.nodes.len * (graph.nodes.len - 1) / 2}
	for j in 1 .. matrix.len {
		for i in 0 .. j {
			x << matrix[i][j] != 0
		}
	}
	return to_string(int_repr(graph.nodes.len)) + to_string(bit_vector_repr(x))
}
