module undirected

import rand

fn test_mst() {
	for i in 0 .. 100 {
		str := random_graph6(rand.i64_in_range(1, 1000) or { 100 }, i / 100)
		graph := Graph.from_graph6(str)
		assert graph.mst(.kruskal).total_weight() == graph.mst(.prim).total_weight()
	}
}
