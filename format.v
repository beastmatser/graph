module graph

// Gives the (symmetric) adjacency matrix of the graph.
pub fn (gr Graph[T]) to_adjacency_matrix[T]() [][]int {
	mut matrix := [][]int{len: gr.nodes.len, init: []int{len: gr.nodes.len}}

	mut node_to_index := map[voidptr]int{}
	for i, node in gr.nodes {
		node_to_index[node] = i
	}

	for node1, neighbours in gr.adjacency {
		for node2, edge in neighbours {
			matrix[node_to_index[node1]][node_to_index[node2]] = edge.weight
		}
	}

	return matrix
}

// Returns the graph6 format of the graph.
pub fn (gr Graph[T]) to_graph6[T]() string {
	matrix := gr.to_adjacency_matrix()
	mut x := []bool{cap: gr.nodes.len * (gr.nodes.len - 1) / 2}
	for j in 1 .. matrix.len {
		for i in 0 .. j {
			x << matrix[i][j] != 0
		}
	}
	return to_string(int_repr(gr.nodes.len)) + to_string(bit_vector_repr(x))
}
