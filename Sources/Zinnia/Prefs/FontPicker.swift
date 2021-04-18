//
//  FontPicker.swift
//
//
//  Created by Aspen on 4/18/21.

import SwiftUI
import UIKit

internal struct FontPicker: UIViewControllerRepresentable {
	@Binding var font: UIFontDescriptor?
	@Environment(\.presentationMode) var presentationMode

	func makeCoordinator() -> FontPicker.Coordinator {
		Coordinator(self)
	}

	func makeUIViewController(context: Context) -> UIFontPickerViewController {
		let picker = UIFontPickerViewController()
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_: UIFontPickerViewController, context _: Context) {}
}

internal extension FontPicker {
	class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
		var parent: FontPicker
		@Environment(\.presentationMode) var presentationMode

		init(_ parent: FontPicker) {
			self.parent = parent
		}

		func fontPickerViewControllerDidCancel(_: UIFontPickerViewController) {}

		func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
			parent.font = viewController.selectedFontDescriptor
			parent.presentationMode.wrappedValue.dismiss()
		}
	}
}
