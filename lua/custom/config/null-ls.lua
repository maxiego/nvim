local null_ls = require 'null-ls'

local group = vim.api.nvim_create_augroup('lsp_format_on_save', { clear = false })
local event = 'BufWritePre' -- or "BufWritePost"
local async = event == 'BufWritePost'

local formatting = null_ls.builtins.formatting

null_ls.setup {
  debug = true,
  sources = {
    formatting.prettier.with {
      extra_args = {
        '--bracket-spacing',
        '--print-width=80',
        '--semi',
        '--single-quote',
        '--tab-width=2',
        '--trailing-comma=es5',
        '--config-precedence=cli-override',
      },
    },
    formatting.black.with {
      extra_args = { '--fast' },
    },
    formatting.stylua,
    formatting.eslint_d,
  },
  on_attach = function(client, bufnr)
    if client.supports_method 'textDocument/formatting' then
      vim.keymap.set('n', '<Leader>f', function()
        vim.lsp.buf.format { bufnr = vim.api.nvim_get_current_buf() }
      end, { buffer = bufnr, desc = '[lsp] format' })

      -- format on save
      vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr, async = async, formatting = { eslint_d = true } }
        end,
        desc = '[lsp] format on save',
      })
    end

    if client.supports_method 'textDocument/rangeFormatting' then
      vim.keymap.set('x', '<Leader>f', function()
        vim.lsp.buf.format { bufnr = vim.api.nvim_get_current_buf() }
      end, { buffer = bufnr, desc = '[lsp] format' })
    end
  end,
}