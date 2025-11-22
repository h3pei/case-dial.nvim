---@class CaseDial
local M = {}

local config = require("case-dial.config")
local selector = require("case-dial.selector")
local detector = require("case-dial.detector")
local converter = require("case-dial.converter")
local utils = require("case-dial.utils")

---Dial the case of the text under cursor or selection
---@param mode string|nil The mode ("n" for normal, "v" for visual)
function M.dial(mode)
  mode = mode or vim.fn.mode()

  local text, start_row, start_col, end_row, end_col

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode
    text, start_row, start_col, end_row, end_col = selector.get_visual_selection()
    if not text then
      utils.notify_warn("No valid selection")
      return
    end
  else
    -- Normal mode
    text, start_col, end_col = selector.get_word_under_cursor()
    if not text then
      utils.notify_warn("No word under cursor")
      return
    end
    start_row = vim.fn.line(".") - 1
    end_row = start_row
  end

  -- Detect current case
  local current_case = detector.detect(text)
  if current_case == "unknown" then
    utils.notify_warn("Cannot detect case (needs 2+ word identifier)")
    return
  end

  -- Get next case
  local next_case = config.get_next_case(current_case)
  if not next_case then
    utils.notify_warn("No next case available")
    return
  end

  -- Convert to next case
  local converted = converter.convert(text, next_case)
  if not converted then
    utils.notify_error("Conversion failed")
    return
  end

  -- Replace text in buffer
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { converted })

  -- Reselect in visual mode to allow continuous dialing
  if mode == "v" or mode == "V" or mode == "\22" then
    local new_end_col = start_col + #converted
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { end_row + 1, new_end_col - 1 })
  end
end

---Setup the plugin with user configuration
---@param opts CaseDialConfig|nil User configuration options
function M.setup(opts)
  if not config.setup(opts) then
    return
  end

  -- Setup keymap if configured
  if config.keymap then
    vim.keymap.set("n", config.keymap, function()
      M.dial("n")
    end, { desc = "Dial case (normal mode)" })

    vim.keymap.set("v", config.keymap, function()
      -- Exit visual mode first to update '< and '> marks
      local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.api.nvim_feedkeys(esc, "nx", false)
      M.dial("v")
    end, { desc = "Dial case (visual mode)" })
  end
end

return M
