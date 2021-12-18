//
//  AddTodoButton.swift
//  YATDA
//
//  Created by Scott Bolin on 25-Oct-21.
//

import SwiftUI

struct AddTodoButton: View {
    @State private var clickCount: Double = 0
    let action: () -> ()
    let isDisabled: Bool

    var body: some View {
        Button {
            withAnimation {
                self.action()
            }
        } label: {
            Image(systemName: "arrow.up.circle")
                .rotationEffect(.radians(2 * Double.pi * clickCount))
                .animation(.easeOut(duration: 0.1), value: clickCount)
        }
        .disabled(isDisabled)
    }
}

//struct AddTodoButton_Previews: PreviewProvider {
//    let closure: () -> ()
//    static var previews: some View {
//        AddTodoButton(action: closure, isDisabled: false)
//    }
//}
