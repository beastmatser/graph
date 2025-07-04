module undirected

import common { Node, Edge }

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
pub struct UndirectedGraph[T] {
	common.Graph[T]
}

pub fn UndirectedGraph.create[T](nodes []&Node[T], edges []&Edge[T]) UndirectedGraph[T] {
	return UndirectedGraph[T]{common.Graph[T]{nodes, edges}}
}
