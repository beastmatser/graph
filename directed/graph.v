module directed

import undirected { Node }

// A directed edge contains two references to nodes, a tail and a head, of type `T`.
pub struct DirectedEdge[T] {
pub:
	tail &Node[T]
	head &Node[T]
pub mut:
	weight int = 1
}

// A directed graph is a list of references to nodes and a list of references to (directed) edges made up of these nodes.
pub struct DirectedGraph[T] {
pub:
	nodes []&Node[T]
	edges []&DirectedEdge[T]
}
