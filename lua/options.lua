require("nvchad.options")

local o = vim.o
-- Indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

local wo = vim.wo
wo.foldmethod = "expr"
wo.foldexpr = "nvim_treesitter#foldexpr()"
wo.foldenable = true
wo.foldlevel = 99
wo.foldcolumn = "3"
wo.cursorlineopt = "both"

-- o.cursorlineopt ='both' -- to enable cursorline!

-- set filetype for .CBL COBOL files.
-- vim.cmd([[ au BufRead,BufNewFile *.CBL set filetype=cobol ]])
