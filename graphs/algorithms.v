module graphs

import datatypes { Queue }

pub fn (graph Graph[T]) bfs[T]() Graph[T] {
	mut labels := map[voidptr]int{}
	for node in graph.nodes {
		labels[node] = 0
	}

	adj := graph.to_adjacency()
	mut edges := []&Edge[T]{cap: graph.nodes.len - 1}
	mut queue := Queue[voidptr]{}
	mut i := 0
	for node in graph.nodes {
		if labels[node] != 0 {
			continue
		}
		i += 1
		labels[node] = i
		queue.push(node)
		for !queue.is_empty() {
			w := queue.pop() or { 0 }
			if w == 0 {
				continue
			}

			for x in adj[w] or { [] } {
				if labels[x] != 0 {
					continue
				}
				i += 1
				labels[x] = i
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

