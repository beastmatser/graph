module graphs

pub fn cycle_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n}

	for i in 0 .. n - 1 {
		edges << &Edge[int]{nodes[i], nodes[i + 1]}
	}
	edges << &Edge[int]{nodes[n - 1], nodes[0]}

	return Graph[int]{nodes, edges}
}

pub fn path_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n - 1}

	for i in 0 .. n - 1 {
		edges << &Edge[int]{nodes[i], nodes[i + 1]}
	}

	return Graph[int]{nodes, edges}
}

pub fn complete_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: n * (n - 1) / 2}

	for i in 0 .. n {
		for j in 0 .. n {
			if i < j {
				edges << &Edge[int]{nodes[i], nodes[j]}
			}
		}
	}

	return Graph[int]{nodes, edges}
}

pub fn complete_bipartite_graph(n int, m int) Graph[int] {
	nodes := []&Node[int]{len: n + m, init: &Node{index}}
	mut edges := []&Edge[int]{cap: m * n}

	for i in 0 .. n {
		for j in n .. n + m {
			edges << &Edge[int]{nodes[i], nodes[j]}
		}
	}

	return Graph[int]{nodes, edges}
}

pub fn star_graph(n int) Graph[int] {
	return complete_bipartite_graph(1, n - 1)
}

pub fn wheel_graph(n int) Graph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&Edge[int]{cap: 2 * n - 2}

	for i in 1 .. n - 1 {
		edges << &Edge[int]{nodes[i], nodes[i + 1]}
		edges << &Edge[int]{nodes[0], nodes[i]}
	}
	edges << &Edge[int]{nodes[n - 1], nodes[1]}
	edges << &Edge[int]{nodes[0], nodes[n - 1]}

	return Graph[int]{nodes, edges}
}
