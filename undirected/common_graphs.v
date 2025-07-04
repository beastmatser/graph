module undirected

// Generates a cycle graph on n nodes.
// The graph's nodes are integer values from 0 to n-1.
pub fn cycle_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n}

	for i in 0 .. n - 1 {
		edges << &Edge[int]{node1: nodes[i], node2: nodes[i + 1]}
	}
	edges << &Edge[int]{node1: nodes[n - 1], node2: nodes[0]}

	return Graph[int]{nodes, edges}
}

// Generates a path graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1.
pub fn path_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n - 1}

	for i in 0 .. n - 1 {
		edges << &Edge[int]{node1: nodes[i], node2: nodes[i + 1]}
	}

	return Graph[int]{nodes, edges}
}

// Generates a complete graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1.
pub fn complete_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n * (n - 1) / 2}

	for i in 0 .. n {
		for j in 0 .. n {
			if i < j {
				edges << &Edge[int]{node1: nodes[i], node2: nodes[j]}
			}
		}
	}

	return Graph[int]{nodes, edges}
}

// Generates a complete bipartite graph on n x m nodes,
// with respectively n and m nodes in the two partitions of the graph.
// The nodes of the graph are integers, from 0 to n x (m - 1).
pub fn complete_bipartite_graph(n int, m int) Graph[int] {
	nodes := []&Node[int]{len: n + m, init: &Node{index}}
	mut edges := []&Edge[int]{cap: m * n}

	for i in 0 .. n {
		for j in n .. n + m {
			edges << &Edge[int]{node1: nodes[i], node2: nodes[j]}
		}
	}

	return Graph[int]{nodes, edges}
}

// Generates a star graph on n nodes.
// In this case a star graph on n nodes has n-1 leaves and a center.
// The nodes of the graph are integers, from 0 to n-1.
pub fn star_graph(n int) Graph[int] {
	return complete_bipartite_graph(1, n - 1)
}

// Generates a wheel graph on n nodes.
// In this case a wheel graph on n nodes has n-1 nodes with degree three and one node with degree n-1.
// The nodes of the graph are integers, from 0 to n-1.
pub fn wheel_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: 2 * n - 2}

	for i in 1 .. n - 1 {
		edges << &Edge[int]{node1: nodes[i], node2: nodes[i + 1]}
		edges << &Edge[int]{node1: nodes[0], node2: nodes[i]}
	}
	edges << &Edge[int]{node1: nodes[n - 1], node2: nodes[1]}
	edges << &Edge[int]{node1: nodes[0], node2: nodes[n - 1]}

	return Graph[int]{nodes, edges}
}
