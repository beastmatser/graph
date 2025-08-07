module graph

import arrays
import rand
import strings

// Returns a random graph6 string for a graph on n nodes,
// with a given edge probability.
pub fn random_graph6(n i64, edge_prob f64) string {
	mut out := strings.new_builder(1024)

	// Encode number of vertices
	if n <= 62 {
		out.write_byte(u8(n + 63))
	} else if n <= 258047 {
		out.write_byte(126) // '~'
		out.write_byte(u8(((n >> 12) & 0x3F) + 63))
		out.write_byte(u8(((n >> 6) & 0x3F) + 63))
		out.write_byte(u8((n & 0x3F) + 63))
	} else {
		out.write_byte(126)
		out.write_byte(126)
		for i := 0; i < 6; i++ {
			out.write_byte(u8(((n >> (30 - i * 6)) & 0x3F) + 63))
		}
	}

	// Generate random upper triangle bits
	mut bits := []bool{}
	for i in 0 .. n {
		for _ in i + 1 .. n {
			bits << (rand.f64() < edge_prob)
		}
	}

	// Encode 6 bits at a time
	mut i := 0
	for i < bits.len {
		mut b := 0
		for j in 0 .. 6 {
			idx := i + j
			if idx < bits.len && bits[idx] {
				b |= 1 << (5 - j)
			}
		}
		out.write_byte(u8(b + 63))
		i += 6
	}

	return out.str()
}

fn to_bit_vector(n u64, width int) []bool {
	mut bits := []bool{cap: width}
	for i := width - 1; i >= 0; i-- {
		bits << ((n >> i) & 1) == 1
	}
	return bits
}

fn int_repr(n int) []int {
	return match true {
		n <= 62 {
			[n + 63]
		}
		63 <= n && n <= 258047 {
			arrays.append([126], bit_vector_repr(to_bit_vector(u64(n), 18)))
		}
		else {
			arrays.append([126, 126], bit_vector_repr(to_bit_vector(u64(n), 36)))
		}
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
