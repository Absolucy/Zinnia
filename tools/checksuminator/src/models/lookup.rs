use bytemuck::{Pod, Zeroable};

#[derive(Debug, Copy, Clone, Pod, Zeroable)]
#[repr(C)]
pub struct CrcLookup {
	pub ckey: u32,
	pub checksum: [u8; 12],
	pub size: u64,
	pub jkey: u64,
	pub jmp: u64,
}
