module undirected

import rand
import strings

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
		for j in i + 1 .. n {
			bits << (rand.f64() < edge_prob)
		}
	}

	// Encode 6 bits at a time
	for i in 0 .. (bits.len + 5) / 6 {
		mut b := 0
		for j in 0 .. 6 {
			idx := i * 6 + j
			if idx < bits.len && bits[idx] {
				b |= 1 << (5 - j)
			}
		}
		out.write_byte(u8(b + 63))
	}

	return out.str()
}

fn test_graph6() {
	for i in 0 .. 100 {
		str := random_graph6(rand.i64_in_range(1, 1000) or { 100 }, i / 100)
		assert UndirectedGraph.from_graph6(str).to_graph6() == str
	}
}
