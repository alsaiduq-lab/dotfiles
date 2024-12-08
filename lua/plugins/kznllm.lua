return {
  {
    'chottolabs/kznllm.nvim',
    dependencies = {
      { 'j-hui/fidget.nvim' },
    },
    config = function(self)
      -- Import required modules
      local presets = require('kznllm.presets.basic')
      local utils = require('kznllm.utils')
      local openai = require('kznllm.specs.openai')
      local anthropic = require('kznllm.specs.anthropic')
      local buffer_manager = require('kznllm.buffer').buffer_manager
      local progress = require('fidget.progress')

      -- Define constants
      local TEMPLATE_DIR = utils.TEMPLATE_PATH

      -- Define a function to get template paths
      local function get_template_path(model, filename)
        return utils.join_path({ TEMPLATE_DIR, model, filename })
      end

      -- Define templates for different models
      local templates = {
        openai = {
          system = get_template_path('openai', 'fill_mode_system_prompt.xml.jinja'),
          user = get_template_path('openai', 'fill_mode_user_prompt.xml.jinja'),
        },
        anthropic = {
          debug = get_template_path('anthropic', 'debug.xml.jinja'),
          system = get_template_path('anthropic', 'fill_mode_system_prompt.xml.jinja'),
          user = get_template_path('anthropic', 'fill_mode_user_prompt.xml.jinja'),
        },
        qwen = {
          system = get_template_path('qwen', 'fill_mode_system_prompt.xml.jinja'),
          user = get_template_path('qwen', 'fill_mode_user_prompt.xml.jinja'),
          instruct = get_template_path('qwen', 'fill_mode_instruct_completion_prompt.xml.jinja'),
        },
      }

      -- Define preset builders for each model
      local BasicQwenPreset = openai.OpenAIPresetBuilder
        :new()
        :add_system_prompts({
          { type = 'text', path = templates.qwen.system },
        })
        :add_message_prompts({
          { type = 'text', role = 'user', path = templates.qwen.user },
        })

      local BasicOpenAIPreset = openai.OpenAIPresetBuilder
        :new()
        :add_system_prompts({
          { type = 'text', path = templates.openai.system },
        })
        :add_message_prompts({
          { type = 'text', role = 'user', path = templates.openai.user },
        })

      local BasicAnthropicPreset = anthropic.AnthropicPresetBuilder
        :new()
        :add_system_prompts({
            { type = 'text', path = templates.anthropic.system },
        })
        :add_message_prompts({
            { type = 'text', role = 'user', path = templates.anthropic.user },
        })

      local BasicGrokPreset = openai.OpenAIPresetBuilder
        :new()
        :add_system_prompts({
            { type = 'text', path = get_template_path('grok', 'fill_mode_system_prompt.xml.jinja') },
        })
        :add_message_prompts({
            { type = 'text', role = 'user', path = get_template_path('grok', 'fill_mode_user_prompt.xml.jinja') },
        })

      -- Define a function to create a progress generator
      local function create_progress_generator()
        local thinking_messages = {
          "vibing for %ds...",
          "yapping for %ds...",
          "skidibing for %ds...",
          "whipping up a yappacino for %ds ... ",
          "being a chill guy for %ds...",
          "been rizzing u up for %ds ...",
          "calculating your rizz level for %ds...",
          "generating some swag for %ds...",
          "creating a masterpiece for %ds...",
        }
        local progress_messages = {
          "still vibing...",
          "deadass almost done...",
          "computing...",
          "AI brain working hard ...",
          "flexing my AI muscles...",
          "unleashing the rizz...",
          "wrapping up the yappacino...",
        }
        local state = {
          phase = 1,
          index = 1,
          start_time = os.time(),
          last_message_time = os.time(),
          message_interval = 3,
        }

        return function()
          local now = os.time()
          if now - state.last_message_time < state.message_interval then
            return nil
          end
          state.last_message_time = now

          local time_elapsed = now - state.start_time
          local messages = state.phase == 1 and thinking_messages or progress_messages
          local message = messages[state.index]:format(time_elapsed)

          if state.phase == 1 and time_elapsed >= 18 then
            state.phase = 2
            state.index = 1
          else
            state.index = (state.index % #messages) + 1
          end

          return message
        end
      end 

      -- Define model configurations
      local model_configs = {
        local_models = {
          ["qwen2.5-coder:14b-instruct-q8_0"] = {
            id = "qwen2.5-coder:14b-instruct-q8_0",
            description = "Qwen2.5-coder 14b",
            base_url = "http://localhost:11434",
            max_tokens = 8192,
            preset_builder = BasicQwenPreset,
            api_key_name = "OPENAI_API_KEY",
            params = {
              model = "qwen2.5-coder:14b-instruct-q8_0",
              stream = true,
              temperature = 0.2,
              top_p = 0.95,
              frequency_penalty = 0,
              presence_penalty = 0,
            },
          },
        },
        cloud_models = {
          gpt4 = {
            id = "gpt-4o",
            description = "OpenAI GPT-4o",
            base_url = "https://api.openai.com",
            max_tokens = 12000,
            preset_builder = BasicOpenAIPreset,
            api_key_name = "OPENAI_API_KEY",
            params = {
              model = "gpt-4o",
              stream = true,
              temperature = 0.5,
              top_p = 0.95,
              frequency_penalty = 0,
              presence_penalty = 0,
            },
          },
          grok = {
            id = "grok-beta",
            description = "xAI Grok Beta",
            base_url = "https://api.x.ai",
            api_key_name = "XAI_API_KEY",
            max_tokens = 131072,
            preset_builder = BasicGrokPreset,
            params = {
              model = "grok-beta",
              stream = true,
              temperature = 0.7,
              top_p = 0.95,
              frequency_penalty = 0,
              presence_penalty = 0,
            },
          },
          llama = {
            id = "llama-3.3-70b-versatile",
            description = "Llama 3.3 70B Versatile (Groq)",
            base_url = "https://api.groq.com/openai/",
            api_key_name = "GROQ_API_KEY",
            max_tokens = 8192,
            preset_builder = BasicOpenAIPreset,
            params = {
              model = "llama-3.3-70b-versatile",
              stream = true,
              temperature = 0.7,
              top_p = 0.95,
              frequency_penalty = 0,
              presence_penalty = 0,
            },
          },
        },
      }

      -- Define a function to create an enhanced invoke function for each model
      local function create_enhanced_invoke(config)
        local provider = openai.OpenAIProvider:new({
          base_url = config.base_url,
          api_key_name = config.api_key_name,
        })

        local preset = config.preset_builder:with_opts({
          provider = provider,
          debug_template_path = templates.qwen.instruct,
          params = {
            model = config.id,
            stream = true,
            temperature = 0.7,
            top_p = 0.9,
            max_tokens = config.max_tokens,
          },
        })

        return function(opts)
          local success, user_query = pcall(utils.get_user_input)
          if not success or not user_query then
            vim.notify('Failed to get user input', vim.log.levels.ERROR)
            return
          end

          local selection, replace = utils.get_visual_selection(opts)
          local current_buf_id = vim.api.nvim_get_current_buf()
          local current_buffer_context = buffer_manager:get_buffer_context(current_buf_id)

          -- Create state with start time
          local invoke_state = {
            start_time = os.time()
          }
          local progress_generator = create_progress_generator()

          -- Setup progress reporting
          local p = progress.handle.create({
            title = ('[%s]'):format(replace and 'Replacing' or 'Processing'),
            lsp_client = { name = 'kznllm' },
          })

          -- Prepare prompt arguments
          local prompt_args = {
            user_query = user_query,
            visual_selection = selection,
            current_buffer_context = current_buffer_context,
            replace = replace,
            context_files = utils.get_project_files(),
          }

          -- Build curl options
          local curl_options = preset:build(prompt_args)
          if not curl_options then
            vim.notify('Failed to build prompt arguments', vim.log.levels.ERROR)
            return
          end

          -- Debug mode handling
          if opts.debug then
            local scratch_buf_id = buffer_manager:create_scratch_buffer()
            local success, debug_data = pcall(utils.make_prompt_from_template, {
              template_path = preset.debug_template_path,
              prompt_args = curl_options,
            })
            if success and debug_data then
              buffer_manager:write_content(debug_data, scratch_buf_id)
              vim.cmd('normal! Gzz')
            else
              vim.notify('Failed to create debug data', vim.log.levels.ERROR)
            end
          end

          -- Create and start streaming job
          local args = provider:make_curl_args(curl_options)
          p:report({ message = config.description })

          buffer_manager:create_streaming_job(args, provider.handle_sse_stream, function()
            local progress_message = progress_generator()
            if progress_message then
              p:report({ message = progress_message })
            end
          end, function()
            local completion_message = string.format("Completed in %ds", os.time() - invoke_state.start_time)
            p:report({ message = completion_message })
            p:finish()
          end)
        end
      end

      -- Initialize model configurations
      for _, model_group in pairs(model_configs) do
        for model_key, model_info in pairs(model_group) do
          table.insert(presets.options, {
            id = model_info.id,
            description = model_info.description,
            invoke = create_enhanced_invoke(model_info),
          })
        end
      end

      -- Set up keybindings for model switching and invocation
      vim.keymap.set({ 'n', 'v' }, '<leader>m', function()
        presets.switch_presets(presets.options)
      end, { desc = 'Switch between model presets' })

      local function invoke_with_opts(opts)
        return function()
          local preset = presets.load_selected_preset(presets.options)
          if preset then
            preset.invoke(opts)
          else
            vim.notify('No preset selected', vim.log.levels.WARN)
          end
        end
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>K', invoke_with_opts { debug = true },
        { desc = 'Invoke LLM with debug mode' })
      vim.keymap.set({ 'n', 'v' }, '<leader>k', invoke_with_opts { debug = false },
        { desc = 'Invoke LLM for completion' })

      -- Set up escape handler for LLM operations
      vim.api.nvim_set_keymap('n', '<Esc>', '', {
        noremap = true,
        silent = true,
        callback = function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'LLM_Escape' })
        end,
      })

      -- Setup cleanup autocmds for temporary buffers
      local function setup_cleanup_autocmds()
        vim.api.nvim_create_augroup('LLMCleanup', { clear = true })
        vim.api.nvim_create_autocmd('VimLeavePre', {
          group = 'LLMCleanup',
          callback = function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_get_option(buf, 'buftype') == 'nofile' then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end,
        })
      end

      setup_cleanup_autocmds()
    end,
  }
}
