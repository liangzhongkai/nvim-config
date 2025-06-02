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
        vim.notify("clangd loaded. arguments: " .. vim.inspect(client.config.settings.clangd.fallbackFlags))
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    -- on_init = function(client)
    --     client.config.flags = client.config.flags or {}
    --     client.config.flags.allow_stderr_messages = false
    -- end,
    capabilities = capabilities,
    init_options = {
        clangdFileStatus = true
    },
    cmd = {
        "clangd",
        "--background-index",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--query-driver=/usr/bin/clang++",
        "--compile-commands-dir=.",
        "--clang-tidy",
    },
    settings = {
        clangd = {
            fallbackFlags = {  -- ✅ 正确传递编译器标志
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
