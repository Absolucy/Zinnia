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
