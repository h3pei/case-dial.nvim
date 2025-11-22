.PHONY: test test-file lint format help

test:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua'}"

test-file:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile $(FILE)"

lint:
	luacheck lua/ tests/

format:
	stylua lua/ tests/

help:
	@echo "Available targets:"
	@echo "  test        - Run all tests"
	@echo "  test-file   - Run specific test file (usage: make test-file FILE=tests/unit/detector_spec.lua)"
	@echo "  lint        - Run luacheck"
	@echo "  format      - Run stylua"
	@echo "  help        - Show this help"
