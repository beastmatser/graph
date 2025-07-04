module directed

import common { Edge, Node }

// A directed graph is a list of references to nodes and a list of references to (directed) edges made up of these nodes.
pub struct DirectedGraph[T] {
	common.Graph[T]
}

pub fn DirectedGraph.create[T](nodes []&Node[T], edges []&Edge[T]) DirectedGraph[T] {
	return DirectedGraph[T]{common.Graph[T]{nodes, edges}}
}
