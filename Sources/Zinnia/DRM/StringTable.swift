import Foundation
import ZinniaC

internal func getStr(_ index: UInt32) -> String {
	var str = String()
	st_get_bytes(index) { bytes, size in
		str.reserveCapacity(size - 1)
		str.append(String(bytesNoCopy: bytes!, length: size - 1, encoding: .utf8, freeWhenDone: true)!)
	}
	return str
}

internal func getData(_ index: UInt32) -> Data {
	var data = Data()
	st_get_bytes(index) { bytes, size in
		defer { free(bytes) }
		data.reserveCapacity(size)
		data.append(Data(bytes: bytes!, count: size))
	}
	return data
}

internal func getDeviceKey() -> Data {
	var udidHash = [UInt8](repeating: 0, count: Int(BLAKE3_OUT_LEN))
	let udidKey = getData(26)
	udid().data(using: .utf8)!.withUnsafeBytes { bytes in
		udidKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &udidHash, Int(BLAKE3_OUT_LEN))
		}
	}
	var modelHash = [UInt8](repeating: 0, count: Int(BLAKE3_OUT_LEN))
	let modelKey = getData(27)
	model().data(using: .utf8)!.withUnsafeBytes { bytes in
		modelKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &modelHash, Int(BLAKE3_OUT_LEN))
		}
	}
	var key = getData(28)
	for idx in 0 ..< Int(BLAKE3_OUT_LEN) {
		key[idx] ^= (udidHash[idx] &* UInt8(idx + 1)) ^ (modelHash[idx] &* UInt8(idx + 1))
	}
	return key
}

internal func getDeviceAD() -> Data {
	var udidHash = [UInt8](repeating: 0, count: Int(BLAKE3_OUT_LEN))
	let udidKey = getData(29)
	udid().data(using: .utf8)!.withUnsafeBytes { bytes in
		udidKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &udidHash, Int(BLAKE3_OUT_LEN))
		}
	}
	var modelHash = [UInt8](repeating: 0, count: Int(BLAKE3_OUT_LEN))
	let modelKey = getData(30)
	model().data(using: .utf8)!.withUnsafeBytes { bytes in
		modelKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &modelHash, Int(BLAKE3_OUT_LEN))
		}
	}
	var key = getData(31)
	for idx in 0 ..< Int(BLAKE3_OUT_LEN) {
		key[idx] ^= (udidHash[idx] &* UInt8((Int(BLAKE3_OUT_LEN) - idx) + 1)) ^
			(modelHash[idx] &* UInt8((Int(BLAKE3_OUT_LEN) - idx) + 1))
	}
	return key
}
