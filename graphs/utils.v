module graphs

import arrays
import math

fn to_bit_vector(n u64, width int) []bool {
	mut bits := []bool{cap: width}
	for i := width - 1; i >= 0; i-- {
		bits << ((n >> i) & 1) == 1
	}
	return bits
}

fn int_repr(n int) []int {
	return match true {
		n <= 62 { [n + 63] }
		63 <= n && n <= 258047 { arrays.append([126], bit_vector_repr(to_bit_vector(u64(n),
				18))) }
		else { arrays.append([126, 126], bit_vector_repr(to_bit_vector(u64(n), 36))) }
	}
}

fn bit_vector_repr(x []bool) []int {
	mut y := x.clone()
	n := (6 - (x.len % 6)) % 6

	for _ in 0 .. n {
		y << false
	}

	powers := {
		0: 1
		1: 2
		2: 4
		3: 8
		4: 16
		5: 32
	}

	mut bigendian := []int{len: (y.len / 6)}
	for i in 0 .. (y.len / 6) {
		for j in 0 .. 6 {
			if !y[6 * i + j] {
				continue
			}
			bigendian[i] += powers[5 - j]
		}
		bigendian[i] += 63
	}

	return bigendian
}

fn to_string(repr []int) string {
	chars := []u8{len: repr.len, init: u8(repr[index])}
	return chars.bytestr()
}

fn lu_decomposition(a [][]f64) !([][]f64, [][]f64, []int) {
	n := a.len
	if a.any(it.len != n) {
		return error('Matrix must be square')
	}

	mut a_copy := a.clone()
	mut l := [][]f64{len: n, init: []f64{len: n}}
	mut u := [][]f64{len: n, init: []f64{len: n}}
	mut perm := []int{len: n}
	for i in 0 .. n {
		perm[i] = i
	}

	for i in 0 .. n {
		mut max_row := i
		mut max_val := math.abs(a_copy[i][i])
		for k in i + 1 .. n {
			if math.abs(a_copy[k][i]) > max_val {
				max_val = math.abs(a_copy[k][i])
				max_row = k
			}
		}

		if max_row != i {
			a_copy[i], a_copy[max_row] = a_copy[max_row], a_copy[i]
			perm[i], perm[max_row] = perm[max_row], perm[i]
			for j in 0 .. i {
				l[i][j], l[max_row][j] = l[max_row][j], l[i][j]
			}
		}

		// Compute U
		for k in i .. n {
			mut sum := 0.0
			for j in 0 .. i {
				sum += l[i][j] * u[j][k]
			}
			u[i][k] = a_copy[i][k] - sum
		}

		// Compute L
		for k in i .. n {
			if i == k {
				l[i][i] = 1.0
			} else {
				mut sum := 0.0
				for j in 0 .. i {
					sum += l[k][j] * u[j][i]
				}
				if math.abs(u[i][i]) < 1e-12 {
					return error('Zero pivot after pivoting — matrix may be singular')
				}
				l[k][i] = (a_copy[k][i] - sum) / u[i][i]
			}
		}
	}

	return l, u, perm
}

fn det(a [][]f64) !f64 {
	_, u, perm := lu_decomposition(a) or { return err }

	mut swaps := 0
	for i in 0 .. perm.len {
		if perm[i] != i {
			swaps++
		}
	}

	mut d := 1.0
	for i in 0 .. a.len {
		d *= u[i][i]
	}
	if swaps % 2 == 1 {
		d = -d
	}
	return d
}

fn matmul(a [][]int, b [][]int) ![][]int {
	n := a.len
	if n == 0 || b.len == 0 {
		return error('Input matrices must not be empty')
	}
	m := a[0].len
	p := b[0].len

	if a.any(it.len != m) || b.any(it.len != p) {
		return error('All rows must have consistent lengths')
	}
	if m != b.len {
		return error('Matrix dimensions incompatible: a is ${n}x${m}, b is ${b.len}x${p}')
	}

	mut result := [][]int{len: n, init: []int{len: p}}

	for i in 0 .. n {
		for j in 0 .. p {
			mut sum := 0
			for k in 0 .. m {
				sum += a[i][k] * b[k][j]
			}
			result[i][j] = sum
		}
	}

	return result
}
