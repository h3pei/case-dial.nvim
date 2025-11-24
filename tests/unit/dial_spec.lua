local config = require("case-dial.config")

describe("dial", function()
  local dial
  local selector
  local utils

  -- Store original vim functions
  local original_nvim_buf_set_text
  local original_nvim_win_set_cursor
  local original_nvim_replace_termcodes
  local original_nvim_feedkeys
  local original_fn_line
  local original_cmd

  before_each(function()
    -- Reset config
    config.cases = { "snake", "pascal", "camel", "constant", "kebab" }
    config.case_index = {
      snake = 1,
      pascal = 2,
      camel = 3,
      constant = 4,
      kebab = 5,
    }
    config.keymap = "<C-\\>"

    -- Store original vim functions
    original_nvim_buf_set_text = vim.api.nvim_buf_set_text
    original_nvim_win_set_cursor = vim.api.nvim_win_set_cursor
    original_nvim_replace_termcodes = vim.api.nvim_replace_termcodes
    original_nvim_feedkeys = vim.api.nvim_feedkeys
    original_fn_line = vim.fn.line
    original_cmd = vim.cmd

    -- Clear module cache to get fresh instances
    package.loaded["case-dial.dial"] = nil
    package.loaded["case-dial.selector"] = nil
    package.loaded["case-dial.utils"] = nil

    -- Setup vim mocks
    vim.api.nvim_buf_set_text = function() end
    vim.api.nvim_win_set_cursor = function() end
    vim.api.nvim_replace_termcodes = function(str)
      return str
    end
    vim.api.nvim_feedkeys = function() end
    vim.fn.line = function()
      return 1
    end
    vim.cmd = function() end

    -- Load modules
    dial = require("case-dial.dial")
    selector = require("case-dial.selector")
    utils = require("case-dial.utils")

    -- Mock utils to suppress notifications
    utils.notify_warn = function() end
    utils.notify_error = function() end
  end)

  after_each(function()
    -- Restore vim functions
    vim.api.nvim_buf_set_text = original_nvim_buf_set_text
    vim.api.nvim_win_set_cursor = original_nvim_win_set_cursor
    vim.api.nvim_replace_termcodes = original_nvim_replace_termcodes
    vim.api.nvim_feedkeys = original_nvim_feedkeys
    vim.fn.line = original_fn_line
    vim.cmd = original_cmd
  end)

  describe("dial_normal", function()
    it("should convert word under cursor from snake to pascal case", function()
      -- Mock selector to return a snake_case word
      selector.get_word_under_cursor = function()
        return "hello_world", 0, 0, 11
      end

      -- Track what was set
      local set_text_args = nil
      vim.api.nvim_buf_set_text = function(buf, sr, sc, er, ec, lines)
        set_text_args = { buf = buf, sr = sr, sc = sc, er = er, ec = ec, lines = lines }
      end

      dial.dial_normal()

      assert.is_not_nil(set_text_args)
      assert.are.equal("HelloWorld", set_text_args.lines[1])
    end)

    it("should warn when no word under cursor", function()
      selector.get_word_under_cursor = function()
        return nil
      end

      local warned = false
      utils.notify_warn = function(msg)
        if msg == "No word under cursor" then
          warned = true
        end
      end

      dial.dial_normal()

      assert.is_true(warned)
    end)

    it("should warn when case cannot be detected", function()
      -- Single word without case indicators
      selector.get_word_under_cursor = function()
        return "hello", 0, 0, 5
      end

      local warned = false
      utils.notify_warn = function(msg)
        if msg:match("Cannot detect case") then
          warned = true
        end
      end

      dial.dial_normal()

      assert.is_true(warned)
    end)

    it("should cycle through all cases", function()
      local test_cases = {
        { input = "hello_world", expected = "HelloWorld" }, -- snake -> pascal
        { input = "HelloWorld", expected = "helloWorld" }, -- pascal -> camel
        { input = "helloWorld", expected = "HELLO_WORLD" }, -- camel -> constant
        { input = "HELLO_WORLD", expected = "hello-world" }, -- constant -> kebab
        { input = "hello-world", expected = "hello_world" }, -- kebab -> snake
      }

      for _, tc in ipairs(test_cases) do
        selector.get_word_under_cursor = function()
          return tc.input, 0, 0, #tc.input
        end

        local result = nil
        vim.api.nvim_buf_set_text = function(_, _, _, _, _, lines)
          result = lines[1]
        end

        dial.dial_normal()

        assert.are.equal(tc.expected, result, "Failed for input: " .. tc.input)
      end
    end)
  end)

  describe("dial_visual", function()
    it("should convert visual selection from snake to pascal case", function()
      -- Mock selector to return a visual selection
      selector.get_visual_selection = function()
        return "hello_world", 0, 0, 11
      end

      local set_text_args = nil
      vim.api.nvim_buf_set_text = function(buf, sr, sc, er, ec, lines)
        set_text_args = { buf = buf, sr = sr, sc = sc, er = er, ec = ec, lines = lines }
      end

      local cursor_calls = {}
      vim.api.nvim_win_set_cursor = function(win, pos)
        table.insert(cursor_calls, { win = win, pos = pos })
      end

      dial.dial_visual()

      assert.is_not_nil(set_text_args)
      assert.are.equal("HelloWorld", set_text_args.lines[1])
      -- Should reselect after conversion
      assert.are.equal(2, #cursor_calls)
    end)

    it("should warn when no valid selection", function()
      selector.get_visual_selection = function()
        return nil
      end

      local warned = false
      utils.notify_warn = function(msg)
        if msg == "No valid selection" then
          warned = true
        end
      end

      dial.dial_visual()

      assert.is_true(warned)
    end)

    it("should reselect with correct positions after conversion", function()
      selector.get_visual_selection = function()
        return "hello_world", 0, 5, 16
      end

      local cursor_positions = {}
      vim.api.nvim_win_set_cursor = function(_, pos)
        table.insert(cursor_positions, pos)
      end

      dial.dial_visual()

      -- First cursor: start of selection (row + 1, start_col)
      assert.are.same({ 1, 5 }, cursor_positions[1])
      -- Second cursor: end of new selection (row + 1, start_col + #converted - 1)
      -- "hello_world" -> "HelloWorld" (11 -> 10 chars)
      assert.are.same({ 1, 14 }, cursor_positions[2])
    end)

    it("should cycle through all cases", function()
      local test_cases = {
        { input = "hello_world", expected = "HelloWorld" },
        { input = "HelloWorld", expected = "helloWorld" },
        { input = "helloWorld", expected = "HELLO_WORLD" },
        { input = "HELLO_WORLD", expected = "hello-world" },
        { input = "hello-world", expected = "hello_world" },
      }

      for _, tc in ipairs(test_cases) do
        selector.get_visual_selection = function()
          return tc.input, 0, 0, #tc.input
        end

        local result = nil
        vim.api.nvim_buf_set_text = function(_, _, _, _, _, lines)
          result = lines[1]
        end

        dial.dial_visual()

        assert.are.equal(tc.expected, result, "Failed for input: " .. tc.input)
      end
    end)
  end)

  describe("with custom case order", function()
    before_each(function()
      -- Set custom case order
      config.cases = { "camel", "snake" }
      config.case_index = {
        camel = 1,
        snake = 2,
      }
    end)

    it("should follow custom case order in dial_normal", function()
      selector.get_word_under_cursor = function()
        return "helloWorld", 0, 0, 10
      end

      local result = nil
      vim.api.nvim_buf_set_text = function(_, _, _, _, _, lines)
        result = lines[1]
      end

      dial.dial_normal()

      -- camel -> snake
      assert.are.equal("hello_world", result)
    end)

    it("should wrap around in custom case order", function()
      selector.get_word_under_cursor = function()
        return "hello_world", 0, 0, 11
      end

      local result = nil
      vim.api.nvim_buf_set_text = function(_, _, _, _, _, lines)
        result = lines[1]
      end

      dial.dial_normal()

      -- snake -> camel (wraps around)
      assert.are.equal("helloWorld", result)
    end)
  end)
end)
