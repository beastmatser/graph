module graph

// Check complement involution and structure
fn test_complement() {
	complete7 := complete_graph(7)
	cycle6 := cycle_graph(6)
	path5 := path_graph(5)
	empty := Graph[int]{
		nodes: [&Node{0}, &Node{1}, &Node{2}, &Node{3}]
	}

	assert complete7.edges.len == complete7.complement().complement().edges.len
	assert complete7.nodes.len == complete7.complement().complement().nodes.len

	assert cycle6.nodes.len == cycle6.complement().complement().nodes.len
	assert path5.edges.len == path5.complement().complement().edges.len

	complement_empty := empty.complement()
	assert complement_empty.edges.len == (4 * (4 - 1)) / 2
	assert complement_empty.nodes.len == empty.nodes.len
	assert complement_empty.complement().edges.len == 0
}

// Check line graph construction
fn test_line_graph() {
	triangle := complete_graph(3)
	line := triangle.line_graph()

	assert line.nodes.len == 3
	assert line.edges.len == 3

	p := path_graph(4)
	lp := p.line_graph()
	assert lp.nodes.len == 3
	assert lp.edges.len == 2
}

fn test_cartesian_product() {
	handle := fn (x int, y int) []int {
		return [x, y]
	}

	g1 := path_graph(2)
	g2 := path_graph(2)
	assert g1.cartesian_product(g2, handle).degrees == cycle_graph(4).degrees

	g3 := complete_graph(5)
	g4 := cycle_graph(3)
	println(g3.cartesian_product(g4, handle).degrees.values())
	assert g3.cartesian_product(g4, handle).degrees.values().all(it == 6)
}
