require("nvchad.mappings")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "快速退出插入模式" })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>ai", "<cmd>ChatGPT<CR>", { desc = "打开 AI 助手" })

map({ "t" }, "vsp", "vsplit<CR>", { desc = "水平分屏" })
map({ "t" }, "sp", "split<CR>", { desc = "垂直分屏" })

map("n", "<leader>z", "za", { desc = "切换折叠" })
--map("n", "<leader>z", "zx", { desc = "update折叠" })
map("n", "<leader>zo", "zR", { desc = "展开所有" })
map("n", "<leader>zc", "zM", { desc = "收起所有" })

map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "history undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd> redo <cr>", { desc = "history redo" })

map({ "n", "i", "v", "t" }, "<A-v>", function()
    require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm" })
end, { desc = "terminal toggle vertical term" })
map({ "n", "i", "v", "t" }, "<A-h>", function()
    require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "terminal toggle horizontal term" })
map({ "n", "i", "v", "t" }, "<A-i>", function()
    require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "terminal toggle floating term" })

map(
    { "n", "i", "v", "t" },
    "<C-p>",
    "<cmd> echo expand('%:p') <cr>",
    { desc = "显示当前文件的全路径" }
)

-- dap
map("n", "<F5>", function()
    require("dap").continue()
end, { desc = "开始调试 or 继续" })
map("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "下一步" })
map("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "进入看看" })
map("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "跳转定义" })
map("n", "<F4>", function()
    require("dap").toggle_breakpoint()
end, { desc = "设置断点" })
map("n", "<Leader>dr", function()
    require("dap").repl.open()
end, { desc = "命令窗口" })
