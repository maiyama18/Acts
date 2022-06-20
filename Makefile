.PHONY: format
format:
	/opt/homebrew/bin/mint run swiftformat .

.PHONY: gen
gen:
	/opt/homebrew/bin/mint run swiftgen
