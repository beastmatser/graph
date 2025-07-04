module undirected

import datatypes { Queue }
import common { Edge, Node }

// Runs a breadth-first search (bfs) on the first node in nodes list of the graph.
// It returns a spanning forrest of the graph.
pub fn (graph UndirectedGraph[T]) bfs[T]() UndirectedGraph[T] {
	mut visited := map[int]bool{}
	nodes := graph.nodes.clone()
	for i in 0 .. nodes.len {
		visited[i] = false
	}

	mut edges := []&Edge[T]{cap: nodes.len - 1}
	mut queue := Queue[int]{}
	for i in 0 .. nodes.len {
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
					node1: nodes[w]
					node2: nodes[x]
				}
				queue.push(x)
			}
		}
	}

	return UndirectedGraph.create[T](nodes, edges)
}

fn rec_dfs[T](i int, adj map[int]map[int]int, mut labels map[int]int, node int, nodes []&Node[T], mut edges []&Edge[T]) int {
	mut j := i + 1
	labels[i] = j
	for k, w in adj[i].keys() {
		if labels[w] == 0 {
			edges << &Edge[T]{
				node1: nodes[node]
				node2: nodes[w]
			}
			j = rec_dfs[T](j, adj, mut labels, k, nodes, mut edges)
		}
	}
	return j
}

// Runs a depth-first search (dfs) on the first node in nodes list of the graph.
// It returns a spanning forrest of the graph.
pub fn (graph UndirectedGraph[T]) dfs[T]() UndirectedGraph[T] {
	mut labels := map[int]int{}
	nodes := graph.nodes.clone()
	for i in 0 .. graph.nodes.len {
		labels[i] = 0
	}

	mut edges := []&Edge[T]{}
	mut i := 0
	for k in 0 .. nodes.len {
		if labels[i] == 0 {
			rec_dfs[T](i, graph.adjacency, mut labels, k, nodes, mut edges)
		}
	}

	return UndirectedGraph.create[T](nodes, edges)
}
