.PHONY: format
format:
	/opt/homebrew/bin/mint run swiftformat .

.PHONY: gen
gen:
	/opt/homebrew/bin/mint run swiftgen

.PHONY: mock
mock:
	/opt/homebrew/bin/mint run mockolo --sourcedirs ActsPackage/Sources --destination ActsPackage/Tests/ActsPackageTests/Generated/Mocks+Generated.swift --enable-args-history --custom-imports AuthAPI

.PHONY: test
test:
	xcodebuild -workspace Acts.xcworkspace -scheme ActsPackageTests -sdk iphonesimulator -destination platform='iOS Simulator,name=iPhone 13,OS=15.2' test
