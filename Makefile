.PHONY: format
format:
	mint run swiftformat .

.PHONY: gen
gen:
	mint run swiftgen

.PHONY: mock
mock:
	mint run mockolo --sourcedirs ActsPackage/Sources --destination ActsPackage/Tests/ActsPackageTests/Generated/Mocks+Generated.swift --enable-args-history --custom-imports AuthAPI --custom-imports GitHubAPI

.PHONY: test
test:
	xcodebuild -workspace Acts.xcworkspace -scheme ActsPackageTests -sdk iphonesimulator -destination platform='iOS Simulator,name=iPhone 13' test
