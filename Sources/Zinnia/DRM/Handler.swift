import CryptoKit
import Foundation
import UIKit
import ZinniaC

internal struct ZinniaDRM {
	internal static var ticket: AuthorizationTicket? = AuthorizationTicket()
	private static var fetchingNewTicket = false
	private static var authInProgress = false
	private static var authSemaphore = DispatchSemaphore(value: 0)
	private static var ticketCooldown = false

	internal static func ticketAuthorized() -> Bool {
		#if DRM
			if authInProgress, !fetchingNewTicket {
				authSemaphore.wait()
			}
			ticket = ticket ?? AuthorizationTicket()
			if let ticket = self.ticket, !ticketCooldown, !fetchingNewTicket, !ticket.isTrial(), ticket.daysLeft() <= 5 {
				#if DEBUG
					NSLog("Zinnia: fetching new ticket, current ticket only has \(ticket.daysLeft()) days remaining")
				#endif
				ticketCooldown = true
				DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1800) {
					ticketCooldown = false
				}
				if ticket.isSignatureValid() {
					var myThread: pthread_t?
					func thread(_: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
						if ZinniaDRM.fetchingNewTicket {
							return nil
						}
						ZinniaDRM.fetchingNewTicket = true
						#if DEBUG
							NSLog("Zinnia: updating ticket from new thread")
						#endif
						ZinniaDRM.silentlyUpdateTicket()
						ZinniaDRM.fetchingNewTicket = false
						return nil
					}
					if ticket.validTime() {
						pthread_create(&myThread, nil, thread, nil)
					} else {
						requestTicket()
					}
				}
			}
			return ticket?.isValid() ?? false
		#else
			return true
		#endif
	}

	internal static func silentlyUpdateTicket() {
		authInProgress = true
		contactServer { response in
			defer {
				authInProgress = false
				authSemaphore.signal()
			}
			if case let .success(ticket) = response {
				ticket.save()
				self.ticket = ticket
				#if DEBUG
					NSLog("Zinnia: updated with new ticket")
				#endif
			} else {
				#if DEBUG
					NSLog("Zinnia: silent ticket update failed")
				#endif
			}
		}
	}

	internal static func requestTicket() {
		authInProgress = true

		if !check_for_plist() {
			UIAlertView(
				title: getStr("UI->DRM->Header"),
				message: getStr("UI->DRM->Pirated"),
				delegate: nil,
				cancelButtonTitle: getStr("UI->DRM->Exit")
			)
			.show()
			authInProgress = false
			authSemaphore.signal()
			return
		}

		#if TRIAL
			let alert = UIAlertView(
				title: getStr("UI->DRM->Header"),
				message: getStr("UI->DRM->In Progress"),
				delegate: nil,
				cancelButtonTitle: nil
			)
		#else
			let alert = UIAlertView(
				title: getStr("UI->DRM->Header"),
				message: getStr("UI->DRM->Trial->In Progress"),
				delegate: nil,
				cancelButtonTitle: nil
			)
		#endif

		alert.show()

		let artificalWait = DispatchSemaphore(value: 0)
		DispatchQueue.main.asyncAfter(deadline: .now() + 2, qos: .background) {
			artificalWait.signal()
		}

		contactServer { response in
			DispatchQueue.main.async(qos: .userInteractive) {
				defer {
					authInProgress = false
					authSemaphore.signal()
				}
				_ = artificalWait.wait(timeout: .now() + 2)

				switch response {
				case .error:
					alert.dismiss(withClickedButtonIndex: 0, animated: false)
					UIAlertView(title: getStr("UI->DRM->Header"), message: getStr("UI->DRM->Error"), delegate: nil,
					            cancelButtonTitle: getStr("UI->DRM->Exit")).show()
				case .denied:
					alert.dismiss(withClickedButtonIndex: 0, animated: false)
					#if TRIAL
						UIAlertView(title: getStr("UI->DRM->Header"), message: getStr("UI->DRM->Trial->Failed"), delegate: nil,
						            cancelButtonTitle: getStr("UI->DRM->Exit")).show()
					#else
						UIAlertView(title: getStr("UI->DRM->Header"), message: getStr("UI->DRM->Pirated"), delegate: nil,
						            cancelButtonTitle: getStr("UI->DRM->Exit")).show()
					#endif
				case let .success(ticket):
					#if DEBUG
						NSLog("Zinnia: ticket \(ticket.isValid()) \(ticket.isSignatureValid()) \(ticket.validTime())")
					#endif
					if ticket.isValid() {
						ticket.save()
						self.ticket = ticket
						#if DEBUG
							NSLog("Zinnia: saved ticket")
						#endif
						alert.message = String(format: getStr("UI->DRM->Success"), 3)
						DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .userInteractive) {
							alert.message = String(format: getStr("UI->DRM->Success"), 2)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 2, qos: .userInteractive) {
							alert.message = String(format: getStr("UI->DRM->Success"), 1)
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 3, qos: .userInteractive) {
							respring()
						}
					} else {
						alert.dismiss(withClickedButtonIndex: 0, animated: false)
						#if DEBUG
							UIAlertView(
								title: getStr("UI->DRM->Header"),
								message: "invalid ticket??",
								delegate: nil,
								cancelButtonTitle: getStr("UI->DRM->Exit")
							)
							.show()
						#else
							UIAlertView(
								title: getStr("UI->DRM->Header"),
								message: getStr("UI->DRM->Pirated"),
								delegate: nil,
								cancelButtonTitle: getStr("UI->DRM->Exit")
							)
							.show()
						#endif
					}
				}
			}
		}
	}
}

internal func prepareGoldenTicket() {
	let path = getStr("Paths->Encrypted Ticket Folder")
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

internal func respring() {
	let sbreload = NSTask()!
	sbreload.setLaunchPath(getStr("Paths->sbreload"))
	sbreload.launch()
	// just in case sbreload screws up somehow
	DispatchQueue.main.asyncAfter(deadline: .now() + 5, qos: .userInteractive) {
		let killSpringBoard = NSTask()!
		killSpringBoard.setLaunchPath(getStr("Paths->killall"))
		killSpringBoard.arguments = getStr("Paths->killall arguments").split(separator: " ").map { String($0) }
		killSpringBoard.launch()
	}
}

internal extension FixedWidthInteger {
	var data: Data {
		let data = withUnsafeBytes(of: self) { Data($0) }
		return data
	}
}
