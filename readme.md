# Telescope Rails DB Schema

This is a plugin for Neovim that adds `:Telescope rails_db_schema` extension
that will show all the tables in your `db/schema.rb` file and allow you to jump
to the table definition.

# Installation

With Packer
```
use {
  "erlingur/telescope-rails-db-schema",
  config = function()
    require('telescope').load_extension('rails_db_schema')
  end
}
```
