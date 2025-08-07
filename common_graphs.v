module graph

// Generates a cycle graph on n nodes.
// The graph's nodes are integer values from 0 to n-1.
pub fn cycle_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n}

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 0 .. n - 1 {
		edge := &Edge[int]{
			node1: nodes[i]
			node2: nodes[i + 1]
		}
		adjacency[edge.node1][edge.node2] = edge
		adjacency[edge.node2][edge.node1] = edge

		edges << edge
	}
	edge := &Edge[int]{
		node1: nodes[n - 1]
		node2: nodes[0]
	}

	adjacency[edge.node1][edge.node2] = edge
	adjacency[edge.node2][edge.node1] = edge
	edges << edge

	return Graph[int]{adjacency, nodes, edges}
}

// Generates a path graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1.
pub fn path_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n - 1}

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 0 .. n - 1 {
		edge := &Edge[int]{
			node1: nodes[i]
			node2: nodes[i + 1]
		}
		adjacency[edge.node1][edge.node2] = edge
		adjacency[edge.node2][edge.node1] = edge

		edges << edge
	}

	return Graph[int]{adjacency, nodes, edges}
}

// Generates a complete graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1.
pub fn complete_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n * (n - 1) / 2}

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 0 .. n {
		for j in 0 .. n {
			if i < j {
				edge := &Edge[int]{
					node1: nodes[i]
					node2: nodes[j]
				}
				adjacency[edge.node1][edge.node2] = edge
				adjacency[edge.node2][edge.node1] = edge

				edges << edge
			}
		}
	}

	return Graph[int]{adjacency, nodes, edges}
}

// Generates a complete bipartite graph on n \times m nodes,
// with respectively n and m nodes in the two partitions of the graph.
// The nodes of the graph are integers, from 0 to n \times (m - 1).
pub fn complete_bipartite_graph(n int, m int) Graph[int] {
	nodes := []&Node[int]{len: n + m, init: &Node{index}}
	mut edges := []&Edge[int]{cap: m * n}

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 0 .. n {
		for j in n .. n + m {
			edge := &Edge[int]{
				node1: nodes[i]
				node2: nodes[j]
			}
			adjacency[edge.node1][edge.node2] = edge
			adjacency[edge.node2][edge.node1] = edge

			edges << edge
		}
	}

	return Graph[int]{adjacency, nodes, edges}
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

	mut adjacency := map[voidptr]map[voidptr]&Edge[int]{}

	for i in 1 .. n - 1 {
		edge1 := &Edge[int]{
			node1: nodes[i]
			node2: nodes[i + 1]
		}
		adjacency[edge1.node1][edge1.node2] = edge1
		adjacency[edge1.node2][edge1.node1] = edge1

		edges << edge1

		edge2 := &Edge[int]{
			node1: nodes[0]
			node2: nodes[i]
		}
		adjacency[edge2.node1][edge2.node2] = edge2
		adjacency[edge2.node2][edge2.node1] = edge2

		edges << edge2
	}
	edge1 := &Edge[int]{
		node1: nodes[n - 1]
		node2: nodes[1]
	}
	adjacency[edge1.node1][edge1.node2] = edge1
	adjacency[edge1.node2][edge1.node1] = edge1

	edges << edge1

	edge2 := &Edge[int]{
		node1: nodes[0]
		node2: nodes[n - 1]
	}
	adjacency[edge2.node1][edge2.node2] = edge2
	adjacency[edge2.node2][edge2.node1] = edge2

	edges << edge2

	return Graph[int]{adjacency, nodes, edges}
}
