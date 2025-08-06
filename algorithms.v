module graph

import datatypes
import math

// Iterator runs from start to stop and then from zero to start.
// For example: if start is 2 and stop 5, then the iterator follows the sequence: 2, 3, 4, 0, 1.
struct ShiftedIterator {
	start int
	stop  int
mut:
	idx  int
	seen bool
}

fn (mut iter ShiftedIterator) next() ?int {
	if (iter.start + iter.idx) % iter.stop == iter.start {
		if iter.seen {
			return none
		}
		iter.seen = true
	}
	defer {
		iter.idx++
	}
	return (iter.start + iter.idx) % iter.stop
}

// Runs a breadth-first search (bfs) on a given node of the graph.
// It returns a spanning forrest of the graph.
pub fn (gr Graph[T]) bfs[T](node &Node[T]) Graph[T] {
	mut visited := map[int]bool{}
	for i in 0 .. gr.nodes.len {
		visited[i] = false
	}

	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	mut queue := datatypes.Queue[int]{}
	for i in ShiftedIterator{
		start: gr.node_to_index[node]
		stop:  gr.nodes.len
	} {
		if visited[i] {
			continue
		}
		visited[i] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in gr.adjacency[w].keys() {
				if visited[x] {
					continue
				}

				visited[x] = true
				edges << gr.get_edge(gr.nodes[w], gr.nodes[x])
				queue.push(x)
			}
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

fn (gr Graph[T]) rec_dfs[T](current_index int, node int, mut labels map[int]int, mut edges []&Edge[T]) int {
	mut next_index := current_index + 1
	labels[current_index] = next_index

	for neighbour in gr.adjacency[current_index].keys() {
		if labels[neighbour] == 0 {
			edges << gr.get_edge(gr.nodes[node], gr.nodes[neighbour])
			next_index = gr.rec_dfs[T](next_index, neighbour, mut labels, mut edges)
		}
	}
	return next_index
}

// Runs a depth-first search (dfs) on a given node of the graph.
// It returns a spanning forrest of the graph.
pub fn (gr Graph[T]) dfs[T](node &Node[T]) Graph[T] {
	mut labels := map[int]int{}

	// Initialize all labels to 0 (unvisited)
	for node_index in 0 .. gr.nodes.len {
		labels[node_index] = 0
	}

	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	mut traversal_index := 0

	for start_index in ShiftedIterator{
		start: gr.node_to_index[node]
		stop:  gr.nodes.len
	} {
		if labels[start_index] == 0 {
			traversal_index = gr.rec_dfs[T](traversal_index, start_index, mut labels, mut
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

	mut components := []int{len: gr.nodes.len, init: index}
	index1 := components[gr.node_to_index[sorted_edges[0].node1]]
	index2 := components[gr.node_to_index[sorted_edges[0].node2]]
	min_comp := math.min(index1, index2)
	components[index1] = min_comp
	components[index2] = min_comp

	mut k := 0
	mut edges := [sorted_edges[0]]
	for edges.len < gr.nodes.len - 1 {
		k += 1
		if gr.is_acyclic_kruskal[T](mut components, k, sorted_edges, sorted_edges[k]) {
			edges << sorted_edges[k]
		}
	}

	return Graph.create[T](gr.nodes, edges)
}

fn (gr Graph[T]) is_acyclic_kruskal[T](mut components []int, k int, edges []&Edge[T], edge &Edge[T]) bool {
	index1 := components[gr.node_to_index[edges[k].node1]]
	index2 := components[gr.node_to_index[edges[k].node2]]

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

	mut seen := map[voidptr]bool{}
	mut edges := []&Edge[T]{cap: gr.nodes.len - 1}
	seen[gr.nodes[0]] = true

	// store index and weight from an edge
	mut minhp := datatypes.MinHeap[IndexWeight]{}
	for i in gr.adjacency[0].values() {
		minhp.insert(IndexWeight{i, gr.edges[i].weight})
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
		node_index := gr.node_to_index[node]
		for edge_index in gr.adjacency[node_index].values() {
			minhp.insert(IndexWeight{edge_index, gr.edges[edge_index].weight})
		}
	}

	return Graph.create[T](gr.nodes, edges)
}
