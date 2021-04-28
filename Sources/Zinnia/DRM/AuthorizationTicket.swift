import CryptoKit
import Foundation
import ZinniaC

internal struct AuthorizationTicket {
	// random uuid
	var x: UUID
	// time issued (seconds since unix epoch)
	var i: Date
	// time expired (seconds since unix epoch)
	var e: Date
	// bitflags relating to the ticket
	var f: UInt8
	// ed25519 signature
	var s: Data

	enum CodingKeys: String, CodingKey {
		case x
		case i
		case e
		case f
		case s
	}
}

extension AuthorizationTicket: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(x, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: getStr(7))
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = getStr(6)

		try container.encode(formatter.string(from: i), forKey: .i)
		try container.encode(formatter.string(from: e), forKey: .e)
		try container.encode(f, forKey: .f)
		try container.encode([UInt8](s), forKey: .s)
	}
}

extension AuthorizationTicket: Decodable {
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		x = try values.decode(UUID.self, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: getStr(7))
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = getStr(6)

		guard let issued = formatter.date(from: try values.decode(String.self, forKey: .i))
		else { throw MyError.err("i") }
		i = issued

		guard let expiry = formatter.date(from: try values.decode(String.self, forKey: .e))
		else { throw MyError.err("e") }
		e = expiry

		f = try values.decode(UInt8.self, forKey: .f)
		s = Data(try values.decode([UInt8].self, forKey: .s))
	}
}

internal extension AuthorizationTicket {
	init?() {
		prepareGoldenTicket()
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: getStr(11))),
		      let sealedTicket = try? ChaChaPoly.SealedBox(combined: encryptedTicket),
		      let unsealedTicket = openBox(sealedTicket),
		      let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: unsealedTicket)
		else { return nil }
		self = ticket
	}

	func save() {
		prepareGoldenTicket()
		guard let json = try? JSONEncoder().encode(self),
		      let sealedBox = sealBox(json) else { return }
		try? sealedBox.combined.write(to: URL(fileURLWithPath: getStr(11)))
	}

	func daysLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.day], from: now, to: e).day ?? 0
	}

	func minutesLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.minute], from: now, to: e).minute ?? 0
	}

	func isTrial() -> Bool {
		(f & (1 << 0)) == 1
	}

	func isSignatureValid() -> Bool {
		guard let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: getData(18)) else { return false }
		var data = Data(capacity: 16 + MemoryLayout<UInt64>.size + MemoryLayout<UInt64>.size)

		// Serialize the UUID into our data
		withUnsafePointer(to: x) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: x)))
		}
		// Serialize UDID, model, and tweak name into the data next
		data.append(udid().data(using: .utf8)!)
		data.append(model().data(using: .utf8)!)
		data.append(getStr(25).uppercased().data(using: .utf8)!)
		// Convert issued/expired dates to seconds, then serialize them into our data
		data.append(UInt64(i.timeIntervalSince1970).littleEndian.data)
		data.append(UInt64(e.timeIntervalSince1970).littleEndian.data)
		// Serialize the bitflag
		data.append(f.littleEndian.data)
		// XOR all data by 42
		for i in 0 ..< data.count {
			data[i] ^= (42 &* UInt8(i + 1))
		}
		// Now we check the signature's validity!
		return publicKey.isValidSignature(s, for: data)
	}

	func validTime() -> Bool {
		let now = Date()
		return now >= (i - 300) && now < e
	}

	func isValid() -> Bool {
		isSignatureValid() && validTime()
	}
}

private enum MyError: Error {
	case err(String)
}
