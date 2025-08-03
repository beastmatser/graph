module graph

import rand

fn test_mst() {
	for i in 0 .. 100 {
		str := random_graph6(rand.i64_in_range(1, 1000) or { 100 }, i / 100)
		random_graph := Graph.from_graph6(str) or { continue }
		assert random_graph.mst(.kruskal).total_weight() == random_graph.mst(.prim).total_weight()
	}

	mut cycle50 := cycle_graph(50)
	for i, mut edge in cycle50.edges {
		edge.weight = i
	}
	assert cycle50.mst(.kruskal).total_weight() == 48 * 49 / 2
	assert cycle50.mst(.prim).total_weight() == 48 * 49 / 2
}
