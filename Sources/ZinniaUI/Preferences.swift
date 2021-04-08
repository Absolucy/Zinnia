import Foundation
import NomaePreferences
import SwiftUI

public enum ZinniaPreferences {
	static let identifier = "me.aspenuwu.zinnia"
	@Preference("enabled", identifier: identifier) public static var enabled = true

	// Date-time
	@Preference("dateFormat", identifier: identifier) public static var dateFormat = "MM/dd/yyyy"
	@Preference("timeFormat", identifier: identifier) public static var timeFormat = "hh:mm a"
	@Preference("dateTimeNeonMul", identifier: identifier) public static var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: identifier) public static var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: identifier) public static var dateTimeBgColor = Color.black
	@Preference("dateTimeBgAlpha", identifier: identifier) public static var dateTimeBgAlpha: Double = 0.5

	// Unlock
	@Preference("unlockBgColor", identifier: identifier) public static var unlockBgColor = Color.primary
	@Preference("unlockNeonMul", identifier: identifier) public static var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: identifier) public static var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: identifier) public static var unlockIconColor = Color.accentColor

	// Camera popup
	@Preference("cameraBgColor", identifier: identifier) public static var cameraBgColor = Color.primary
	@Preference("cameraNeonColor", identifier: identifier) public static var cameraNeonColor = Color.orange
	@Preference("cameraNeonMul", identifier: identifier) public static var cameraNeonMul: Double = 1
	@Preference("cameraIconColor", identifier: identifier) public static var cameraIconColor = Color.accentColor

	// Flashlight popup
	@Preference("flashlightBgColor", identifier: identifier) public static var flashlightBgColor = Color.primary
	@Preference("flashlightNeonColor", identifier: identifier) public static var flashlightNeonColor = Color.yellow
	@Preference("flashlightNeonMul", identifier: identifier) public static var flashlightNeonMul: Double = 1
	@Preference("flashlightIconColor", identifier: identifier) public static var flashlightIconColor = Color.accentColor

	// Unlock popup
	@Preference("lockBgColorUnlocked", identifier: identifier) public static var lockBgColorUnlocked = Color.primary
	@Preference("lockBgColorLocked", identifier: identifier) public static var lockBgColorLocked = Color.primary
	@Preference("lockNeonMulUnlocked", identifier: identifier) public static var lockNeonMulUnlocked: Double = 1
	@Preference("lockNeonMulLocked", identifier: identifier) public static var lockNeonMulLocked: Double = 1
	@Preference("lockNeonColorUnlocked", identifier: identifier) public static var lockNeonColorUnlocked = Color.green
	@Preference("lockNeonColorLocked", identifier: identifier) public static var lockNeonColorLocked = Color.red
	@Preference("lockIconColorUnlocked", identifier: identifier) public static var lockIconColorUnlocked = Color
		.accentColor
	@Preference("lockIconColorLocked", identifier: identifier) public static var lockIconColorLocked = Color.accentColor
}
