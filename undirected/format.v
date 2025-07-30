module undirected

// Gives the (symmetric) adjacency matrix of the graph.
// The order of the rows and columns is exactly the same as the order of the nodes list in the graph object.
pub fn (graph Graph[T]) to_adjacency_matrix[T]() [][]int {
	mut matrix := [][]int{len: graph.nodes.len, init: []int{len: graph.nodes.len}}

	for node1, neighbours in graph.adjacency {
		for node2, edge in neighbours {
			matrix[node1][node2] = graph.edges[edge].weight
		}
	}

	return matrix
}

// Returns the graph6 format of the given graph.
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
