module graphs

import datatypes { Queue }

pub fn (graph Graph[T]) bfs[T]() Graph[T] {
	mut visited := map[voidptr]bool{}
	for node in graph.nodes {
		visited[node] = false
	}

	adj := graph.to_adjacency()
	mut edges := []&Edge[T]{cap: graph.nodes.len - 1}
	mut queue := Queue[voidptr]{}
	for node in graph.nodes {
		if visited[node] {
			continue
		}
		visited[node] = true
		queue.push(node)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in adj[w] or { [] } {
				if visited[x] {
					continue
				}

				visited[x] = true
				edges << &Edge[T]{w, x}
				queue.push(x)
			}
		}
	}

	return Graph[T]{graph.nodes, edges}
}

fn rec_dfs[T](i int, adj map[voidptr][]&Node[T], mut labels map[voidptr]int, v &Node[T], mut edges []&Edge[T]) int {
	mut j := i + 1
	labels[v] = j
	for w in adj[v] or { [] } {
		if labels[w] == 0 {
			edges << &Edge[T]{v, w}
			j = rec_dfs[T](j, adj, mut labels, w, mut edges)
		}
	}
	return j
}

pub fn (graph Graph[T]) dfs[T]() Graph[T] {
	mut labels := map[voidptr]int{}
	for node in graph.nodes {
		labels[node] = 0
	}

	mut edges := []&Edge[T]{}
	adj := graph.to_adjacency()
	mut i := 0
	for node in graph.nodes {
		if labels[node] == 0 {
			rec_dfs[T](i, adj, mut labels, node, mut edges)
		}
	}

	return Graph[T]{graph.nodes, edges}
}

