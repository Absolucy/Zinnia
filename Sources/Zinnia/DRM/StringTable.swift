import Foundation
import ZinniaC

#if THEOS_SWIFT
	internal func getStr(_ index: UInt32) -> String {
		var str = String()
		st_get_bytes(index) { bytes, size in
			str.reserveCapacity(size - 1)
			str.append(String(bytesNoCopy: bytes!, length: size - 1, encoding: .utf8, freeWhenDone: true)!)
		}
		return str
	}

	internal func getList(_ index: UInt32) -> [String] {
		getStr(index).split(separator: "$").map { String($0) }
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
#else
	internal func getStr(_: String) -> String {
		fatalError("use of getStr without preprocessor!")
	}

	internal func getList(_: UInt32) -> [String] {
		fatalError("use of getList without preprocessor!")
	}

	internal func getData(_: UInt32) -> Data {
		fatalError("use of getData without preprocessor!")
	}
#endif
