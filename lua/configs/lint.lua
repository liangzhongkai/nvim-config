local lint = require("lint")

lint.linters_by_ft = {
    lua = { "luacheck" },
    -- haskell = { "hlint" },
    python = { "flake8" },
    cpp = { "cpplint" },
    c = { "cpplint" },
}

lint.linters.luacheck.args = {
    "--globals",
    "love",
    "vim",
    "--formatter",
    "plain",
    "--codes",
    "--ranges",
    "-",
}

-- -- 定义 TscanCode 的 Linter 配置
-- lint.linters.tscancode = {
--     cmd = "/usr/local/bin/tscancode", -- 若未加入 PATH，需替换为绝对路径（如 "/path/to/tscancode"）
--     args = { "--enable=all", "-q" }, -- 启用所有规则，静默模式
--     stdin = false, -- 从文件读取
--     stream = "stderr", -- 输出到 stderr
--     parser = function(output)
--         -- 解析 TscanCode 输出为诊断信息（格式需适配 nvim-lint）
--         if output == nil or output == "" then
--             return {} -- 返回空诊断结果，避免 nil 报错
--         end
--         local diagnostics = {}
--         for line in output:gmatch("[^\n]+") do
--             if line:match("error|warning|style|serious|critical") then
--             -- 提取文件名、行号、错误信息（示例，需根据实际输出调整正则）
--             local fname, lnum, msg = line:match("(.+):(%d+):(.+)")
--             if fname and lnum then
--                 table.insert(diagnostics, {
--                     lnum = tonumber(lnum) - 1, -- Neovim 行号从 0 开始
--                     col = 0,
--                     message = msg,
--                     severity = vim.diagnostic.severity.WARN, -- 根据错误类型调整
--                     source = "tscancode",
--                 })
--             end
--             end
--         end
--         return diagnostics
--     end,
-- }

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
