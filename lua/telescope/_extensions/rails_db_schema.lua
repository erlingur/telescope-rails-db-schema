local has_telescope, telescope = pcall(require, 'telescope')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"
local make_entry = require "telescope.make_entry"
local io = require('io')

if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

M = {}

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

M.rails_db_schema = function(opts)
  local current_file = vim.fn.expand("%:p")
  local schema_file = vim.fn.getcwd() .. "/db/schema.rb"

  if not file_exists(schema_file) then
    print("No schema.rb file found")
    return
  end

  local command = "egrep -n create_table " .. schema_file
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  local tables = {}
  for line in result:gmatch("[^\r\n]+") do
    local table_name = line:match("create_table \"(.*)\"")
    if table_name then
      local row = {}
      row["name"] = table_name
      row["line"] = tonumber(split(line, ":")[1])
      table.insert(tables, row)
    end
  end

  opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Tables",
    finder = finders.new_table {
      results = tables,
      entry_maker = function(line)
        return make_entry.set_default_entry_mt({
          ordinal = line["name"],
          display = line["name"],
          filename = schema_file,
          lnum = line["line"],
        }, opts)
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = conf.grep_previewer(opts)
  }):find()
end

return telescope.register_extension {
  exports = {
    rails_db_schema = M.rails_db_schema
  },
}

