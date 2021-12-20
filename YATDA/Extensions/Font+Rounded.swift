//
//  Font+Rounded.swift
//  YATDA
//
//  Created by Scott Bolin on 20-Dec-21.
//
// Thanks to Peter Friese for this extension
/* https://github.com/peterfriese/MakeItSo/tree/develop?utm_campaign=Not%20Only%20Swift%20Weekly&utm_medium=email&utm_source=Revue%20newsletter
 */
//

import SwiftUI

extension UIFontDescriptor {
    static func largeTitle() -> UIFontDescriptor? {
        UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold)
    }

    static func headline() -> UIFontDescriptor? {
        UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline).withSymbolicTraits(.traitBold)
    }

    func rounded() -> UIFontDescriptor? {
        self.withDesign(.rounded)
    }
}

// see https://gist.github.com/darrensapalo/bd6dddab6a70ae0a2d6cf8ac5aeb6b1a for more
extension UIFont {
    static func roundedLargeTitle() -> UIFont? {
        guard let descriptor = UIFontDescriptor.largeTitle()?.rounded() else { return nil }
        return UIFont(descriptor: descriptor, size: 0)
    }

    static func roundedHeadline() -> UIFont? {
        guard let descriptor = UIFontDescriptor.headline()?.rounded() else { return nil }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension View {
}
