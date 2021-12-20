//
//  HighlightTextField.swift
//  YATDA
//
//  Created by Scott Bolin on 20-Dec-21.
//

import UIKit
import SwiftUI

struct HighlightTextField: UIViewRepresentable {

    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: HighlightTextField

        init(parent: HighlightTextField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        }
    }
}
