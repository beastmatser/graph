module graph

fn test_dynamic() {
	mut g := Graph.create[int]([], [])
	g.add_node(&Node{0}) or {}
	g.add_node(&Node{1}) or {}
	g.add_node(&Node{2}) or {}
	g.add_node(&Node{3}) or {}

	mut num_fails := 0
	g.add_nodes([g.nodes[0], &Node{4}]) or { num_fails++ }
	assert g.nodes.len == 4

	// Remove node that doesn't exist
	g.remove_node(&Node{4}) or { num_fails++ }

	// Remove edge that doesn't exist
	g.remove_edge(&Edge[int]{g.nodes[0], &Node{3}, 1}) or { num_fails++ }

	g.add_edge(&Edge[int]{ node1: g.nodes[0], node2: g.nodes[1] }) or { assert false }
	g.add_edge(&Edge[int]{ node1: g.nodes[1], node2: g.nodes[2] }) or { assert false }

	// Add edge that already exists
	g.add_edge(&Edge[int]{ node1: g.nodes[1], node2: g.nodes[2] }) or { num_fails++ }

	// Add edge with a node not in the graph
	g.add_edge(&Edge[int]{ node1: &Node{0}, node2: g.nodes[2] }) or { num_fails++ }

	g.add_edges([g.edges[0], &Edge[int]{node1: g.nodes[2], node2: g.nodes[3]}]) or { num_fails++ }
	assert g.edges.len == 2

	assert num_fails == 6
}
