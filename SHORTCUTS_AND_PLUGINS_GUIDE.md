# Neovim Configuration Guide

## Quick Reference: Keyboard Shortcuts

### Leader Key
- **Leader Key**: `<Space>` (space bar)

### Basic Navigation & Window Management
| Shortcut | Description |
|----------|-------------|
| `<C-h>` | Move focus to left window |
| `<C-j>` | Move focus to lower window |
| `<C-k>` | Move focus to upper window |
| `<C-l>` | Move focus to right window |
| `<leader>pv` | Open project view (file explorer) |

### Search & File Operations (Telescope)
| Shortcut | Description |
|----------|-------------|
| `<leader>sf` | **[S]earch [F]iles** - Find files in project |
| `<leader>sg` | **[S]earch by [G]rep** - Search text in files |
| `<leader>sw` | **[S]earch current [W]ord** - Search word under cursor |
| `<leader>sh` | **[S]earch [H]elp** - Search help documentation |
| `<leader>sk` | **[S]earch [K]eymaps** - Search available keymaps |
| `<leader>ss` | **[S]earch [S]elect** - Telescope builtin pickers |
| `<leader>sd` | **[S]earch [D]iagnostics** - Search LSP diagnostics |
| `<leader>sr` | **[S]earch [R]esume** - Resume last search |
| `<leader>s.` | **[S]earch Recent Files** - Recently opened files |
| `<leader>sn` | **[S]earch [N]eovim files** - Search config files |
| `<leader><leader>` | **Find existing buffers** - Switch between open buffers |
| `<leader>/` | **Fuzzy search in current buffer** |
| `<leader>s/` | **Live grep in open files** |

### LSP (Language Server) Features
| Shortcut | Description |
|----------|-------------|
| `grd` | **[G]oto [D]efinition** - Jump to definition |
| `grr` | **[G]oto [R]eferences** - Find all references |
| `gri` | **[G]oto [I]mplementation** - Jump to implementation |
| `grt` | **[G]oto [T]ype Definition** - Jump to type definition |
| `grD` | **[G]oto [D]eclaration** - Jump to declaration |
| `grn` | **[R]e[n]ame** - Rename symbol |
| `gra` | **Code [A]ction** - Show available code actions |
| `gO` | **Open Document Symbols** - Navigate symbols in file |
| `gW` | **Open Workspace Symbols** - Navigate symbols in project |

### Formatting & Editing
| Shortcut | Description |
|----------|-------------|
| `<leader>f` | **[F]ormat buffer** - Format current file |
| `<leader>th` | **[T]oggle inlay [H]ints** - Toggle LSP inlay hints |

### Diagnostics & Debugging
| Shortcut | Description |
|----------|-------------|
| `<leader>q` | **Open diagnostic [Q]uickfix list** |

### Terminal & General
| Shortcut | Description |
|----------|-------------|
| `<Esc>` | Clear search highlights (normal mode) |
| `<Esc><Esc>` | Exit terminal mode |

### Completion (Blink.cmp)
| Shortcut | Description |
|----------|-------------|
| `<C-y>` | Accept completion |
| `<Tab>/<S-Tab>` | Navigate snippet placeholders |
| `<C-Space>` | Open menu or docs |
| `<C-n>/<C-p>` | Select next/previous item |
| `<C-e>` | Hide menu |
| `<C-k>` | Toggle signature help |

---

## Plugin Guide

### Core Functionality

#### **Telescope** - Fuzzy Finder
- **Purpose**: Powerful fuzzy finding for files, text, and more
- **Key Features**: File search, live grep, help search, buffer switching
- **Extensions**: FZF native (faster searching), UI select integration

#### **LSP Configuration** - Language Support
- **Purpose**: Provides intelligent code features
- **Features**: Auto-completion, go-to-definition, error checking, refactoring
- **Supported Languages**: TypeScript/JavaScript, Zig, JSON, Lua, and more
- **Tools**: Mason (package manager), Mason-LSP-Config, Mason-Tool-Installer

#### **Blink.cmp** - Auto-completion Engine
- **Purpose**: Intelligent code completion
- **Features**: LSP-based completion, snippet support, fuzzy matching
- **Integrations**: Works with LSP servers and LuaSnip

