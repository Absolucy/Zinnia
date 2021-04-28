import CryptoKit
import Foundation
import ZinniaC

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox? {
	let key = SymmetricKey(data: getDeviceKey())
	let ad = getDeviceAD()
	NSLog("Zinnia: key is \(getDeviceKey()), ad is \(ad)")
	return try? ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data? {
	let key = SymmetricKey(data: getDeviceKey())
	let ad = getDeviceAD()
	NSLog("Zinnia: key is \(key), ad is \(ad)")
	return try? ChaChaPoly.open(box, using: key, authenticating: ad)
}

internal func getDeviceKey() -> Data {
	let key_len = Int(BLAKE3_OUT_LEN)
	var udidHash = [UInt8](repeating: 0, count: key_len)
	let udidKey = getData(26)
	udid().data(using: .utf8)!.withUnsafeBytes { bytes in
		udidKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &udidHash, key_len)
		}
	}
	var modelHash = [UInt8](repeating: 0, count: key_len)
	let modelKey = getData(27)
	model().data(using: .utf8)!.withUnsafeBytes { bytes in
		modelKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &modelHash, key_len)
		}
	}
	var key = getData(28)
	for idx in 0 ..< key_len {
		key[idx] ^= (udidHash[idx] &* UInt8(idx + 1)) ^ (modelHash[idx] &* UInt8(idx + 1))
	}
	return key
}

internal func getDeviceAD() -> Data {
	let key_len = Int(BLAKE3_OUT_LEN)
	var udidHash = [UInt8](repeating: 0, count: key_len)
	let udidKey = getData(29)
	udid().data(using: .utf8)!.withUnsafeBytes { bytes in
		udidKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &udidHash, key_len)
		}
	}
	var modelHash = [UInt8](repeating: 0, count: key_len)
	let modelKey = getData(30)
	model().data(using: .utf8)!.withUnsafeBytes { bytes in
		modelKey.withUnsafeBytes { b3key in
			var hasher = blake3_hasher()
			blake3_hasher_init_keyed(&hasher, b3key.bindMemory(to: UInt8.self).baseAddress!)
			blake3_hasher_update(&hasher, bytes.baseAddress!, bytes.count)
			blake3_hasher_finalize(&hasher, &modelHash, key_len)
		}
	}
	var key = getData(31)
	for idx in 0 ..< key_len {
		key[idx] ^= (udidHash[idx] &* UInt8((key_len - idx) + 1)) ^ (modelHash[idx] &* UInt8((key_len - idx) + 1))
	}
	return key
}
