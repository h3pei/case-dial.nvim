---@class CaseDialConverter
local M = {}

---Split a string into words based on its case type
---@param str string The string to split
---@return string[] words Array of lowercase words
local function split_into_words(str)
  local words = {}

  -- Check for underscore or hyphen separators first
  if str:find("_") then
    for word in str:gmatch("[^_]+") do
      table.insert(words, word:lower())
    end
    return words
  end

  if str:find("-") then
    for word in str:gmatch("[^-]+") do
      table.insert(words, word:lower())
    end
    return words
  end

  -- Handle camelCase and PascalCase
  local current_word = ""
  for i = 1, #str do
    local char = str:sub(i, i)
    local is_upper = char:match("[A-Z]")

    if is_upper and #current_word > 0 then
      -- Check if this is the start of a new word
      local prev_char = str:sub(i - 1, i - 1)
      local prev_is_lower = prev_char:match("[a-z]")

      if prev_is_lower then
        -- lowercase followed by uppercase = new word
        table.insert(words, current_word:lower())
        current_word = char
      else
        -- Handle consecutive uppercase (e.g., "XMLParser" -> "XML", "Parser")
        local next_char = str:sub(i + 1, i + 1)
        local next_is_lower = next_char and next_char:match("[a-z]")

        if next_is_lower and #current_word > 0 then
          table.insert(words, current_word:lower())
          current_word = char
        else
          current_word = current_word .. char
        end
      end
    else
      current_word = current_word .. char
    end
  end

  if #current_word > 0 then
    table.insert(words, current_word:lower())
  end

  return words
end

---Convert words to snake_case
---@param words string[] Array of lowercase words
---@return string
local function to_snake(words)
  return table.concat(words, "_")
end

---Convert words to PascalCase
---@param words string[] Array of lowercase words
---@return string
local function to_pascal(words)
  local result = {}
  for _, word in ipairs(words) do
    table.insert(result, word:sub(1, 1):upper() .. word:sub(2))
  end
  return table.concat(result, "")
end

---Convert words to camelCase
---@param words string[] Array of lowercase words
---@return string
local function to_camel(words)
  local result = {}
  for i, word in ipairs(words) do
    if i == 1 then
      table.insert(result, word)
    else
      table.insert(result, word:sub(1, 1):upper() .. word:sub(2))
    end
  end
  return table.concat(result, "")
end

---Convert words to CONSTANT_CASE
---@param words string[] Array of lowercase words
---@return string
local function to_constant(words)
  local result = {}
  for _, word in ipairs(words) do
    table.insert(result, word:upper())
  end
  return table.concat(result, "_")
end

---Convert words to kebab-case
---@param words string[] Array of lowercase words
---@return string
local function to_kebab(words)
  return table.concat(words, "-")
end

---@type table<string, fun(words: string[]): string>
local converters = {
  snake = to_snake,
  pascal = to_pascal,
  camel = to_camel,
  constant = to_constant,
  kebab = to_kebab,
}

---Convert a string to the specified case type
---@param str string The string to convert
---@param target_case string The target case type ("snake", "pascal", "camel", "constant", "kebab")
---@return string|nil converted The converted string, or nil if conversion failed
function M.convert(str, target_case)
  if not str or str == "" then
    return nil
  end

  local converter = converters[target_case]
  if not converter then
    return nil
  end

  local words = split_into_words(str)
  if #words == 0 then
    return nil
  end

  return converter(words)
end

---Get all available case types
---@return string[] case_types Array of case type names
function M.get_case_types()
  return { "snake", "pascal", "camel", "constant", "kebab" }
end

return M
