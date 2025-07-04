module undirected

import arrays

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
