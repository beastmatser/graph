module undirected

import datatypes { Queue }
import common { Edge }

// Runs a breadth-first search (bfs) on the first node in nodes list of the graph.
// It returns a spanning forrest of the graph.
pub fn (graph UndirectedGraph[T]) bfs[T]() UndirectedGraph[T] {
	mut visited := map[int]bool{}
	for i in 0 .. graph.nodes.len {
		visited[i] = false
	}

	mut edges := []&Edge[T]{cap: graph.nodes.len - 1}
	mut queue := Queue[int]{}
	for i in 0 .. graph.nodes.len {
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

	return UndirectedGraph.create[T](graph.nodes, edges)
}

fn (graph UndirectedGraph[T]) rec_dfs[T](current_index int, node int, mut labels map[int]int, mut edges []&Edge[T]) int {
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

// Runs a depth-first search (dfs) on the first node in nodes list of the graph.
// It returns a spanning forrest of the graph.
pub fn (graph UndirectedGraph[T]) dfs[T]() UndirectedGraph[T] {
	mut labels := map[int]int{}

	// Initialize all labels to 0 (unvisited)
	for node_index in 0 .. graph.nodes.len {
		labels[node_index] = 0
	}

	mut edges := []&Edge[T]{}
	mut traversal_index := 0

	for start_index in 0 .. graph.nodes.len {
		if labels[start_index] == 0 {
			traversal_index = graph.rec_dfs[T](traversal_index, start_index, mut labels, mut
				edges)
		}
	}

	return UndirectedGraph.create[T](graph.nodes, edges)
}
