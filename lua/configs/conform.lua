local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        c_cpp = { "clang-format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        -- go = { "gofumpt", "goimports-reviser", "golines" },
        -- haskell = { "fourmolu", "stylish-haskell" },
        python = { "isort", "black" },
    },

    formatters = {
        -- C & C++
        ["clang-format"] = {
            -- prepend_args = {
            --     "-style={ \
            --             IndentWidth: 4, \
            --             TabWidth: 4, \
            --             UseTab: Never, \
            --             SpacesBeforeTrailingComments: 2, \
            --             AlignTrailingComments: true, \
            --             AccessModifierOffset: 0, \
            --             IndentAccessModifiers: true, \
            --             PackConstructorInitializers: Never}",
            -- },
            prepend_args = {
                "-style=file", -- 1. 先尝试项目目录的 .clang-format
                -- -style=file:~/.config/clang-format/global_format
                "-fallback-style=google", -- 2. 失败时回退 Google 风格
                "--assume-filename=$FILENAME", -- 确保文件类型识别
            },
            stdin = true, -- 通过 stdin 传递代码
        },
        -- Golang
        ["goimports-reviser"] = {
            prepend_args = { "-rm-unused" },
        },
        golines = {
            prepend_args = { "--max-len=80" },
        },
        -- Lua
        stylua = {
            prepend_args = {
                "--column-width",
                "80",
                "--line-endings",
                "Unix",
                "--indent-type",
                "Spaces",
                "--indent-width",
                "4",
                "--quote-style",
                "AutoPreferDouble",
            },
        },
        -- Python
        black = {
            prepend_args = {
                "--fast",
                "--line-length",
                "80",
            },
        },
        isort = {
            prepend_args = {
                "--profile",
                "black",
            },
        },
    },

    -- format_on_save = {
    --     -- These options will be passed to conform.format()
    --     timeout_ms = 500,
    --     lsp_fallback = true,
    -- },
}

require("conform").setup(options)
