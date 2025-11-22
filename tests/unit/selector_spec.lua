local helpers = require("tests.helpers")
local selector = require("case-dial.selector")

describe("selector", function()
  local bufnr

  after_each(function()
    helpers.cleanup_buffer(bufnr)
  end)

  describe("get_word_under_cursor", function()
    it("should return snake_case word", function()
      bufnr = helpers.setup_buffer("local foo_bar = 1", { 1, 8 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.are.equal("foo_bar", word)
      assert.are.equal(6, start_col)
      assert.are.equal(13, end_col)
    end)

    it("should return camelCase word", function()
      bufnr = helpers.setup_buffer("local fooBar = 1", { 1, 8 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.are.equal("fooBar", word)
      assert.are.equal(6, start_col)
      assert.are.equal(12, end_col)
    end)

    it("should return kebab-case word", function()
      bufnr = helpers.setup_buffer("foo-bar-baz", { 1, 5 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.are.equal("foo-bar-baz", word)
      assert.are.equal(0, start_col)
      assert.are.equal(11, end_col)
    end)

    it("should return word at beginning of line", function()
      bufnr = helpers.setup_buffer("foo_bar = 1", { 1, 0 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.are.equal("foo_bar", word)
      assert.are.equal(0, start_col)
      assert.are.equal(7, end_col)
    end)

    it("should return word at end of line", function()
      bufnr = helpers.setup_buffer("x = foo_bar", { 1, 10 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.are.equal("foo_bar", word)
      assert.are.equal(4, start_col)
      assert.are.equal(11, end_col)
    end)

    it("should return nil for empty line", function()
      bufnr = helpers.setup_buffer("", { 1, 0 })

      local word, start_col, end_col = selector.get_word_under_cursor()
      assert.is_nil(word)
      assert.is_nil(start_col)
      assert.is_nil(end_col)
    end)
  end)

  describe("get_visual_selection", function()
    it("should return selected text", function()
      bufnr = helpers.setup_buffer("local foo_bar = 1", { 1, 6 })
      -- Set visual selection marks
      vim.fn.setpos("'<", { bufnr, 1, 7, 0 })
      vim.fn.setpos("'>", { bufnr, 1, 13, 0 })

      local text, start_row, start_col, end_row, end_col = selector.get_visual_selection()
      assert.are.equal("foo_bar", text)
      assert.are.equal(0, start_row)
      assert.are.equal(6, start_col)
      assert.are.equal(0, end_row)
      assert.are.equal(13, end_col)
    end)

    it("should return partial word selection", function()
      bufnr = helpers.setup_buffer("greater_than_or_equal_to", { 1, 0 })
      -- Select "greater_than" only
      vim.fn.setpos("'<", { bufnr, 1, 1, 0 })
      vim.fn.setpos("'>", { bufnr, 1, 12, 0 })

      local text, start_row, start_col, end_row, end_col = selector.get_visual_selection()
      assert.are.equal("greater_than", text)
      assert.are.equal(0, start_row)
      assert.are.equal(0, start_col)
      assert.are.equal(0, end_row)
      assert.are.equal(12, end_col)
    end)

    it("should return nil for multi-line selection", function()
      bufnr = helpers.setup_buffer("foo_bar\nbaz_qux", { 1, 0 })
      -- Set multi-line selection
      vim.fn.setpos("'<", { bufnr, 1, 1, 0 })
      vim.fn.setpos("'>", { bufnr, 2, 7, 0 })

      local text = selector.get_visual_selection()
      assert.is_nil(text)
    end)

    it("should handle selection at line start", function()
      bufnr = helpers.setup_buffer("foo_bar = 1", { 1, 0 })
      vim.fn.setpos("'<", { bufnr, 1, 1, 0 })
      vim.fn.setpos("'>", { bufnr, 1, 7, 0 })

      local text, start_row, start_col, end_row, end_col = selector.get_visual_selection()
      assert.are.equal("foo_bar", text)
      assert.are.equal(0, start_row)
      assert.are.equal(0, start_col)
      assert.are.equal(0, end_row)
      assert.are.equal(7, end_col)
    end)
  end)
end)
