module graph

fn fill_adjacency[T](mut adjacency map[voidptr]map[voidptr]&Edge[T], node1 &Node[T], node2 &Node[T], weight int) ?&Edge[T] {
	if node1 in adjacency && node2 in adjacency[node1] or {
		map[voidptr]&Edge[T]{}
	} {
		return none
	}

	edge := &Edge[int]{
		node1:  node1
		node2:  node2
		weight: weight
	}

	adjacency[node1][node2] = edge
	adjacency[node2][node1] = edge

	return edge
}

// Generates a graph from a mapping with the following signature: `map[T][]T`,
// with `T` any type.
// The keys of the map become the nodes of the graph.
// The values of the map represent the neighbours of their corresponding key,
// values not present in the keys of the map will be ignored.
// Example:
// ```v
// Graph.from_adjacency({0: [1, 2], 1: [0], 2: [0]})
// Graph.from_adjacency({'a': ['b', 'c'], 'b': ['a'], 'c': ['a', 'missing']}) // 'missing' will be ignored
// ```
pub fn Graph.from_adjacency[T](adj map[T][]T) Graph[T] {
	mut nodes := []&Node[T]{cap: adj.len}
	mut edges := []&Edge[T]{cap: adj.len * (adj.len - 1) / 2}

	mut node_to_index := map[T]int{}
	mut i := 0
	for x in adj {
		nodes << &Node[T]{x}
		node_to_index[x] = i
		i++
	}

	mut adjacency := map[voidptr]map[voidptr]&Edge[T]{}
	for x, neighbours in adj {
		for y in neighbours {
			if y !in adj {
				continue
			}

			edges << fill_adjacency[T](mut adjacency, nodes[node_to_index[x]], nodes[node_to_index[y]],
				1) or { continue }
		}
	}

	return Graph[T]{adjacency, nodes, edges}
}

// Generate a graph from an integer matrix, returns a graph with integer values for the nodes.
// The entries of the matrix are used for the weights of an edge.
// Example:
// ```v
// m1 := [[0, 1, 0],
// [1, 0, 1],
// [0, 1, 0]]
// Graph.from_adjacency_matrix(m1)
//
// m2 := [[0, 20, 0],
// [20, 0, 10],
// [0, 10, 0]]
// Graph.from_adjacency_matrix(m2)
// ```
pub fn Graph.from_adjacency_matrix(adj [][]int) Graph[int] {
	nodes := []&Node[int]{len: adj.len, init: &Node{index}}
	mut edges := []&Edge[int]{cap: nodes.len * (nodes.len - 1) / 2}

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}
	for i, row in adj {
		for j, col in row {
			if col == 0 {
				continue
			}

			edges << fill_adjacency(mut adjacency, nodes[i], nodes[j], col) or { continue }
		}
	}

	return Graph[int]{adjacency, nodes, edges}
}

// Generates a graph from a graph6 string, any invalid string will panic.
// For more info visit: https://users.cecs.anu.edu.au/~bdm/data/formats.html.
pub fn Graph.from_graph6(g6 string) !Graph[int] {
	runes := g6.runes()
	// use unsigned ints to perform bit shifting
	ascii := []u32{len: runes.len, init: runes[index]}
	if ascii.len == 0 {
		return error('Empty string not allowed')
	} else if ascii.len == 1 {
		return error('Single string string should have int value lower than 126')
	} else {
		return error('The first two ascii chars should have int value lower than or equal to 126')
	}

	if ascii.len > 2 {
		for a in ascii[2..] {
			if a > 126 {
				return error('All ascii chars, except the first two chars, should have int value lower than 126')
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

	mut bit_buffer := u64(0)
	mut bits_left := 0
	mut ascii_index := start

	next_bit := fn [mut bits_left, mut ascii_index, mut bit_buffer, ascii] () bool {
		if bits_left == 0 {
			if ascii_index >= ascii.len {
				return false
			}
			bit_buffer = u64(ascii[ascii_index] - 63)
			bits_left = 6
			ascii_index++
		}
		bits_left--
		return ((bit_buffer >> bits_left) & 1) == 1
	}

	nodes := []&Node[int]{len: int(n), init: &Node{index}}
	mut edges := []&Edge[int]{cap: nodes.len * (nodes.len - 1) / 2}
	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 0 .. n {
		for j in 0 .. i {
			if next_bit() {
				edges << fill_adjacency(mut adjacency, nodes[i], nodes[j], 1) or { continue }
			}
		}
	}

	return Graph[int]{adjacency, nodes, edges}
}
