import AuthenticationServices

public extension ASWebAuthenticationSession {
    static func start(url: URL, callbackURLScheme: String, presentationContextProvider: ASWebAuthenticationPresentationContextProviding) async throws -> URL? {
        var session: ASWebAuthenticationSession?
        let onCancel = { session?.cancel() }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { cont in
                session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                    if let error = error {
                        cont.resume(throwing: error)
                        return
                    }
                    cont.resume(returning: callbackURL)
                }
                session?.presentationContextProvider = presentationContextProvider
                session?.start()
            }
        } onCancel: {
            onCancel()
        }
    }
}
