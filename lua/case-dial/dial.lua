local M = {}

local config = require("case-dial.config")
local selector = require("case-dial.selector")
local detector = require("case-dial.detector")
local converter = require("case-dial.converter")
local utils = require("case-dial.utils")

---Get the next case type in the dial
---@param current_case string The current case type
---@return string|nil next_case The next case type, or nil if not found
local function get_next_case(current_case)
  local cases = config.cases

  local idx = config.case_index[current_case]
  if not idx then
    return cases[1]
  end

  local next_index = (idx % #cases) + 1
  return cases[next_index]
end

---Internal function to detect, convert, and replace text
---@param text string The text to convert
---@param row number Row (0-indexed)
---@param start_col number Start column
---@param end_col number End column
---@return string|nil converted The converted text, or nil if failed
local function dial(text, row, start_col, end_col)
  -- Detect current case
  local current_case = detector.detect(text)
  if current_case == "unknown" then
    utils.notify_warn("Cannot detect case (needs 2+ word identifier)")
    return nil
  end

  -- Get next case
  local next_case = get_next_case(current_case)
  if not next_case then
    utils.notify_warn("No next case available")
    return nil
  end

  -- Convert to next case
  local converted = converter.convert(text, next_case)
  if not converted then
    utils.notify_error("Conversion failed")
    return nil
  end

  -- Replace text in buffer
  vim.api.nvim_buf_set_text(0, row, start_col, row, end_col, { converted })

  return converted
end

---Dial the case of the word under cursor (Normal mode)
function M.dial_normal()
  local text, row, start_col, end_col = selector.get_word_under_cursor()
  if not text then
    utils.notify_warn("No word under cursor")
    return
  end

  dial(text, row, start_col, end_col)
end

---Dial the case of the visual selection (Visual mode)
function M.dial_visual()
  -- Exit visual mode first to update '< and '> marks
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)

  local text, row, start_col, end_col = selector.get_visual_selection()
  if not text then
    utils.notify_warn("No valid selection")
    return
  end

  local converted = dial(text, row, start_col, end_col)
  if not converted then
    return
  end

  -- Reselect to allow continuous dialing
  local new_end_col = start_col + #converted
  vim.api.nvim_win_set_cursor(0, { row + 1, start_col })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { row + 1, new_end_col - 1 })
end

return M
