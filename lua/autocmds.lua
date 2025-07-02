require "nvchad.autocmds"

vim.api.nvim_create_user_command("ReloadAll", function()
  vim.cmd("silent! checktime")
  vim.notify("all files reloaded", vim.log.levels.INFO)
end, { desc = "强制刷新所有打开文件" })

-- -- 定义 Quickfix 搜索函数
-- function SearchInclude(query)
--     local cmd = "rg --vimgrep --type=c,h --no-heading " .. vim.fn.shellescape(query)
--     local results = vim.fn.systemlist(cmd)
--     vim.fn.setqflist({}, ' ', { title = 'Includes', lines = results })
--     vim.cmd('copen')  -- 打开 Quickfix 窗口
-- end
