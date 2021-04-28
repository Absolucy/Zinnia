import Foundation
import ZinniaC

private func jailbreak() -> String {
	let paths = getStr(20).split(separator: "|")
	let jailbreaks = getStr(21).split(separator: "|")
	if FileManager.default.fileExists(atPath: String(paths[0])) {
		return String(jailbreaks[0])
	} else if FileManager.default.fileExists(atPath: String(paths[1])),
	          FileManager.default.fileExists(atPath: String(paths[2]))
	{
		return String(jailbreaks[1])
	} else if FileManager.default.fileExists(atPath: String(paths[1])) {
		return String(jailbreaks[2])
	} else if FileManager.default.fileExists(atPath: String(paths[3])) {
		return String(jailbreaks[3])
	} else if FileManager.default.fileExists(atPath: String(paths[4])) {
		return String(jailbreaks[4])
	}
	return String(jailbreaks[5])
}

private func iosVersion() -> String {
	let version = ProcessInfo.processInfo.operatingSystemVersion
	if version.patchVersion > 0 {
		return String(format: getStr(23), version.majorVersion, version.minorVersion, version.patchVersion)
	} else {
		return String(format: getStr(24), version.majorVersion, version.minorVersion)
	}
}

internal func userAgent() -> String {
	String(format: getStr(22), getStr(25), getStr(19), model(), jailbreak(), iosVersion())
}
