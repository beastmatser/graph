module undirected

// Generates a graph from a mapping with the following signature: `map[T][]T`,
// with `T` any type.
// The keys of the map become the nodes of the graph.
// The values of the map represent the neighbours of their corresponding key.
// Note: if a node is present as a neighbour of another node but not the other way around,
// then some edges can be missing.
// For example, the map `{0: [], 1: [0]}` will result in a graph with two nodes but no edges.
// This is because any node that was already seen in the key values will be skipped if they appear
// in the list of neighbours of another node, in an effort to avoid adding duplicate edges.
pub fn Graph.from_adjacency[T](adj map[T][]T) Graph[T] {
	mut nodes := []&Node[T]{}
	mut edges := []&Edge[T]{}

	mut index := map[T]int{}
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

			edges << &Edge[T]{node1: nodes[index[x]], node2: nodes[index[y]]}
		}
	}

	return Graph[T]{nodes, edges}
}

// Generate a graph from an integer matrix, returns a graph with integer values for the nodes.
// Note that only the upper triangle is checked, since any adjacency matrix of an
// undirected graph should be symmetric. So, it is not required to fill in the whole matrix,
// only the upper triangle is needed to create the graph.
pub fn Graph.from_adjacency_matrix(adj [][]int) Graph[int] {
	nodes := []&Node[int]{len: adj.len, init: &Node{index}}
	mut edges := []&Edge[int]{}

	for i, row in adj {
		for j, col in row {
			if i <= j { // Only check upper triangle of adjacency matrix
				continue
			} else if col != 0 {
				edges << &Edge[int]{node1: nodes[i], node2: nodes[j], weight: col}
			}
		}
	}

	return Graph[int]{nodes, edges}
}

// Generates a graph from a graph6 string, any invalid string will panic.
// For more info visit: https://users.cecs.anu.edu.au/~bdm/data/formats.html.
pub fn Graph.from_graph6(g6 string) Graph[int] {
	runes := g6.runes()
	// use unsigned ints to perform bit shifting
	ascii := []u32{len: runes.len, init: runes[index]}
	if ascii.len == 0 {
		panic('Empty string not allowed')
	} else if ascii.len == 1 {
		assert ascii[0] < 126
	} else {
		assert ascii[0] <= 126
		assert ascii[1] <= 126
	}

	if ascii.len > 2 {
		for a in ascii[2..] {
			if a > 126 {
				panic('Ascii chars should have int value lower or equal to 126')
			}
		}
	}

	mut start := 1
	n := match true {
		ascii[0] == 126 && ascii[1] == 126 {
			start = 8

			((ascii[2] - 63) << 30) + ((ascii[3] - 63) << 24) + ((ascii[4] - 63) << 18) +
				((ascii[5] - 63) << 12) + ((ascii[6] - 63) << 6) + ascii[7] - 63
		}
		ascii[0] == 126 {
			start = 4
			((ascii[1] - 63) << 12) + ((ascii[2] - 63) << 6) + (ascii[3] - 63)
		}
		else {
			ascii[0] - 63
		}
	}

	mut adj_matrix := [][]int{len: int(n), init: []int{len: int(n)}}

	mut flat_bits := []bool{}
	for i in 0 .. runes.len - start - 1 {
		bits := to_bit_vector(u64(ascii[start + i] - 63), 6)
		for b in bits {
			flat_bits << b
		}
	}

	mut bit_index := 0
	for i := 1; i < n; i++ {
		for j := 0; j < i; j++ {
			if bit_index >= flat_bits.len {
				break
			}
			bit := flat_bits[bit_index]
			adj_matrix[i][j] = if bit { 1 } else { 0 } // only fill upper triangle
			bit_index++
		}
	}

	return Graph.from_adjacency_matrix(adj_matrix)
}
