import XCTest

extension XCTestCase {
    func XCTAssertEqualAsync<T: Equatable>(
        _ expression1: @autoclosure () async throws -> T, _ expression2: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line
    ) async throws {
        let value = try await expression1()
        XCTAssertEqual(value, try expression2(), message(), file: file, line: line)
    }
}
