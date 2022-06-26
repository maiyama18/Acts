import SwiftUI

public extension Font {
    static var avenirTitle2: Font {
        Font.custom("AvenirNext-Regular", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)
    }

    static var avenirBody: Font {
        Font.custom("AvenirNext-Regular", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    static var avenirCallout: Font {
        Font.custom("AvenirNext-Regular", size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
    }

    static var avenirCaption: Font {
        Font.custom("AvenirNext-Regular", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
    }
}
