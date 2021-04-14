import CryptoKit
import Foundation
import ZinniaC

enum MyError: Error {
	case err(String)
}

internal struct ZinniaDRM {
	private static var ticket: AuthorizationTicket? = AuthorizationTicket()

	private static var authSemaphore = DispatchSemaphore(value: 0)

	internal static func authorizeTicket() -> Bool {
		self.ticket = AuthorizationTicket()
		if let ticket = self.ticket {
			return ticket.isValid()
		} else {
			return false
		}
	}

	internal static func requestTicket() {
		let outPipe = Pipe()
		let inPipe = Pipe()
		let task = NSTask()!
		task.setLaunchPath(drm_path()!)
		task.standardOutput = outPipe
		task.standardInput = inPipe
		task.launch()

		try! inPipe.fileHandleForWriting.write(contentsOf: "a".data(using: .ascii)!)
		inPipe.fileHandleForWriting.write(self.createCommunicationData().data(using: .ascii)!)
		try! inPipe.fileHandleForWriting.write(contentsOf: "\n".data(using: .ascii)!)

		task.waitUntilExit()
		let output = outPipe.fileHandleForReading.readDataToEndOfFile()
		if let ticket = try? JSONDecoder().decode(AuthorizationTicket.self, from: output) {
			ticket.save()
			self.ticket = ticket
			self.authSemaphore.signal()
		}
	}

	private static func createCommunicationData() -> String {
		var key = randomBytes(32)!
		let keyXor = randomBytes(32)!
		var udidNonce = randomBytes(12)!
		var modelNonce = randomBytes(12)!
		let nonceXor = randomBytes(12)!
		let udidData = udid()!.data(using: .ascii)!
		let modelData = model()!.data(using: .ascii)!
		guard let encryptedUdid = try? ChaChaPoly.seal(
			udidData,
			using: SymmetricKey(data: key),
			nonce: ChaChaPoly.Nonce(data: udidNonce)
		) else { return "" }
		guard let encryptedModel = try? ChaChaPoly.seal(
			modelData,
			using: SymmetricKey(data: key),
			nonce: ChaChaPoly.Nonce(data: modelNonce)
		) else { return "" }
		var output = Data(capacity: 32 + 32 + 12 + 12 + encryptedUdid.ciphertext.count + encryptedUdid.tag
			.count + encryptedModel.ciphertext.count + encryptedModel.tag.count + MemoryLayout<UInt64>
			.size + MemoryLayout<UInt64>.size
			+ 15 + 5 + 3 + 30 + 30 + 30 + 29 + 29 + 29 + 29 + 4)
		// the \x2A\x2A\x2A\x2A magic
		output.append(contentsOf: [42, 42, 42, 42])
		// _a1
		output.append(randomBytes(15)!)
		// key_xor
		output.append(keyXor)
		// key
		for i in 0 ..< 32 {
			key[i] = key[i] ^ keyXor[i]
		}
		output.append(key)
		// _a2
		output.append(randomBytes(5)!)
		// nonce_xor
		output.append(nonceXor)
		// _a3
		output.append(randomBytes(3)!)
		// udid_nonce
		for i in 0 ..< 12 {
			udidNonce[i] = udidNonce[i] ^ nonceXor[i]
		}
		output.append(udidNonce)
		// _a4, _a5
		output.append(randomBytes(60)!)
		// _udid_size
		var udidSize = UInt64(encryptedUdid.ciphertext.count + encryptedUdid.tag.count).littleEndian
		withUnsafeBytes(of: &udidSize) {
			output.append(contentsOf: $0)
		}
		// _a6
		output.append(randomBytes(30)!)
		// udid
		output.append(encryptedUdid.ciphertext)
		output.append(encryptedUdid.tag)
		// _model_size
		var modelSize = UInt64(encryptedModel.ciphertext.count + encryptedModel.tag.count).littleEndian
		withUnsafeBytes(of: &modelSize) {
			output.append(contentsOf: $0)
		}
		// _a7, _a8, _a9
		output.append(randomBytes(29 * 3)!)
		// model
		output.append(encryptedModel.ciphertext)
		output.append(encryptedModel.tag)
		// _a10
		output.append(randomBytes(29)!)
		// model_nonce
		for i in 0 ..< 12 {
			modelNonce[i] = modelNonce[i] ^ nonceXor[i]
		}
		output.append(modelNonce)
		return output.base64EncodedString()
	}
}

internal func sealBox(_ data: Data) -> ChaChaPoly.SealedBox? {
	let key = SymmetricKey(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try? ChaChaPoly.seal(data, using: key, authenticating: ad)
}

internal func openBox(_ box: ChaChaPoly.SealedBox) -> Data? {
	let key = SymmetricKey(data: getDeviceKey()!)
	let ad = getDeviceAD()!
	return try? ChaChaPoly.open(box, using: key, authenticating: ad)
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
		try container.encode(self.x, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: date_locale()!)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = date_format()!

		try container.encode(formatter.string(from: self.i), forKey: .i)
		try container.encode(formatter.string(from: self.e), forKey: .e)
		try container.encode([UInt8](self.s), forKey: .s)
	}
}

extension AuthorizationTicket: Decodable {
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		self.x = try values.decode(UUID.self, forKey: .x)

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: date_locale()!)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = date_format()!

		guard let issued = formatter.date(from: try values.decode(String.self, forKey: .i))
		else { throw MyError.err("issued was not date") }
		self.i = issued

		guard let expiry = formatter.date(from: try values.decode(String.self, forKey: .e))
		else { throw MyError.err("expiry was not date") }
		self.e = expiry

		self.s = Data(try values.decode([UInt8].self, forKey: .s))
	}
}

internal extension AuthorizationTicket {
	init?() {
		prepareGoldenTicket()
		guard let encryptedTicket = try? Data(contentsOf: URL(fileURLWithPath: golden_ticket()!)),
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
		try? sealedBox.combined.write(to: URL(fileURLWithPath: golden_ticket()!))
	}

	func daysLeft() -> Int {
		let now = Date()
		return Calendar.current.dateComponents([.day], from: now, to: self.e).day ?? 0
	}

	func isValid() -> Bool {
		let publicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: pubkey()!)
		var data = Data(capacity: 16 + MemoryLayout<UInt64>.size + MemoryLayout<UInt64>.size)

		// Serialize the UUID into our data
		withUnsafePointer(to: self.x) {
			data.append(Data(bytes: $0, count: MemoryLayout.size(ofValue: x)))
		}
		// Serialize UDID, model, and tweak name into the data next
		data.append(udid()!.data(using: .utf8)!)
		data.append(model()!.data(using: .utf8)!)
		data.append(tweakName()!.uppercased().data(using: .utf8)!)
		// Convert issued/expired dates to seconds, then serialize them into our data
		data.append(UInt64(self.i.timeIntervalSince1970).littleEndian.data)
		data.append(UInt64(self.e.timeIntervalSince1970).littleEndian.data)
		// XOR all data by 42
		for i in 0 ..< data.count {
			data[i] ^= 42
		}
		let now = Date()
		// Now we check the signature's validity!
		return publicKey.isValidSignature(self.s, for: data) && now >= self.i && now < self.e
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
