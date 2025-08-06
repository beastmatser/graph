module graph

import arrays
import datatypes
import math

// Returns the number of nodes of a graph, also accessible through `Graph.nodes.len`.
pub fn (gr Graph[T]) num_nodes[T]() int {
	return gr.nodes.len
}

// Returns the number of edges of a graph, also accessible through `Graph.edges.len`.
pub fn (gr Graph[T]) num_edges[T]() int {
	return gr.edges.len
}

// Returns the total weight of all edges of a graph.
pub fn (gr Graph[T]) total_weight() int {
	mut total := 0
	for edge in gr.edges {
		total += edge.weight
	}
	return total
}

// Returns a list of the degrees of the graph, not necessarily ordered.
pub fn (gr Graph[T]) degree_list[T]() []int {
	mut degrees := []int{cap: gr.nodes.len}
	for _, neighbours in gr.adjacency {
		degrees << neighbours.len
	}
	return degrees
}

// Returns the minimum degree of the graph.
pub fn (gr Graph[T]) min_degree[T]() int {
	return arrays.min(gr.degree_list()) or { 0 }
}

// Returns the maximum degree of the graph.
pub fn (gr Graph[T]) max_degree[T]() int {
	return arrays.max(gr.degree_list()) or { 0 }
}

// Returns the density of the graph.
pub fn (gr Graph[T]) density[T]() f32 {
	n := gr.nodes.len
	return 2 * f32(gr.edges.len) / f32(n * (n - 1))
}

// Checks whether the graph is regular.
pub fn (gr Graph[T]) is_regular[T]() bool {
	degrees := gr.degree_list()
	return arrays.min(degrees) or { 0 } == arrays.max(degrees) or { 0 }
}

// Checks whether the graph is a cycle.
pub fn (gr Graph[T]) is_cycle[T]() bool {
	degrees := gr.degree_list()
	return arrays.min(degrees) or { 0 } == 2 && arrays.max(degrees) or { 0 } == 2
}

// Checks whether the graph is a complete graph.
pub fn (gr Graph[T]) is_complete[T]() bool {
	degrees := gr.degree_list()
	return degrees.all(it == gr.nodes.len - 1)
}

// Checks whether the graph is Eulerian.
pub fn (gr Graph[T]) is_eulerian[T]() bool {
	degrees := gr.degree_list()
	return degrees.all(it % 2 == 0)
}

// Checks whether the graph contains an Eulerian path.
pub fn (gr Graph[T]) has_eulerian_path[T]() bool {
	degrees := gr.degree_list()
	return degrees.count(it % 2 == 1) == 2
}

// Checks whether the graph is a tree.
pub fn (gr Graph[T]) is_tree[T]() bool {
	if gr.edges.len != gr.nodes.len - 1 {
		return false
	}

	if gr.nodes.len == 0 {
		return true
	}

	return gr.dfs().edges.len == gr.edges.len
}

// Checks whether the graph is connected.
pub fn (gr Graph[T]) is_connected[T]() bool {
	if gr.nodes.len == 0 {
		return true
	}

	span_tree := gr.dfs()
	return span_tree.edges.len == gr.nodes.len - 1
}

// Returns the number of connected components of the graph.
pub fn (gr Graph[T]) num_connected_components[T]() int {
	if gr.nodes.len == 0 {
		return 0
	}

	return gr.nodes.len - gr.dfs().edges.len
}

// Checks whether the graph is bipartite.
pub fn (gr Graph[T]) is_bipartite[T]() bool {
	mut colours := map[voidptr][2]bool{} // 2 bits per node, 1 for if node is coloured and 1 for the colour itself

	mut queue := datatypes.Queue[voidptr]{}
	for node in gr.nodes {
		if colours[node][0] {
			continue
		}
		colours[node][0] = true
		queue.push(node)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in (gr.adjacency[w] or { continue }).keys() {
				if colours[x][0] {
					if colours[x][1] == colours[w][1] {
						return false
					}
					continue
				}

				colours[x][0] = true
				colours[x][1] = !colours[w][1]
				queue.push(x)
			}
		}
	}

	return true
}

// Checks whether the graph is acyclic, i.e. does not contain a cycle.
// This differs from checking if a graph is a tree, since a graph can be a forrest.
pub fn (gr Graph[T]) is_acyclic[T]() bool {
	mut visited := map[voidptr]bool{}
	mut parents := map[voidptr]voidptr{}

	mut queue := datatypes.Queue[voidptr]{}
	for node in gr.nodes {
		if visited[node] {
			continue
		}
		visited[node] = true
		queue.push(node)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in (gr.adjacency[w] or { continue }).keys() {
				if visited[x] {
					if parents[w] or { continue } != x {
						return false
					}
					continue
				}

				visited[x] = true
				parents[x] = w
				queue.push(x)
			}
		}
	}

	return true
}

