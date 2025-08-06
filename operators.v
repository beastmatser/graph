module graph

// Gives the complement of a graph.
// The list of (references to) nodes is reused,
// so that a change in the original graph also appears in the complement.
// This implies that the complement of the complement the original graph is.
pub fn (gr Graph[T]) complement[T]() Graph[T] {
	mut edges := []&Edge[T]{cap: gr.nodes.len * (gr.nodes.len - 1) / 2 - gr.edges.len}

	mut adjacency := map[int]map[int]int{}
	mut degrees := map[int]int{}
	for node1 in 0 .. gr.nodes.len {
		degrees[node1] = gr.nodes.len - 1 - gr.degrees[node1]
		for node2 in 0 .. gr.nodes.len {
			if node1 < node2 && node2 !in gr.adjacency[node1] {
				adjacency[node1][node2] = edges.len
				adjacency[node2][node1] = edges.len

				edges << &Edge[T]{
					node1: gr.nodes[node1]
					node2: gr.nodes[node2]
				}
			}
		}
	}

	return Graph[T]{gr.nodes, edges, adjacency, gr.node_to_index, degrees}
}

// Gives the line graph of a graph.
// The values of the nodes are the weights of the edges in the original graph.
// So, for a simple graph all nodes will contain the value one.
pub fn (gr Graph[T]) line_graph[T]() Graph[int] {
	nodes := []&Node[int]{len: gr.edges.len, init: &Node[int]{gr.edges[index].weight}}
	mut edges := []&Edge[int]{cap: gr.edges.len}

	mut adjacency := map[int]map[int]int{}
	mut degrees := map[int]int{}

	for i, edge1 in gr.edges {
		for j, edge2 in gr.edges[i + 1..] {
			if edge1.node1 == edge2.node1 || edge1.node1 == edge2.node2
				|| edge1.node2 == edge2.node1 || edge1.node2 == edge2.node2 {
				degrees[i] += 1
				degrees[j] += 1

				adjacency[i][j] = edges.len
				adjacency[j][i] = edges.len

				edges << &Edge[int]{
					node1: nodes[i]
					node2: nodes[j + i + 1]
				}
			}
		}
	}

	return Graph.create[int](nodes, edges)
}

fn update[V](nodes []&Node[V], mut edges []&Edge[V], mut adjacency map[int]map[int]int, mut degrees map[int]int, new_index1 int, new_index2 int) {
	degrees[new_index1] += 1
	degrees[new_index2] += 1

	adjacency[new_index1][new_index2] = edges.len
	adjacency[new_index2][new_index1] = edges.len

	edges << &Edge[V]{
		node1: nodes[new_index1]
		node2: nodes[new_index2]
	}
}

pub fn (gr1 Graph[T]) cartesian_product[T, U, V](gr2 Graph[U], handle fn (x T, y U) V) Graph[V] {
	mut nodes := []&Node[V]{cap: gr1.nodes.len * gr2.nodes.len}
	mut edges := []&Edge[V]{cap: gr1.nodes.len * gr2.nodes.len * (gr1.nodes.len * gr2.nodes.len - 1) / 2}

	mut old_to_new := map[string]int{}
	mut node_to_index := map[voidptr]int{}
	for index1, node1 in gr1.nodes {
		for index2, node2 in gr2.nodes {
			node := &Node[V]{handle(node1.val, node2.val)}
			node_to_index[node] = nodes.len
			old_to_new['${index1},${index2}'] = nodes.len
			nodes << node
		}
	}

	mut adjacency := map[int]map[int]int{}
	mut degrees := map[int]int{}

	for index1 in 0 .. gr1.nodes.len {
		for node2, neighbours in gr2.adjacency {
			for node3, _ in neighbours {
				if node2 > node3 {
					continue
				}
				new_index1 := old_to_new['${index1},${node2}']
				new_index2 := old_to_new['${index1},${node3}']

				update[V](nodes, mut edges, mut adjacency, mut degrees, new_index1, new_index2)
			}
		}
	}

	for index1 in 0 .. gr2.nodes.len {
		for node2, neighbours in gr1.adjacency {
			for node3, _ in neighbours {
				if node2 > node3 {
					continue
				}
				new_index1 := old_to_new['${node2},${index1}']
				new_index2 := old_to_new['${node3},${index1}']

				update[V](nodes, mut edges, mut adjacency, mut degrees, new_index1, new_index2)
			}
		}
	}

	return Graph[V]{nodes, edges, adjacency, node_to_index, degrees}
}
