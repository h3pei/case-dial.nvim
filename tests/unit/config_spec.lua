local config = require("case-dial.config")

describe("config", function()
  -- Reset config before each test
  before_each(function()
    config.config = {
      cases = { "snake", "pascal", "camel", "constant", "kebab" },
      keymap = "<C-\\>",
    }
    -- Reset case_index for O(1) lookup
    config.case_index = {
      snake = 1,
      pascal = 2,
      camel = 3,
      constant = 4,
      kebab = 5,
    }
  end)

  -- Helper to set cases and case_index together
  local function set_cases(cases)
    config.cases = cases
    config.case_index = {}
    for i, case in ipairs(cases) do
      config.case_index[case] = i
    end
  end

  describe("validate", function()
    it("should accept all valid case types", function()
      local is_valid = config.validate({
        cases = { "snake", "pascal", "camel", "constant", "kebab" },
        keymap = "<C-\\>",
      })

      assert.is_true(is_valid)
    end)

    it("should return true for valid config", function()
      local is_valid = config.validate({
        cases = { "snake", "pascal", "camel" },
        keymap = "<C-\\>",
      })

      assert.is_true(is_valid)
    end)

    it("should return false for invalid case type", function()
      local is_valid = config.validate({
        cases = { "snake", "invalid_case" },
        keymap = "<C-\\>",
      })

      assert.is_false(is_valid)
    end)

    it("should return false for less than 2 case types", function()
      local is_valid = config.validate({
        cases = { "snake" },
        keymap = "<C-\\>",
      })

      assert.is_false(is_valid)
    end)
  end)

  describe("setup", function()
    it("should apply valid config", function()
      local opts = {
        cases = { "snake", "camel" },
        keymap = "<C-k>",
      }
      local success = config.setup(opts)
      assert.is_true(success)
      assert.are.same({ "snake", "camel" }, config.cases)
      assert.are.equal("<C-k>", config.keymap)
    end)

    it("should return false for invalid config", function()
      local opts = {
        cases = { "invalid" },
      }
      local success = config.setup(opts)
      assert.is_false(success)
    end)

    it("should merge with default config", function()
      local opts = {
        cases = { "pascal", "camel" },
      }
      local success = config.setup(opts)
      assert.is_true(success)
      assert.are.same({ "pascal", "camel" }, config.cases)
      assert.are.equal("<C-\\>", config.keymap) -- default keymap preserved
    end)

    it("should handle nil opts", function()
      local success = config.setup(nil)
      assert.is_true(success)
      -- Should use defaults
      assert.are.same({ "snake", "pascal", "camel", "constant", "kebab" }, config.cases)
    end)

    it("should allow disabling keymap with false", function()
      local opts = {
        keymap = false,
      }
      local success = config.setup(opts)
      assert.is_true(success)
      assert.is_false(config.keymap)
    end)
  end)

  describe("get_next_case", function()
    it("should return next case in dial", function()
      set_cases({ "snake", "pascal", "camel" })

      assert.are.equal("pascal", config.get_next_case("snake"))
      assert.are.equal("camel", config.get_next_case("pascal"))
      assert.are.equal("snake", config.get_next_case("camel"))
    end)

    it("should wrap around at the end", function()
      set_cases({ "snake", "pascal" })

      assert.are.equal("snake", config.get_next_case("pascal"))
    end)

    it("should return first case for unknown config case", function()
      set_cases({ "snake", "pascal", "camel" })

      assert.are.equal("snake", config.get_next_case("unknown"))
    end)

    it("should work with custom case order", function()
      set_cases({ "camel", "snake", "constant" })

      assert.are.equal("snake", config.get_next_case("camel"))
      assert.are.equal("constant", config.get_next_case("snake"))
      assert.are.equal("camel", config.get_next_case("constant"))
    end)

    it("should work with two cases", function()
      set_cases({ "snake", "camel" })

      assert.are.equal("camel", config.get_next_case("snake"))
      assert.are.equal("snake", config.get_next_case("camel"))
    end)
  end)
end)
