module graph

// Gives the complement of a graph.
// The list of (references to) nodes is reused,
// so that a change in the original graph also appears in the complement.
// This implies that the complement of the complement the original graph is.
pub fn (gr Graph[T]) complement[T]() Graph[T] {
	mut edges := []&Edge[T]{cap: gr.nodes.len * (gr.nodes.len - 1) / 2 - gr.edges.len}

	mut adjacency := map[voidptr]map[voidptr]&Edge[T]{}
	for i, node1 in gr.nodes {
		for j, node2 in gr.nodes {
			if i < j && node2 !in unsafe { gr.adjacency[node1] } {
				edge := &Edge[T]{
					node1: node1
					node2: node2
				}
				edges << edge
				adjacency[node1][node2] = edge
				adjacency[node2][node1] = edge
			}
		}
	}

	return Graph[T]{adjacency, gr.nodes, edges}
}

// Gives the line graph of a graph.
// The values of the nodes are the weights of the edges in the original graph.
// So, for a simple graph all nodes will contain the value one.
pub fn (gr Graph[T]) line_graph[T]() Graph[int] {
	nodes := []&Node[int]{len: gr.edges.len, init: &Node[int]{gr.edges[index].weight}}
	mut edges := []&Edge[int]{cap: gr.edges.len}

	mut adjacency := map[voidptr]map[voidptr]&Edge[T]{}

	for i, edge1 in gr.edges {
		for j, edge2 in gr.edges[i + 1..] {
			if edge1.node1 == edge2.node1 || edge1.node1 == edge2.node2
				|| edge1.node2 == edge2.node1 || edge1.node2 == edge2.node2 {
				edge := &Edge[int]{
					node1: nodes[i]
					node2: nodes[j + i + 1]
				}
				edges << edge

				adjacency[i][j] = edge
				adjacency[j][i] = edge
			}
		}
	}

	return Graph[int]{adjacency, nodes, edges}
}

fn update[T](mut edges []&Edge[T], mut adjacency map[voidptr]map[voidptr]&Edge[T], new_node1 &Node[T], new_node2 &Node[T]) {
	edge := &Edge[T]{
		node1: new_node1
		node2: new_node2
	}

	edges << edge
	adjacency[new_node1][new_node2] = edge
	adjacency[new_node2][new_node1] = edge
}

pub fn (gr1 Graph[T]) cartesian_product[T, U, V](gr2 Graph[U], handle fn (x T, y U) V) Graph[V] {
	mut nodes := []&Node[V]{cap: gr1.nodes.len * gr2.nodes.len}
	mut edges := []&Edge[V]{cap: gr1.nodes.len * gr2.nodes.len * (gr1.nodes.len * gr2.nodes.len - 1) / 2}

	mut old_to_new := map[string]int{}
	mut node_to_index := map[voidptr]int{}
	for node1 in gr1.nodes {
		for node2 in gr2.nodes {
			node := &Node[V]{handle(node1.val, node2.val)}
			node_to_index[node] = nodes.len
			old_to_new['${voidptr(node1)},${voidptr(node2)}'] = nodes.len
			nodes << node
		}
	}

	mut adjacency := map[voidptr]map[voidptr]&Edge[V]{}

	for node1 in gr1.nodes {
		for node2, neighbours in gr2.adjacency {
			for node3, _ in neighbours {
				if node2 > node3 {
					continue
				}
				new_index1 := old_to_new['${voidptr(node1)},${voidptr(node2)}']
				new_index2 := old_to_new['${voidptr(node1)},${voidptr(node3)}']

				update[V](mut edges, mut adjacency, nodes[new_index1], nodes[new_index2])
			}
		}
	}

	for node1 in gr2.nodes {
		for node2, neighbours in gr1.adjacency {
			for node3, _ in neighbours {
				if node2 > node3 {
					continue
				}
				new_index1 := old_to_new['${voidptr(node2)},${voidptr(node1)}']
				new_index2 := old_to_new['${voidptr(node3)},${voidptr(node1)}']

				update[V](mut edges, mut adjacency, nodes[new_index1], nodes[new_index2])
			}
		}
	}

	return Graph[V]{adjacency, nodes, edges}
}
