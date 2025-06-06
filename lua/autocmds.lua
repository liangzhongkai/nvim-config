require "nvchad.autocmds"

vim.api.nvim_create_user_command("ReloadAll", function()
  vim.cmd("silent! checktime")
  vim.notify("all files reloaded", vim.log.levels.INFO)
end, { desc = "强制刷新所有打开文件" })
