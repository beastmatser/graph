module graphs

pub struct Node[T] {
pub mut:
	x T
}

pub struct Edge[T] {
pub:
	node1 &Node[T]
	node2 &Node[T]
}

pub struct Graph[T] {
pub:
	nodes []&Node[T]
	edges []&Edge[T]
}
