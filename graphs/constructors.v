module graphs

pub fn Graph.from_adjacency[T](adj map[T][]T) Graph[T] {
	mut nodes := []&Node[T]{}
	mut edges := []&Edge[T]{}

	mut index := map[T]int
	for i, x in adj.keys() {
		nodes << &Node[T]{x}
		index[x] = i
	}

	mut seen := []T{}
	for x, neighbours in adj {
		seen << x
		for y in neighbours {
			if y in seen {
				continue
			}

			edges << &Edge[T]{nodes[index[x]], nodes[index[y]]}
		}
	}

	return Graph[T]{nodes, edges}
}


// pub fn Graph.from_adjacency_matrix[T](adj [][]bool) Graph[int]
// pub fn Graph.from_graph6(s string) Graph[int]
