module graphs

import datatypes { Queue }

pub fn (graph Graph[T]) bfs[T]() Graph[T] {
	mut visited := map[int]bool{}
	nodes := graph.nodes.clone()
	for i in 0 .. nodes.len {
		visited[i] = false
	}

	adj := graph.to_adjacency()
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

			for x in adj[w] or { [] } {
				if visited[x] {
					continue
				}

				visited[x] = true
				edges << &Edge[T]{nodes[w], nodes[x]}
				queue.push(x)
			}
		}
	}

	return Graph[T]{nodes, edges}
}

fn rec_dfs[T](i int, adj map[int][]int, mut labels map[int]int, node int, nodes []&Node[T], mut edges []&Edge[T]) int {
	mut j := i + 1
	labels[i] = j
	for k, w in adj[i] or { [] } {
		if labels[w] == 0 {
			edges << &Edge[T]{nodes[node], nodes[w]}
			j = rec_dfs[T](j, adj, mut labels, k, nodes, mut edges)
		}
	}
	return j
}

pub fn (graph Graph[T]) dfs[T]() Graph[T] {
	mut labels := map[int]int{}
	nodes := graph.nodes.clone()
	for i in 0 .. graph.nodes.len {
		labels[i] = 0
	}

	mut edges := []&Edge[T]{}
	adj := graph.to_adjacency()
	mut i := 0
	for k in 0 .. nodes.len {
		if labels[i] == 0 {
			rec_dfs[T](i, adj, mut labels, k, nodes, mut edges)
		}
	}

	return Graph[T]{nodes, edges}
}
