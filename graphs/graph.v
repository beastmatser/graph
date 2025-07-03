module graphs

// A node that contains a value of type `T` in the mutable field `x`.
// Nodes are stored on the heap to ensure stable references to them.
@[heap]
pub struct Node[T] {
pub mut:
	x T
}

// An edge contains two references to nodes of type `T`.
pub struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
}

// A graph is a list of references to nodes and a list of references to edges made up of these nodes.
pub struct Graph[T] {
pub:
	nodes []&Node[T]
	edges []&Edge[T]
}
