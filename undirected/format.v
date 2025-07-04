module undirected

// Formats a graph into an adjacency mapping of the graph.
// The keys represent the index of the node in the list of nodes of the graph.
// A value corresponding to a key is a list with all indices of the neighbours of this key.
// For example, if the nodes are given by `[&Node{'a'}, &Node{'b'}]`
// and there exists an edge between these two nodes.
// Then the resulting map will look like this: `{0: [1], 1: [0]}`,
// so here zero and one correspond to the nodes `&Node{'a'}` and `&Node{'b'}` respectively.
pub fn (graph Graph[T]) to_adjacency[T]() map[int][]int {
	mut adj := map[int][]int{}

	mut node_to_int := map[voidptr]int{}
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

// Formats a graph into an adjacency mapping with weights of the graph.
// The keys represent the index of the node in the list of nodes of the graph.
// A value corresponding to a key is a list of maps with keys the indices of the neighbours .
// For example, if the nodes are given by `[&Node{'a'}, &Node{'b'}]`
// and there exists an edge with weight 3 between these two nodes.
// Then the resulting map will look like this: `{0: [1], 1: [0]}`,
// so here zero and one correspond to the nodes `&Node{'a'}` and `&Node{'b'}` respectively.
pub fn (graph Graph[T]) to_adjacency_weights[T]() map[int]map[int]int {
	mut adj := map[int]map[int]int{}

	mut node_to_int := map[voidptr]int{}
	for i, node in graph.nodes {
		node_to_int[node] = i
		adj[i] = {}
	}

	for edge in graph.edges {
		adj[node_to_int[edge.node1]][node_to_int[edge.node2]] = edge.weight
		adj[node_to_int[edge.node2]][node_to_int[edge.node1]] = edge.weight
	}

	return adj
}

// Gives the (symmetric) adjacency matrix of the graph.
// The order of the rows and columns is exactly the same as the order of the nodes list in the graph object.
pub fn (graph Graph[T]) to_adjacency_matrix[T]() [][]int {
	mut matrix := [][]int{len: graph.nodes.len, init: []int{len: graph.nodes.len}}

	mut ptr_to_index := map[voidptr]int{}
	for i, node in graph.nodes {
		ptr_to_index[node] = i
	}

	for edge in graph.edges {
		i := ptr_to_index[edge.node1]
		j := ptr_to_index[edge.node2]
		matrix[i][j] = edge.weight
		matrix[j][i] = edge.weight
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
