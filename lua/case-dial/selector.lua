---@class CaseDialSelector
local M = {}

local IDENTIFIER_PATTERN = "[a-zA-Z0-9_-]"

---Get a single character at the specified position (1-indexed)
---@param str string The string to get the character from
---@param pos number The position (1-indexed)
---@return string char The character at the position
local function char_at(str, pos)
  return str:sub(pos, pos)
end

---Get the word under cursor in normal mode
---@return string|nil word The word under cursor
---@return number|nil row Row (0-indexed)
---@return number|nil start_col Start column (0-indexed)
---@return number|nil end_col End column (0-indexed, exclusive)
function M.get_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    return nil, nil, nil, nil
  end

  local current_line = vim.api.nvim_get_current_line()
  local current_col = vim.fn.col(".") -- 1-indexed
  local row = vim.fn.line(".") - 1 -- 0-indexed

  -- Find the word boundaries
  local start_col = current_col
  local end_col = current_col

  -- Move start_col to the beginning of the word
  while start_col > 1 and char_at(current_line, start_col - 1):match(IDENTIFIER_PATTERN) do
    start_col = start_col - 1
  end

  -- Move end_col to the end of the word
  while end_col < #current_line and char_at(current_line, end_col + 1):match(IDENTIFIER_PATTERN) do
    end_col = end_col + 1
  end

  local extracted_word = current_line:sub(start_col, end_col)

  return extracted_word, row, start_col - 1, end_col
end

---Get the selected text in visual mode
---@return string|nil text The selected text
---@return number|nil row Row (0-indexed)
---@return number|nil start_col Start column (0-indexed)
---@return number|nil end_col End column (0-indexed, exclusive)
function M.get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3]

  -- Handle special case for visual line mode
  if end_col == 2147483647 then
    local line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]
    end_col = #line
  end

  -- Only support single-line selection
  if start_row ~= end_row then
    return nil, nil, nil, nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)
  if #lines == 0 then
    return nil, nil, nil, nil
  end

  local extracted_word = lines[1]:sub(start_col + 1, end_col)

  return extracted_word, start_row, start_col, end_col
end

return M