// Returns the eccentricity of a given node.
fn (gr Graph[T]) eccentricity[T](node &Node[T]) int {
	mut max_dist := 0

	mut dist := map[voidptr]int{}
	mut visited := map[voidptr]bool{}
	mut queue := datatypes.Queue[voidptr]{}
	visited[node] = true
	dist[node] = 0
	queue.push(node)

	for !queue.is_empty() {
		w := queue.pop() or { continue }
		for x, edge in gr.adjacency[w] or { continue } {
			if visited[x] {
				continue
			}
			visited[x] = true
			dist[x] = dist[w] + edge.weight
			max_dist = if max_dist > dist[x] { max_dist } else { dist[x] }
			queue.push(x)
		}
	}

	return max_dist
}

// Returns the diameter of the graph, this implementation only works for connected graphs.
pub fn (gr Graph[T]) diameter[T]() int {
	mut max_dist := 0

	for node in gr.nodes {
		dist := gr.eccentricity(node)
		if dist > max_dist {
			max_dist = dist
		}
	}

	return max_dist
}

// Returns the radius of the graph, this implementation only works for connected graphs.
pub fn (gr Graph[T]) radius[T]() int {
	if gr.nodes.len == 0 {
		return 0
	}
	mut min_dist := gr.eccentricity(gr.nodes[0])

	for node in gr.nodes[1..] {
		dist := gr.eccentricity(node)
		if dist < min_dist {
			min_dist = dist
		}
	}

	return min_dist
}

// Returns the girth of the graph.
pub fn (gr Graph[T]) girth[T]() int {
	mut min_cycle := -1

	for node in gr.nodes {
		mut dist := map[voidptr]int{}
		mut parent := map[voidptr]voidptr{}
		mut visited := map[voidptr]bool{}
		mut queue := datatypes.Queue[voidptr]{}

		dist[node] = 0
		visited[node] = true
		queue.push(node)

		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in (gr.adjacency[w] or { continue }).keys() {
				if w in parent && unsafe { x == parent[w] } {
					continue
				} else if !visited[x] {
					visited[x] = true
					dist[x] = dist[w] + 1
					parent[x] = w
					queue.push(x)
					continue
				}
				// Found a cycle
				cycle_len := dist[x] + dist[w] + 1
				if min_cycle == -1 {
					min_cycle = cycle_len
				} else if cycle_len < min_cycle {
					min_cycle = cycle_len
				}
			}
		}
	}

	return min_cycle
}

// Returns the number of spanning trees of the graph.
pub fn (gr Graph[T]) num_spanning_trees[T]() f64 {
	mut laplacian := [][]f64{len: gr.nodes.len, init: []f64{len: gr.nodes.len}}

	mut ptr_to_index := map[voidptr]int{}
	for i, node in gr.nodes {
		ptr_to_index[node] = i
	}

	for edge in gr.edges {
		i := ptr_to_index[edge.node1]
		j := ptr_to_index[edge.node2]
		laplacian[i][i] += 1
		laplacian[j][j] += 1
		laplacian[i][j] = -1
		laplacian[j][i] = -1
	}

	// remove last column
	for mut row in laplacian[1..] {
		row.pop()
	}

	return math.abs(math.round(det(laplacian[1..]) or { 0 }))
}

// Returns the number of triangles of the gr.
pub fn (gr Graph[T]) num_triangles[T]() int {
	m := gr.to_adjacency_matrix()
	mut sum := 0
	for i, row in matmul(m, matmul(m, m) or { [] }) or { [] } {
		sum += int(row[i])
	}
	return sum / 6
}

// Returns the degeneracy the gr.
// It implements the algorithm described by Matula and Beck, described [here](https://doi.org/10.1145/2402.322385)
@[unsafe]
pub fn (gr Graph[T]) degeneracy() int {
	n := gr.nodes.len
	mut visited := map[voidptr]bool{}
	mut degree := map[voidptr]int{}
	mut max_deg := 0

	for node in gr.nodes {
		degree[node] = unsafe { gr.adjacency[node] }.len
	}

	mut bucket := map[int][]voidptr{}
	for v, deg in degree {
		if deg !in bucket {
			bucket[deg] = []
		}
		bucket[deg] << v
	}

	mut remaining := n

	for remaining > 0 {
		// Find the smallest non-empty bucket
		mut found := false
		mut current_deg := 0
		for current_deg <= n {
			if current_deg in bucket && bucket[current_deg].len > 0 {
				found = true
				break
			}
			current_deg++
		}
		if !found {
			break // no vertices left to process
		}

		v := bucket[current_deg].pop()
		if visited[v] {
			continue
		}
		visited[v] = true
		remaining--
		if current_deg > max_deg {
			max_deg = current_deg
		}

		for u in gr.adjacency[v].keys() {
			if !visited[u] {
				old_deg := degree[u]
				degree[u]--
				// Remove u from old bucket
				bucket[old_deg] = bucket[old_deg].filter(it != u)
				// Add to new bucket
				if degree[u] !in bucket {
					bucket[degree[u]] = []
				}
				bucket[degree[u]] << u
			}
		}
	}

	return max_deg
}
