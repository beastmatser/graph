module undirected

import arrays
import datatypes { Queue }
import math
import util
import common { Node }

// Returns a list of the degrees of the graph, not necessarily ordered.
pub fn (graph UndirectedGraph[T]) degree_list[T]() []int {
	return graph.degrees.values()
}

// Returns the minimum degree of the graph.
pub fn (graph UndirectedGraph[T]) min_degree[T]() int {
	return arrays.min(graph.degree_list()) or { 0 }
}

// Returns the maximum degree of the graph.
pub fn (graph UndirectedGraph[T]) max_degree[T]() int {
	return arrays.max(graph.degree_list()) or { 0 }
}

// Returns the density of the graph.
pub fn (graph UndirectedGraph[T]) density[T]() f32 {
	n := graph.nodes.len
	return 2 * f32(graph.edges.len) / f32(n * (n - 1))
}

// Checks whether the graph is regular.
pub fn (graph UndirectedGraph[T]) is_regular[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == arrays.max(degrees) or { 0 }
}

// Checks whether the graph is a cycle.
pub fn (graph UndirectedGraph[T]) is_cycle[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == 2 && arrays.max(degrees) or { 0 } == 2
}

// Checks whether the graph is a complete graph.
pub fn (graph UndirectedGraph[T]) is_complete[T]() bool {
	degrees := graph.degree_list()
	n := graph.nodes.len
	return degrees.all(it == n - 1)
}

// Checks whether the graph is Eulerian.
pub fn (graph UndirectedGraph[T]) is_eulerian[T]() bool {
	degrees := graph.degree_list()
	return degrees.all(it % 2 == 0)
}

// Checks whether the graph contains an Eulerian path.
pub fn (graph UndirectedGraph[T]) has_eulerian_path[T]() bool {
	degrees := graph.degree_list()
	return degrees.count(it % 2 == 1) == 2
}

// Checks whether the graph is a tree.
pub fn (graph UndirectedGraph[T]) is_tree[T]() bool {
	if graph.edges.len != graph.nodes.len - 1 {
		return false
	}

	return graph.dfs().edges.len == graph.edges.len
}

// Checks whether the graph is connected.
pub fn (graph UndirectedGraph[T]) is_connected[T]() bool {
	span_tree := graph.dfs()
	return span_tree.edges.len == span_tree.nodes.len
}

// Returns the number of connected components of the graph.
pub fn (graph Graph[T]) num_connected_components[T]() int {
	return graph.nodes.len - graph.dfs().edges.len
}

// Checks whether the graph is bipartite.
pub fn (graph UndirectedGraph[T]) is_bipartite[T]() bool {
	mut colours := map[int][2]bool{} // 2 bits per node, 1 for if node is coloured and 1 for the colour itself
	for i in 0 .. graph.nodes.len {
		colours[i] = [false, false]!
	}

	mut queue := Queue[int]{}
	for i in 0 .. graph.nodes.len {
		if colours[i][0] {
			continue
		}
		colours[i][0] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in graph.adjacency[w].keys() {
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
pub fn (graph UndirectedGraph[T]) is_acyclic[T]() bool {
	mut visited := map[int]bool{}
	mut parents := map[int]int{}
	for i in 0 .. graph.nodes.len {
		visited[i] = false
	}

	mut queue := Queue[int]{}
	for i in 0 .. graph.nodes.len {
		if visited[i] {
			continue
		}
		visited[i] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in graph.adjacency[w].keys() {
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

fn (graph UndirectedGraph[T]) eccentricity_helper[T](node int) int {
	mut max_dist := 0

	mut dist := map[int]int{}
	mut visited := map[int]bool{}
	mut queue := Queue[int]{}
	visited[node] = true
	dist[node] = 0
	queue.push(node)

	for !queue.is_empty() {
		w := queue.pop() or { continue }
		for x, weight in graph.adjacency[w] {
			if visited[x] {
				continue
			}
			visited[x] = true
			dist[x] = dist[w] + weight
			max_dist = if max_dist > dist[x] { max_dist } else { dist[x] }
			queue.push(x)
		}
	}

	return max_dist
}

// Returns the eccentricity of a given node.
pub fn (graph UndirectedGraph[T]) eccentricity[T](node &Node[T]) int {
	return graph.eccentricity_helper(graph.nodes.index(node))
}

// Returns the diameter of the graph, this implementation only works for connected graphs.
pub fn (graph UndirectedGraph[T]) diameter[T]() int {
	mut max_dist := 0

	for i in 0 .. graph.nodes.len {
		dist := graph.eccentricity_helper(i)
		if dist > max_dist {
			max_dist = dist
		}
	}

	return max_dist
}

// Returns the radius of the graph, this implementation only works for connected graphs.
pub fn (graph UndirectedGraph[T]) radius[T]() int {
	if graph.nodes.len == 0 {
		return 0
	}
	mut min_dist := graph.eccentricity_helper(0)

	for i in 0 .. graph.nodes[1..].len {
		dist := graph.eccentricity_helper(i)
		if dist < min_dist {
			min_dist = dist
		}
	}

	return min_dist
}

// Returns the girth of the graph.
pub fn (graph UndirectedGraph[T]) girth[T]() int {
	mut min_cycle := -1

	for i in 0 .. graph.nodes.len {
		mut dist := map[int]int{}
		mut parent := map[int]int{}
		mut visited := map[int]bool{}
		mut queue := Queue[int]{}

		dist[i] = 0
		visited[i] = true
		queue.push(i)

		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in graph.adjacency[w].keys() {
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
pub fn (graph UndirectedGraph[T]) num_spanning_trees[T]() f64 {
	mut laplacian := [][]f64{len: graph.nodes.len, init: []f64{len: graph.nodes.len}}

	mut ptr_to_index := map[voidptr]int{}
	for i, node in graph.nodes {
		ptr_to_index[node] = i
	}

	for edge in graph.edges {
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

	return math.abs(math.round(util.det(laplacian[1..]) or { 0 }))
}

// Returns the number of triangles of the graph.
pub fn (graph UndirectedGraph[T]) num_triangles[T]() int {
	m := graph.to_adjacency_matrix()
	mut sum := 0
	for i, row in util.matmul(m, util.matmul(m, m) or { [] }) or { [] } {
		sum += int(row[i])
	}
	return sum / 6
}

// Returns the degeneracy the graph.
// It implements the algorithm described by Matula and Beck, described [here](https://doi.org/10.1145/2402.322385)
pub fn (graph UndirectedGraph[T]) degeneracy() int {
	n := graph.nodes.len
	mut visited := map[int]bool{}
	mut degree := map[int]int{}
	mut max_deg := 0

	for i in 0 .. n {
		degree[i] = graph.adjacency[i].len
		visited[i] = false
	}

	mut bucket := map[int][]int{}
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

		for u in graph.adjacency[v].keys() {
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
