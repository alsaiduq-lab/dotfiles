_G.vim = vim
return {
  {
    'chottolabs/kznllm.nvim',
    dependencies = {
      { 'j-hui/fidget.nvim' },
    },
    config = function(self)
      -- Import necessary modules
      local presets = require('kznllm.presets.basic')
      local utils = require('kznllm.utils')
      local openai = require('kznllm.specs.openai')
      local anthropic = require('kznllm.specs.anthropic')
      local buffer_manager = require('kznllm.buffer').buffer_manager
      local api = vim.api
      local progress = require('fidget.progress')

      -- Define paths for templates
      local openai_template_path = utils.join_path({ utils.TEMPLATE_PATH, 'openai' })
      local openai_system_template = utils.join_path({ openai_template_path, 'fill_mode_system_prompt.xml.jinja' })
      local openai_user_template = utils.join_path({ openai_template_path, 'fill_mode_user_prompt.xml.jinja' })
      local anthropic_template_path = utils.join_path({ utils.TEMPLATE_PATH, 'anthropic' })
      local anthropic_debug_template = utils.join_path({ anthropic_template_path, 'debug.xml.jinja' })
      local anthropic_system_template = utils.join_path({ anthropic_template_path, 'fill_mode_system_prompt.xml.jinja' })
      local anthropic_user_template = utils.join_path({ anthropic_template_path, 'fill_mode_user_prompt.xml.jinja' })
      
      -- Add local model support through OpenAI compatibility layer
      local local_models = {
        ["mixtral-8x7b-instruct"] = {
          id = "mixtral-8x7b-instruct",
          description = "Mixtral 8x7B Instruct",
          base_url = "http://localhost:8000",
          max_tokens = 4096
        },
        ["mistral-7b-instruct"] = {
          id = "mistral-7b-instruct",
          description = "Mistral 7B Instruct",
          base_url = "http://localhost:8000",
          max_tokens = 4096
        }
      }

      -- Function to create the invoke for preset configurations
      local function create_invoke(config)
        return function(opts)
          local user_query = utils.get_user_input()
          if not user_query then return end

          local selection, replace = utils.get_visual_selection(opts)
          local current_buf_id = api.nvim_get_current_buf()
          local current_buffer_context = buffer_manager:get_buffer_context(current_buf_id)

          local p = progress.handle.create({
            title = ('[%s]'):format(replace and 'replacing' or 'yapping'),
            lsp_client = { name = 'kznllm' },
          })

          local prompt_args = {
            user_query = user_query,
            visual_selection = selection,
            current_buffer_context = current_buffer_context,
            replace = replace,
            context_files = utils.get_project_files(),
          }

          local curl_options = config.preset_builder:build(prompt_args)

          if opts.debug then
            local scratch_buf_id = buffer_manager:create_scratch_buffer()
            local debug_data = utils.make_prompt_from_template({
              template_path = config.preset_builder.debug_template_path,
              prompt_args = curl_options,
            })
            buffer_manager:write_content(debug_data, scratch_buf_id)
            vim.cmd('normal! Gzz')
          end

          local provider = config.preset_builder.provider
          local args = provider:make_curl_args(curl_options)

          local state = { start = os.time(), last_updated = nil }
          p:report({ message = ('%s'):format(config.description) })
          local message = 'yapped'

          buffer_manager:create_streaming_job(args, provider.handle_sse_stream, function()
            local elapsed = os.time() - state.start
            if message:format(elapsed) ~= message then
              p:report({ message = message:format(os.time() - state.start) })
            end
          end, function()
            p:finish()
          end)
        end
      end

      local BasicOpenAIPreset = openai.OpenAIPresetBuilder
        :new()
        :add_system_prompts({
          { type = 'text', path = openai_system_template },
        })
        :add_message_prompts({
          { type = 'text', role = 'user', path = openai_user_template },
        })

      -- Your existing configurations
      local qwen_config = {
        id = "qwen2.5-coder:14b-instruct-q8_0",
        description = "Qwen 2.5 Coder 14B",
        preset_builder = BasicOpenAIPreset:with_opts({
          provider = openai.OpenAIProvider:new({
            base_url = "http://localhost:11434"
          }),
          params = {
            model = "qwen2.5-coder:14b-instruct-q8_0",
            stream = true,
            temperature = 0.7,
            top_p = 0.9,
            max_tokens = 8192,
          }
        })
      }

      local grok_config = {
        id = "grok-beta",
        description = "xAI Grok Beta",
        preset_builder = BasicOpenAIPreset:with_opts({
          provider = openai.OpenAIProvider:new({
            api_key_name = "XAI_API_KEY",
            base_url = "https://api.x.ai"
          }),
          headers = {
            endpoint = "/v1/chat/completions",
            extra_headers = {}
          },
          params = {
            model = "grok-beta",
            stream = true,
            temperature = 0.7,
            top_p = 0.9,
            max_tokens = 131072
          }
        })
      }

      local gpt4o_config = {
        id = "gpt-4o",
        description = "OpenAI gpt-4o",
        preset_builder = BasicOpenAIPreset:with_opts({
          provider = openai.OpenAIProvider:new({
            api_key_name = "OPENAI_API_KEY",
            base_url = "https://api.openai.com"
          }),
          headers = {
            endpoint = "/v1/chat/completions",
            extra_headers = {}
          },
          params = {
            model = "gpt-4o",
            stream = true,
            temperature = 0.7,
            top_p = 0.9,
            max_tokens = 8192
          }
        })
      }

      local claude_sonnet_config = {
        id = "claude-3-5-sonnet",
        description = "Anthropic Claude 3.5 Sonnet",
        preset_builder = anthropic.AnthropicPresetBuilder
          :new()
          :add_system_prompts({
            {
              type = 'text',
              path = anthropic_system_template,
              cache_control = { type = 'ephemeral' },
            },
          })
          :add_message_prompts({
            { type = 'text', role = 'user', path = anthropic_user_template },
          })
          :with_opts({
            debug_template_path = anthropic_debug_template,
            params = {
              model = "claude-3-5-sonnet-20241022",
              stream = true,
              max_tokens = 8192,
              temperature = 0.7,
            },
          })
      }

      local claude_haiku_config = {
        id = "claude-3-5-haiku",
        description = "Anthropic Claude 3.5 Haiku",
        preset_builder = anthropic.AnthropicPresetBuilder
          :new()
          :add_system_prompts({
            {
              type = 'text',
              path = anthropic_system_template,
              cache_control = { type = 'ephemeral' },
            },
          })
          :add_message_prompts({
            { type = 'text', role = 'user', path = anthropic_user_template },
          })
          :with_opts({
            debug_template_path = anthropic_debug_template,
            params = {
              model = "claude-3-5-haiku-20241022",
              stream = true,
              max_tokens = 8192,
              temperature = 0.7,
            },
          })
      }

      -- Create configurations for local models
      local configs = {}
      for model_id, model_info in pairs(local_models) do
        configs[model_id] = {
          id = model_info.id,
          description = model_info.description,
          preset_builder = BasicOpenAIPreset:with_opts({
            provider = openai.OpenAIProvider:new({
              base_url = model_info.base_url
            }),
            params = {
              model = model_info.id,
              stream = true,
              temperature = 0.7,
              top_p = 0.9,
              max_tokens = model_info.max_tokens,
            }
          })
        }
      end

      -- Combine all configurations
      presets.options = {
        {
          id = qwen_config.id,
          description = qwen_config.description,
          preset_builder = qwen_config.preset_builder,
          invoke = create_invoke(qwen_config)
        },
        {
          id = grok_config.id,
          description = grok_config.description,
          preset_builder = grok_config.preset_builder,
          invoke = create_invoke(grok_config)
        },
        {
          id = gpt4o_config.id,
          description = gpt4o_config.description,
          preset_builder = gpt4o_config.preset_builder,
          invoke = create_invoke(gpt4o_config)
        },
        {
          id = claude_sonnet_config.id,
          description = claude_sonnet_config.description,
          preset_builder = claude_sonnet_config.preset_builder,
          invoke = create_invoke(claude_sonnet_config)
        },
        {
          id = claude_haiku_config.id,
          description = claude_haiku_config.description,
          preset_builder = claude_haiku_config.preset_builder,
          invoke = create_invoke(claude_haiku_config)
        }
      }

      -- Add local model configurations
      for _, config in pairs(configs) do
        table.insert(presets.options, {
          id = config.id,
          description = config.description,
          preset_builder = config.preset_builder,
          invoke = create_invoke(config)
        })
      end

      -- Your existing keybindings
      vim.keymap.set({ 'n', 'v' }, '<leader>m', function()
        presets.switch_presets(presets.options)
      end, { desc = 'Switch between LLM presets' })

      local function invoke_with_opts(opts)
        return function()
          local preset = presets.load_selected_preset(presets.options)
          if preset and preset.invoke then
            preset.invoke(opts)
          else
            vim.notify('No valid preset selected', vim.log.levels.WARN)
          end
        end
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>K', invoke_with_opts { debug = true },
        { desc = 'Send current selection to LLM (Debug Mode)' })
      vim.keymap.set({ 'n', 'v' }, '<leader>k', invoke_with_opts { debug = false },
        { desc = 'Send current selection to LLM' })

      vim.api.nvim_set_keymap('n', '<Esc>', '', {
        noremap = true,
        silent = true,
        callback = function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'LLM_Escape' })
        end,
      })
    end,
  }
}
