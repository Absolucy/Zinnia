import ZinniaC
import Foundation
import CryptoKit

enum MyError: Error {
	case err(String)
}

internal class ZinniaDRM {
	static let instance = ZinniaDRM()

	var ticket: AuthorizationTicket? = AuthorizationTicket()

	func authorizeTicket() -> Bool {
		self.ticket = AuthorizationTicket()
		if let ticket = self.ticket {
			return ticket.isValid()
		} else {
			return false
		}
	}
}

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox {
	let key = SymmetricKey.init(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try! ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data {
	let key = SymmetricKey.init(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try! ChaChaPoly.open(box, using: key, authenticating: ad)
}

internal struct AuthorizationTicket {
	// random uuid
	var x: UUID
	// time issued (seconds since unix epoch)
	var i: Date
	// time expired (seconds since unix epoch)
	var e: Date
	// ed25519 signature
	var s: Data
	
	enum CodingKeys: String, CodingKey {
		case x
		case i
		case e
		case s
	}
}

extension AuthorizationTicket: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(x, forKey: .x)
		try container.encode(ISO8601DateFormatter().string(from: i), forKey: .i)
		try container.encode(ISO8601DateFormatter().string(from: e), forKey: .e)
		try container.encode(s, forKey: .s)
	}
}

extension AuthorizationTicket: Decodable {
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.x = try values.decode(UUID.self, forKey: .x)
		guard let issued = ISO8601DateFormatter().date(from: try values.decode(String.self, forKey: .i)) else { throw MyError.err("issued was not date") }
		self.i = issued
		guard let expiry = ISO8601DateFormatter().date(from: try values.decode(String.self, forKey: .e)) else { throw MyError.err("expiry was not date") }
		self.e = expiry
		self.s = try values.decode(Data.self, forKey: .s)
	}
}

internal extension AuthorizationTicket {
	init?() {
		prepareGoldenTicket()
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: golden_ticket()!)),
			  let sealedTicket = try? ChaChaPoly.SealedBox(combined: encryptedTicket),
			  let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: openBox(sealedTicket)) else { return nil }
		self = ticket
	}

	func save() {
		prepareGoldenTicket()
		guard let json = try? JSONEncoder().encode(self) else { return }
		let sealedBox = sealBox(json)
		try? sealedBox.combined.write(to: URL(fileURLWithPath: golden_ticket()!))
	}

	func daysLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.day], from: now, to: e).day ?? 0
	}

	func isValid() -> Bool {
		let publicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: pubkey()!)
		var data = Data(capacity: 16 + MemoryLayout<UInt64>.size + MemoryLayout<UInt64>.size)
		
		// Serialize the UUID into our data
		withUnsafePointer(to: x) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: x)))
		}
		// Serialize UDID and model into the data next
		data.append(udid()!.data(using: .utf8)!)
		data.append(model()!.data(using: .utf8)!)
		// Convert issued/expired dates to seconds, then serialize them into our data
		data.append(UInt64(i.timeIntervalSince1970).littleEndian.data)
		data.append(UInt64(e.timeIntervalSince1970).littleEndian.data)
		// XOR all data by 42
		for i in 0 ..< data.count {
			data[i] ^= 42
		}
		let now = Date()
		// Now we check the signature's validity!
		return publicKey.isValidSignature(self.s, for: data) && now >= i && now < e
	}
}

internal func prepareGoldenTicket() {
	let path = golden_ticket_folder()!
	var isDir: ObjCBool = false
	let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
	if !exists || !isDir.boolValue {
		do {
			try FileManager.default.removeItem(atPath: path)
		} catch {}
		do {
			try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
		} catch {}
	}
}

internal extension FixedWidthInteger {
	var data: Data {
		let data = withUnsafeBytes(of: self) { Data($0) }
		return data
	}
}

