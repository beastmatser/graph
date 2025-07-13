module undirected

import datatypes { MinHeap }
import math
import common { Edge }

// Finds a minimum spanning tree of a graph using Kruskal's algorithm.
pub fn (graph UndirectedGraph[T]) kruskal[T]() UndirectedGraph[T] {
	if graph.edges.len == 0 {
		return graph
	}
	mut sorted_edges := graph.edges.clone()
	sorted_edges.sort(a.weight < b.weight)

	mut components := []int{len: graph.nodes.len, init: index}
	index1 := components[graph.node_to_index[sorted_edges[0].node1]]
	index2 := components[graph.node_to_index[sorted_edges[0].node2]]
	min_comp := math.min(index1, index2)
	components[index1] = min_comp
	components[index2] = min_comp

	mut k := 0
	mut edges := [sorted_edges[0]]
	for edges.len < graph.nodes.len - 1 {
		k += 1
		if graph.is_acyclic_kruskal[T](mut components, k, sorted_edges, sorted_edges[k]) {
			edges << sorted_edges[k]
		}
	}

	return UndirectedGraph.create[T](graph.nodes, edges)
}

fn (graph UndirectedGraph[T]) is_acyclic_kruskal[T](mut components []int, k int, edges []&Edge[T], edge &Edge[T]) bool {
	index1 := components[graph.node_to_index[edges[k].node1]]
	index2 := components[graph.node_to_index[edges[k].node2]]

	if index1 == index2 {
		return false
	}

	min_comp := math.min(index1, index2)
	max_comp := math.max(index1, index2)

	for mut node in components {
		if node == max_comp {
			node = min_comp
		}
	}

	return true
}

// To use as elements in the heap in Prim's algorithm,
// since &Edge[T] as an element of the heap causes trouble.
// Saves indices of edge in the edges list of the graph
// and its weight, which is used to sort the heap.
struct IndexWeight {
	index  int
	weight int
}

fn (i1 IndexWeight) < (i2 IndexWeight) bool {
	return i1.weight < i2.weight
}

// Finds a minimum spanning tree of a graph using Prim's algorithm.
// It is implemented using V's builtin `MinHeap`.
pub fn (graph UndirectedGraph[T]) prim[T]() UndirectedGraph[T] {
	if graph.nodes.len == 0 {
		return graph
	}

	mut seen := map[voidptr]bool{}
	mut edges := []&Edge[T]{}
	seen[graph.nodes[0]] = true

	// store index and weight from an edge
	mut minhp := MinHeap[IndexWeight]{}
	for i in graph.adjacency[0].values() {
		minhp.insert(IndexWeight{i, graph.edges[i].weight})
	}

	for edges.len < graph.nodes.len - 1 {
		index_weight := minhp.pop() or { break }
		edge := graph.edges[index_weight.index]

		if seen[edge.node1] && seen[edge.node2] {
			continue
		}

		edges << edge

		node := if seen[edge.node1] { edge.node2 } else { edge.node1 }
		seen[node] = true
		node_index := graph.node_to_index[node]
		for edge_index in graph.adjacency[node_index].values() {
			minhp.insert(IndexWeight{edge_index, graph.edges[edge_index].weight})
		}
	}

	return UndirectedGraph.create[T](graph.nodes, edges)
}
