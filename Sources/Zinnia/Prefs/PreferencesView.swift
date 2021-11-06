//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreGraphics
import Foundation
import SwiftUI
import ZinniaC

struct PreferencesView: View {
	@Environment(\.colorScheme) var colorScheme

	@State private var fullPreview = false
	@State private var respringAlert = false
	@State private var setFont: SetFont? = nil
	@State private var dateFontInfo: UIFontDescriptor? = nil
	@State private var timeFontInfo: UIFontDescriptor? = nil

	private let notifier = NotificationCenter.default.publisher(for: NSNotification.Name("me.aspenuwu.zinnia.unlock"))
		.receive(on: RunLoop.main)

	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true
	@Preference("dateFont", identifier: ZinniaPreferences.identifier) var dateFont = "San Francisco"
	@Preference("timeFont", identifier: ZinniaPreferences.identifier) var timeFont = "San Francisco"

	let lockScreenBg: AnyView = {
		if let bg = lockScreenWallpaper() {
			return AnyView(Image(uiImage: bg))
		} else {
			return AnyView(Color.primary.colorInvert())
		}
	}()

	var body: some View {
		Form {
			Header("Zinnia",
			       icon: (Image(contentsOfFile: "/Library/PreferenceBundles/ZinniaPrefs.bundle/icon-logo.png") ??
			       	Image(systemName: "lock.rectangle.stack")).resizable().frame(width: 120, height: 120))
			Toggle("Enabled", isOn: $enabled)
				.onTapGesture {
					respringAlert = true
				}
				.alert(isPresented: $respringAlert) {
					Alert(
						title: Text("In order for Zinnia to be enabled/disabled, you need to respring. Would you like to do so now?"),
						primaryButton: .destructive(Text("Respring"), action: respring),
						secondaryButton: .cancel(Text("Later"))
					)
				}
			if self.enabled {
				Button("Full Preview") {
					fullPreview = true
				}
				TimeDatePrefs(setFont: $setFont, dateFontInfo: $dateFontInfo, timeFontInfo: $timeFontInfo)
				UnlockPrefs()
				PopupPrefs()
			}
		}
		.sheet(item: $setFont, onDismiss: {
			if let dateFontInfo = self.dateFontInfo {
				dateFont = dateFontInfo.postscriptName
			}
			if let timeFontInfo = self.timeFontInfo {
				timeFont = timeFontInfo.postscriptName
			}
		}, content: { f in
			switch f {
			case .date:
				FontPicker(font: $dateFontInfo).padding(.top)
			case .time:
				FontPicker(font: $timeFontInfo).padding(.top)
			}
		})
		.fullScreenCover(isPresented: $fullPreview) {
			VStack {
				TimeDateView()
					.padding(.vertical, 30)
				Spacer().allowsHitTesting(false)
				Text("Unlock to exit preview")
					.font(.caption)
				UnlockButtonView()
			}
			.preferredColorScheme(self.colorScheme)
			.background(lockScreenBg)
		}
		.navigationBarTitle("Zinnia")
		.navigationBarTitleDisplayMode(.inline)
		.onReceive(notifier) { _ in
			fullPreview = false
		}
	}
}

struct PreferencesViewPreviews: PreviewProvider {
	static var previews: some View {
		PreferencesView()
			.preferredColorScheme(.dark)
		PreferencesView()
			.preferredColorScheme(.light)
	}
}

private extension Image {
	init?(contentsOfFile path: String) {
		guard let uiImage = UIImage(contentsOfFile: path) else { return nil }
		self.init(uiImage: uiImage)
	}
}

internal func respring() {
	let sbreload = NSTask()!
	sbreload.setLaunchPath("/usr/bin/sbreload")
	sbreload.launch()
	// just in case sbreload screws up somehow
	DispatchQueue.main.asyncAfter(deadline: .now() + 5, qos: .userInteractive) {
		let killSpringBoard = NSTask()!
		killSpringBoard.setLaunchPath("/usr/bin/killall")
		killSpringBoard.arguments = ["-9", "SpringBoard"]
		killSpringBoard.launch()
	}
}
