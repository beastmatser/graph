module graphs

import arrays
import datatypes { Queue }
import math

// Returns the number of nodes of a graph, also accessible through `graph.nodes.len`.
pub fn (graph Graph[T]) num_nodes[T]() int {
	return graph.nodes.len
}

// Returns the number of edges of a graph, also accessible through `graph.edges.len`.
pub fn (graph Graph[T]) num_edges[T]() int {
	return graph.edges.len
}

// Returns a map of the degrees of the graph.
// The keys are the indices of the nodes in the node list of the graph
// and the values are the degrees of the nodes.
pub fn (graph Graph[T]) degree_map[T]() map[int]int {
	mut degrees := map[int]int{}
	mut node_to_int := map[voidptr]int{}
	for i, node in graph.nodes {
		node_to_int[node] = i
		degrees[i] = 0
	}

	for edge in graph.edges {
		degrees[node_to_int[edge.node1]] += 1
		degrees[node_to_int[edge.node2]] += 1
	}

	return degrees
}

// Returns a list of the degrees of the graph, not necessarily ordered.
pub fn (graph Graph[T]) degree_list[T]() []int {
	return graph.degree_map().values()
}

// Returns the minimum degree of the graph.
pub fn (graph Graph[T]) min_degree[T]() int {
	return arrays.min(graph.degree_list()) or { 0 }
}

// Returns the maximum degree of the graph.
pub fn (graph Graph[T]) max_degree[T]() int {
	return arrays.max(graph.degree_list()) or { 0 }
}

// Returns the density of the graph.
pub fn (graph Graph[T]) density[T]() f32 {
	n := graph.nodes.len
	return 2 * f32(graph.edges.len) / f32(n * (n - 1))
}

// Checks whether the graph is regular.
pub fn (graph Graph[T]) is_regular[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == arrays.max(degrees) or { 0 }
}

// Checks whether the graph is a cycle.
pub fn (graph Graph[T]) is_cycle[T]() bool {
	degrees := graph.degree_list()
	return arrays.min(degrees) or { 0 } == 2 && arrays.max(degrees) or { 0 } == 2
}

// Checks whether the graph is a complete graph.
pub fn (graph Graph[T]) is_complete[T]() bool {
	degrees := graph.degree_list()
	n := graph.nodes.len
	return arrays.min(degrees) or { 0 } == n - 1 && arrays.max(degrees) or { 0 } == n - 1
}

// Checks whether the graph is Eulerian.
pub fn (graph Graph[T]) is_eulerian[T]() bool {
	degrees := graph.degree_list()
	return degrees.all(it % 2 == 0)
}

// Checks whether the graph contains an Eulerian path.
pub fn (graph Graph[T]) has_eulerian_path[T]() bool {
	degrees := graph.degree_list()
	return degrees.count(it % 2 == 1) == 2
}

// Checks whether the graph is a tree.
pub fn (graph Graph[T]) is_tree[T]() bool {
	if graph.edges.len != graph.nodes.len - 1 {
		return false
	}

	return graph.dfs().edges.len == graph.edges.len
}

// Checks whether the graph is connected.
pub fn (graph Graph[T]) is_connected[T]() bool {
	span_tree := graph.dfs()
	return span_tree.edges.len == span_tree.nodes.len
}

// Returns the number of connected components of the graph.
pub fn (graph Graph[T]) num_connected_components[T]() int {
	return graph.nodes.len - graph.dfs().edges.len
}

// Checks whether the graph is bipartite.
pub fn (graph Graph[T]) is_bipartite[T]() bool {
	mut colours := map[int][2]bool{} // 2 bits per node, 1 for if node is coloured and 1 for the colour itself
	for i in 0 .. graph.nodes.len {
		colours[i] = [false, false]!
	}

	adj := graph.to_adjacency()
	mut queue := Queue[int]{}
	for i in 0 .. graph.nodes.len {
		if colours[i][0] {
			continue
		}
		colours[i][0] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in adj[w] or { [] } {
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
pub fn (graph Graph[T]) is_acyclic[T]() bool {
	mut visited := map[int]bool{}
	mut parents := map[int]int{}
	for i in 0 .. graph.nodes.len {
		visited[i] = false
	}

	adj := graph.to_adjacency()
	mut queue := Queue[int]{}
	for i in 0 .. graph.nodes.len {
		if visited[i] {
			continue
		}
		visited[i] = true
		queue.push(i)
		for !queue.is_empty() {
			w := queue.pop() or { continue }

			for x in adj[w] or { [] } {
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

fn (graph Graph[T]) eccentricity_helper[T](node int, adj map[int][]int) int {
	mut max_dist := 0

	mut dist := map[int]int{}
	mut visited := map[int]bool{}
	mut queue := Queue[int]{}
	visited[node] = true
	dist[node] = 0
	queue.push(node)

	for !queue.is_empty() {
		w := queue.pop() or { continue }
		for x in adj[w] or { [] } {
			if visited[x] {
				continue
			}
			visited[x] = true
			dist[x] = dist[w] + 1
			max_dist = if max_dist > dist[x] { max_dist } else { dist[x] }
			queue.push(x)
		}
	}

	return max_dist
}

// Returns the eccentricity of a given node.
pub fn (graph Graph[T]) eccentricity[T](node &Node[T]) int {
	return graph.eccentricity_helper(graph.nodes.index(node), graph.to_adjacency())
}

// Returns the diameter of the graph, this implementation only works for connected graphs.
pub fn (graph Graph[T]) diameter[T]() int {
	mut max_dist := 0
	adj := graph.to_adjacency()

	for i in 0 .. graph.nodes.len {
		dist := graph.eccentricity_helper(i, adj)
		if dist > max_dist {
			max_dist = dist
		}
	}

	return max_dist
}

// Returns the radius of the graph, this implementation only works for connected graphs.
pub fn (graph Graph[T]) radius[T]() int {
	adj := graph.to_adjacency()
	if graph.nodes.len == 0 {
		return 0
	}
	mut min_dist := graph.eccentricity_helper(0, adj)

	for i in 0 .. graph.nodes[1..].len {
		dist := graph.eccentricity_helper(i, adj)
		if dist < min_dist {
			min_dist = dist
		}
	}

	return min_dist
}

// Returns the girth of the graph.
pub fn (graph Graph[T]) girth[T]() int {
	adj := graph.to_adjacency()
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

			for x in adj[w] or { [] } {
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
pub fn (graph Graph[T]) num_spanning_trees[T]() f64 {
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

	return math.abs(math.round(det(laplacian[1..]) or { 0 }))
}

// Returns the number of triangles of the graph.
pub fn (graph Graph[T]) num_triangles[T]() int {
	m := graph.to_adjacency_matrix()
	mut sum := 0
	for i, row in matmul(m, matmul(m, m) or { [] }) or { [] } {
		sum += int(row[i])
	}
	return sum / 6
}

// Returns the degeneracy the graph.
// It implements the algorithm described by Matula and Beck, described [here](https://doi.org/10.1145/2402.322385)
pub fn (graph Graph[T]) degeneracy() int {
	n := graph.nodes.len
	mut visited := map[int]bool{}
	adj := graph.to_adjacency()
	mut degree := map[int]int{}
	mut max_deg := 0

	for i in 0 .. n {
		degree[i] = adj[i].len
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

		for u in adj[v] {
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
