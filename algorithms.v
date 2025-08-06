module graph

import datatypes
import math

// Runs a breadth-first search (bfs) on a given node of the graph.
// It returns a spanning forrest of the graph.
pub fn (gr Graph[T]) bfs[T]() Graph[T] {
	mut visited := map[voidptr]bool{}

	mut node_to_index := map[voidptr]int{}
	for i, node in gr.nodes {
		node_to_index[node] = i
	}

	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	mut queue := datatypes.Queue[int]{}
	for i, node in gr.nodes {
		if visited[i] {
			continue
		}
		visited[node] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in (gr.adjacency[w] or { continue }).keys() {
				if visited[x] {
					continue
				}

				visited[x] = true
				edges << gr.get_edge(gr.nodes[node_to_index[w]], gr.nodes[node_to_index[x]]) or {
					continue
				}
				queue.push(x)
			}
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

fn (gr Graph[T]) rec_dfs[T](current_index int, node &Node[T], mut labels map[voidptr]int, mut edges []&Edge[T]) int {
	mut next_index := current_index + 1
	labels[node] = next_index

	for neighbour in unsafe { gr.adjacency[node] }.keys() {
		if labels[neighbour] == 0 {
			edges << gr.get_edge(node, neighbour) or { continue }
			next_index = gr.rec_dfs[T](next_index, neighbour, mut labels, mut edges)
		}
	}
	return next_index
}

// Runs a depth-first search (dfs) on a given node of the graph.
// It returns a spanning forrest of the graph.
pub fn (gr Graph[T]) dfs[T]() Graph[T] {
	mut labels := map[voidptr]int{}

	// Initialize all labels to 0 (unvisited)
	for node in gr.nodes {
		labels[node] = 0
	}

	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	mut traversal_index := 0

	for start_node in gr.nodes {
		if labels[start_node] == 0 {
			traversal_index = gr.rec_dfs[T](traversal_index, start_node, mut labels, mut
				edges)
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

pub enum MSTAlgorithm {
	kruskal
	prim
}

// Finds the minimum spanning tree of a graph.
// The possible algorithms are listed in `enum MSTAlgorithm`.
pub fn (gr Graph[T]) mst[T](method MSTAlgorithm) Graph[T] {
	return match method {
		.kruskal { gr.kruskal() }
		.prim { gr.prim() }
	}
}

// Finds a minimum spanning tree of a graph using Kruskal's algorithm.
fn (gr Graph[T]) kruskal[T]() Graph[T] {
	if gr.edges.len == 0 {
		return gr
	}
	mut sorted_edges := gr.edges.clone()
	sorted_edges.sort(a.weight < b.weight)

	mut node_to_index := map[voidptr]int{}
	mut components := []int{cap: gr.nodes.len}
	for i, node in gr.nodes {
		node_to_index[node] = i
		components << i
	}

	index1 := components[node_to_index[sorted_edges[0].node1]]
	index2 := components[node_to_index[sorted_edges[0].node2]]
	min_comp := math.min(index1, index2)
	components[index1] = min_comp
	components[index2] = min_comp

	mut k := 0
	mut edges := [sorted_edges[0]]
	for edges.len < gr.nodes.len - 1 {
		k += 1
		if gr.is_acyclic_kruskal[T](node_to_index, mut components, k, sorted_edges, sorted_edges[k]) {
			edges << sorted_edges[k]
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

fn (gr Graph[T]) is_acyclic_kruskal[T](node_to_index map[voidptr]int, mut components []int, k int, edges []&Edge[T], edge &Edge[T]) bool {
	index1 := components[node_to_index[edges[k].node1]]
	index2 := components[node_to_index[edges[k].node2]]

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
fn (gr Graph[T]) prim[T]() Graph[T] {
	if gr.nodes.len == 0 {
		return gr
	}

	mut edge_to_index := map[voidptr]int{}
	for i, edge in gr.edges {
		edge_to_index[edge] = i
	}

	mut seen := map[voidptr]bool{}
	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	seen[gr.nodes[0]] = true

	// store index and weight from an edge
	mut minhp := datatypes.MinHeap[IndexWeight]{}
	for edge in unsafe { gr.adjacency[gr.nodes[0]] }.values() {
		minhp.insert(IndexWeight{edge_to_index[edge], edge.weight})
	}

	for edges.len < gr.nodes.len - 1 {
		index_weight := minhp.pop() or { break }
		edge := gr.edges[index_weight.index]

		if seen[edge.node1] && seen[edge.node2] {
			continue
		}

		edges << edge

		node := if seen[edge.node1] { edge.node2 } else { edge.node1 }
		seen[node] = true
		for new_edge in (gr.adjacency[node] or { continue }).values() {
			minhp.insert(IndexWeight{edge_to_index[new_edge], new_edge.weight})
		}
	}

	return Graph.create[T](gr.nodes, edges)
}
