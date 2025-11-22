---@class CaseDialSelector
local M = {}

---Get the word under cursor in normal mode
---@return string|nil word The word under cursor
---@return number|nil start_col Start column (0-indexed)
---@return number|nil end_col End column (0-indexed, exclusive)
function M.get_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    return nil, nil, nil
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".") - 1 -- 0-indexed

  -- Find the word boundaries
  local start_col = col
  local end_col = col

  -- Move start_col to the beginning of the word
  while start_col > 0 do
    local char = line:sub(start_col, start_col)
    if not char:match("[a-zA-Z0-9_-]") then
      break
    end
    start_col = start_col - 1
  end
  -- Adjust if we stopped on a non-identifier character or went past the start
  if start_col == 0 then
    -- We reached the beginning; check if first char is identifier
    if line:sub(1, 1):match("[a-zA-Z0-9_-]") then
      start_col = 1
    else
      start_col = 2
    end
  else
    start_col = start_col + 1
  end

  -- Move end_col to the end of the word
  while end_col < #line do
    local char = line:sub(end_col + 1, end_col + 1)
    if not char:match("[a-zA-Z0-9_-]") then
      break
    end
    end_col = end_col + 1
  end

  local extracted_word = line:sub(start_col, end_col)
  return extracted_word, start_col - 1, end_col
end

---Get the selected text in visual mode
---@return string|nil text The selected text
---@return number|nil start_row Start row (0-indexed)
---@return number|nil start_col Start column (0-indexed)
---@return number|nil end_row End row (0-indexed)
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
    return nil, nil, nil, nil, nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)
  if #lines == 0 then
    return nil, nil, nil, nil, nil
  end

  local text = lines[1]:sub(start_col + 1, end_col)
  return text, start_row, start_col, end_row, end_col
end

return M
