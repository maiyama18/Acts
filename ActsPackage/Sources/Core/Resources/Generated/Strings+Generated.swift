// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
    public enum Common {
        /// Cancel
        public static let cancel = L10n.tr("Localizable", "common.cancel")
        /// Delete
        public static let delete = L10n.tr("Localizable", "common.delete")
        /// Error
        public static let error = L10n.tr("Localizable", "common.error")
        /// OK
        public static let ok = L10n.tr("Localizable", "common.ok")
    }

    public enum ErrorMessage {
        /// Network disconnected
        public static let disconnected = L10n.tr("Localizable", "error_message.disconnected")
        /// Unexpected error occurred
        public static let unexpectedError = L10n.tr("Localizable", "error_message.unexpected_error")
    }

    public enum SignInFeature {
        /// Sign In with GitHub
        public static let signInWithGithub = L10n.tr("Localizable", "sign_in_feature.sign_in_with_github")
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable convenience_type