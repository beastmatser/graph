module undirected

import datatypes { MinHeap, Queue }
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
// In a directed graph at the iteration where a certain node is considered,
// only outgoing edges will be added to the forrest.
pub fn (graph Graph[T]) bfs[T](node &Node[T]) Graph[T] {
	mut visited := map[int]bool{}
	for i in 0 .. graph.nodes.len {
		visited[i] = false
	}

	mut edges := []&Edge[T]{cap: graph.nodes.len - 1}
	mut queue := Queue[int]{}
	for i in ShiftedIterator{
		start: graph.node_to_index[node]
		stop:  graph.nodes.len
	} {
		if visited[i] {
			continue
		}
		visited[i] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in graph.adjacency[w].keys() {
				if visited[x] {
					continue
				}

				visited[x] = true
				edges << &Edge[T]{
					node1: graph.nodes[w]
					node2: graph.nodes[x]
				}
				queue.push(x)
			}
		}
	}

	return Graph.create[T](graph.nodes, edges)
}

fn (graph Graph[T]) rec_dfs[T](current_index int, node int, mut labels map[int]int, mut edges []&Edge[T]) int {
	mut next_index := current_index + 1
	labels[current_index] = next_index

	for neighbour in graph.adjacency[current_index].keys() {
		if labels[neighbour] == 0 {
			edges << &Edge[T]{
				node1: graph.nodes[node]
				node2: graph.nodes[neighbour]
			}
			next_index = graph.rec_dfs[T](next_index, neighbour, mut labels, mut edges)
		}
	}
	return next_index
}

// Runs a depth-first search (dfs) on a given node of the graph.
// It returns a spanning forrest of the graph.
// In a directed graph only outgoing edges (from the node at a certain point in the iteration)
// will be added to the forrest;
pub fn (graph Graph[T]) dfs[T](node &Node[T]) Graph[T] {
	mut labels := map[int]int{}

	// Initialize all labels to 0 (unvisited)
	for node_index in 0 .. graph.nodes.len {
		labels[node_index] = 0
	}

	mut edges := []&Edge[T]{}
	mut traversal_index := 0

	for start_index in ShiftedIterator{
		start: graph.node_to_index[node]
		stop:  graph.nodes.len
	} {
		if labels[start_index] == 0 {
			traversal_index = graph.rec_dfs[T](traversal_index, start_index, mut labels, mut
				edges)
		}
	}

	return Graph.create[T](graph.nodes, edges)
}

pub enum MSTAlgorithm {
	kruskal
	prim
}

// Finds the minimum spanning tree of a graph.
// The possible algorithms are listed in `enum MSTAlgorithm`.
pub fn (graph Graph[T]) mst[T](method MSTAlgorithm) Graph[T] {
	return match method {
		.kruskal { graph.kruskal() }
		.prim { graph.prim() }
	}
}

// Finds a minimum spanning tree of a graph using Kruskal's algorithm.
fn (graph Graph[T]) kruskal[T]() Graph[T] {
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

	return Graph.create[T](graph.nodes, edges)
}

fn (graph Graph[T]) is_acyclic_kruskal[T](mut components []int, k int, edges []&Edge[T], edge &Edge[T]) bool {
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
fn (graph Graph[T]) prim[T]() Graph[T] {
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

	return Graph.create[T](graph.nodes, edges)
}
