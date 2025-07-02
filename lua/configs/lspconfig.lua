local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- list of all servers configured.
lspconfig.servers = {
    "lua_ls",
    "clangd",
    -- "gopls",
    -- "hls",
    -- "ols",
    "pyright",
}

-- list of servers configured with default config.
local default_servers = {
    -- "clangd",
    -- "ols",
    "pyright",
}

-- lsps with default config
for _, lsp in ipairs(default_servers) do
    lspconfig[lsp].setup({
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    })
end

lspconfig.clangd.setup({
    on_attach = function(client, bufnr)
        vim.notify(
            "clangd loaded. arguments: "
                .. vim.inspect(client.config.settings.clangd.fallbackFlags)
        )
        -- vim.api.nvim_buf_set_keymap(
        --     bufnr,
        --     "n",
        --     "<leader>ca",
        --     "<cmd>lua vim.lsp.buf.code_action()<CR>",
        --     { noremap = true, silent = true, desc = "LSP 代码操作" }
        -- )
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.codeActionProvider = true
        -- 添加代码操作映射（快速修复缺失头文件等）
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
            buffer = bufnr,
            desc = "LSP 代码操作",
        })
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    -- on_init = function(client)
    --     client.config.flags = client.config.flags or {}
    --     client.config.flags.allow_stderr_messages = false
    --     -- 确保调用原始的on_init
    --     if on_init then on_init(client) end
    -- end,
    capabilities = capabilities,
    init_options = {
        -- fallbackFlags = { "-std=c++20", "--stdlib=libc++" },
        fallbackFlags = { "-std=c++2b" },
        clangdFileStatus = true,
        clangd = {
            formatting = false, -- 关键：禁用 clangd 自带的格式化
            -- 禁用与 cpplint 重叠的风格检查（如缩进）
            extraArgs = { "--clang-tidy-checks=-readability*,-whitespace*" },
        },
    },
    -- cmd = {
    --     "clangd",
    --     "--background-index",
    --     "--completion-style=detailed",
    --     "--header-insertion=iwyu",
    --     "--query-driver=/usr/bin/clang++",
    --     "--compile-commands-dir=.",
    --     "--clang-tidy",
    --     "--log=verbose",
    -- },
    settings = {
        clangd = {
            arguments = {
                "--background-index",
                "--completion-style=detailed",
                "--header-insertion=iwyu", -- 启用Include What You Use风格的头文件插入
                "--all-scopes-completion", -- 确保更全面的补全建议
                "--query-driver=/usr/bin/clang++",
                "--compile-commands-dir=.",
                "--clang-tidy",
                "--log=verbose",
            },
            -- from `clang -print-resource-dir`
            -- "resourceDir": "/usr/lib/llvm-17/lib/clang/17",
            fallbackFlags = { -- ✅ 正确传递编译器标志
                -- "-std=c++2b",
                -- "-stdlib=libc++",
                -- include paths from `clang -v -fsyntax-only -x c++ /dev/null`
                -- "-isystem/home/kctubt/dev",
                -- "-isystem/home/kctubt/dev/yanlanting/include",
                -- "-isystem/home/kctubt/dev/gtest/include",
                -- "-isystem/home/kctubt/dev/boost/1.84.0/include",
                -- "-isystem/usr/include/c++/12",
                -- "-isystem/usr/include/x86_64-linux-gnu/c++/12",
                -- "-isystem/usr/include/c++/12/backward",
                -- "-isystem/usr/lib/llvm-21/lib/clang/21/include",
                -- "-isystem/usr/local/include",
                -- "-isystem/usr/include/x86_64-linux-gnu",
                -- "-isystem/usr/include",
                -- "-Wno-unused-parameter",
                -- "-Wno-unknown-pragmas",
                -- "-Wno-unused-variable",
                -- "-Wno-deprecated-declarations",
                -- "-Wno-ignored-attributes",
                -- "-Wno-unknown-pragmas",
            },
        },
    },
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    disableDiagnostics = false,
    filetypes = {
        "h",
        "hpp",
        "hxx",
        "c",
        "cc",
        "cpp",
        "c++",
        "objc",
        "objcpp",
        "cuda",
        "cu",
    },
})

-- lspconfig.ccls.setup({
--     on_attach = function(client, bufnr)
--         client.server_capabilities.documentFormattingProvider = false
--         client.server_capabilities.documentRangeFormattingProvider = false
--         on_attach(client, bufnr)
--     end,
--     on_init = on_init,
--     capabilities = capabilities,
--     init_options = {
--         compilationDatabaseDirectory = "build", -- 指定编译数据库目录
--         cache = { directory = ".ccls-cache" },
--     },
--     cmd = {
--         "ccls",
--     },
--     root_dir = function(fname)
--         return lspconfig.util.root_pattern("compile_commands.json", ".ccls")(
--             fname
--         )
--     end,
-- })

lspconfig.gopls.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl", "gowork" },
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            completeUnimported = true,
            usePlaceholders = true,
            staticcheck = true,
        },
    },
})

lspconfig.hls.setup({
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,

    on_init = on_init,
    capabilities = capabilities,
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,

    settings = {
        Lua = {
            diagnostics = {
                enable = false, -- Disable all diagnostics from lua_ls
                -- globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/love2d/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})