#### **LuaSnip** - Snippet Engine
- **Purpose**: Code snippet expansion and management
- **Features**: Supports LSP snippets, custom snippets

### Development Tools

#### **Conform.nvim** - Code Formatting
- **Purpose**: Automatic code formatting
- **Supported Formatters**: Stylua (Lua), Prettier (JavaScript), and more
- **Features**: Format on save, multiple formatter support

#### **Treesitter** - Syntax Highlighting
- **Purpose**: Advanced syntax highlighting and code understanding
- **Features**: Better highlighting, code folding, text objects
- **Languages**: Bash, C, HTML, Lua, Markdown, Vim, and more

#### **Gitsigns** - Git Integration
- **Purpose**: Git integration in the editor
- **Features**: Git blame, hunk navigation, staging, diff viewing
- **Visual Indicators**: Shows added/changed/deleted lines in gutter

### AI & Assistance

#### **GitHub Copilot** - AI Code Assistant
- **Purpose**: AI-powered code suggestions
- **Features**: Real-time code completion, code generation

#### **CopilotChat** - AI Chat Interface
- **Purpose**: Interactive AI assistance
- **Features**: Code explanations, debugging help, refactoring suggestions

### Editor Enhancements

#### **Which-key** - Keymap Helper
- **Purpose**: Shows available keybindings as you type
- **Features**: Popup menu with available commands, helps learn shortcuts

#### **Mini.nvim** - Swiss Army Knife
- **Components Used**:
  - **Mini.ai**: Better text objects (around/inside)
  - **Mini.surround**: Add/change/delete surroundings (quotes, brackets)
  - **Mini.statusline**: Clean status line

#### **Smear Cursor** - Visual Enhancement
- **Purpose**: Smooth cursor animations
- **Features**: Makes cursor movement more visually appealing

#### **Todo Comments** - Comment Highlighting
- **Purpose**: Highlights TODO, FIXME, NOTE comments
- **Features**: Makes important comments stand out

### Specialized Tools

#### **Neo-tree** - File Explorer
- **Purpose**: Modern file tree explorer
- **Features**: File/folder management, Git status, buffer view

#### **Leetcode.nvim** - Coding Practice
- **Purpose**: Solve LeetCode problems directly in Neovim
- **Features**: Problem fetching, testing, submission

#### **Firenvim** - Browser Integration
- **Purpose**: Use Neovim in web browsers
- **Features**: Edit text areas with full Neovim functionality

#### **Hardtime** - Vim Training
- **Purpose**: Helps break bad Vim habits
- **Features**: Prevents repetitive key usage, encourages efficient editing

#### **Guess Indent** - Auto Indentation
- **Purpose**: Automatically detects and sets indentation
- **Features**: Detects tabs vs spaces, indentation width

### Linting & Code Quality

#### **Nvim-lint** (via kickstart)
- **Purpose**: Code linting and error detection
- **Features**: Real-time error checking, multiple linter support

#### **Autopairs** (via kickstart)
- **Purpose**: Automatic bracket/quote pairing
- **Features**: Auto-closes brackets, quotes, and other pairs

### Themes & Appearance

#### **Tokyo Night** - Color Scheme
- **Purpose**: Modern, eye-friendly color scheme
- **Variants**: Night, Storm, Moon, Day themes
- **Features**: Consistent colors across all UI elements

---

## Tips for Getting Started

1. **Start with basic navigation**: Master `<C-h/j/k/l>` for window switching
2. **Learn Telescope shortcuts**: `<leader>sf` and `<leader>sg` are most commonly used
3. **Use LSP features**: `grd` (go to definition) and `grr` (find references) are essential
4. **Format regularly**: `<leader>f` to keep code clean
5. **Explore with Which-key**: Press `<leader>` and wait to see available options
6. **Use `:checkhealth` to verify everything is working correctly**

## Useful Commands

- `:Lazy` - Manage plugins
- `:Mason` - Manage LSP servers and tools
- `:Telescope` - Open Telescope
- `:ConformInfo` - Check formatting configuration
- `:checkhealth` - Verify Neovim health
- `:help <topic>` - Get help on any topic
