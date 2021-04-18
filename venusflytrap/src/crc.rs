use obfstr::{
	bytes::{deobfuscate, keystream, obfuscate},
	random,
};

const POLYNOMIAL_KEYSTREAM: [u8; 8] = keystream(random!(u32));
const POLYNOMIAL: [u8; 8] = obfuscate(b"\x49\x1b\xf5\xd4\xf5\x70\x78\xa1", &POLYNOMIAL_KEYSTREAM);

#[inline(always)]
pub fn crc(initial: u64, data: &[u8]) -> u64 {
	let polynomial = u64::from_le_bytes(deobfuscate(&POLYNOMIAL, &POLYNOMIAL_KEYSTREAM));
	data.iter().fold(initial, |crc, byte| {
		let mut crc = crc ^ ((*byte as u64) << 56);
		for _ in 0..8 {
			if (crc & 0x8000000000000000) != 0 {
				crc = (crc << 1) ^ polynomial;
			} else {
				crc <<= 1;
			}
		}
		crc
	})
}
