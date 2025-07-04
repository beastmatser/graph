module directed

import undirected { Node }

// Generates a directed cycle graph on n nodes.
// The graph's nodes are integer values from 0 to n-1, the edges are i -> i+1 (in modulo n).
pub fn cycle_graph(n int) DirectedGraph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&DirectedEdge[int]{cap: n}

	for i in 0 .. n - 1 {
		edges << &DirectedEdge[int]{tail: nodes[i], head: nodes[i + 1]}
	}
	edges << &DirectedEdge[int]{tail: nodes[n - 1], head: nodes[0]}

	return DirectedGraph[int]{nodes, edges}
}

// Generates a directed path graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1, the edges are i -> i+1 (i=0, ..., n-1).
pub fn path_graph(n int) DirectedGraph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&DirectedEdge[int]{cap: n - 1}

	for i in 0 .. n - 1 {
		edges << &DirectedEdge[int]{tail: nodes[i], head: nodes[i + 1]}
	}

	return DirectedGraph[int]{nodes, edges}
}

// Generates a complete graph on n nodes.
// The nodes of the graph are integers, from 0 to n-1.
pub fn complete_graph(n int) DirectedGraph[int] {
	nodes := []&Node[int]{len: n, init: &Node{index}}
	mut edges := []&DirectedEdge[int]{cap: n * (n - 1) / 2}

	for i in 0 .. n {
		for j in 0 .. n {
			if i < j {
				edges << &DirectedEdge[int]{tail: nodes[i], head: nodes[j]}
			}
		}
	}

	return DirectedGraph[int]{nodes, edges}
}
