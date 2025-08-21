# Zettelkasten Guide for Neovim

## 🧠 What is a Zettelkasten?

A zettelkasten (German for "slip box") is a method of note-taking and knowledge management that focuses on:

- **Atomic notes**: One idea per note
- **Linked thinking**: Connect related ideas with links
- **Emergent organization**: Structure emerges from connections, not hierarchies
- **Long-term knowledge building**: Create a "second brain" that grows over time

## 🚀 Quick Start

### Step 1: Restart Neovim
The plugin will install automatically and create your zettelkasten directory structure.

### Step 2: Your First Zettel
1. **Open the panel**: `<leader>zz`
2. **Create your first note**: `<leader>zn`
3. **Give it a title**: Something like "Zettelkasten Getting Started"
4. **Write atomic content**: One clear idea per note

### Step 3: Directory Structure Created
```
~/zettelkasten/
├── daily/           # Daily notes
├── weekly/          # Weekly notes  
├── templates/       # Note templates
└── [your notes]     # Individual zettel notes
```

## ⌨️ Key Commands

### Note Management
| Command | Action | Description |
|---------|--------|-------------|
| `<leader>zz` | Open panel | Start here! Main zettelkasten interface |
| `<leader>zn` | New note | Create a new atomic note |
| `<leader>zf` | Find notes | Search through all your notes |
| `<leader>zg` | Grep notes | Search text within notes |
| `<leader>zt` | Toggle todo | Mark items as done/undone |

### Daily & Weekly Notes
| Command | Action | Description |
|---------|--------|-------------|
| `<leader>zd` | Daily note | Open today's daily note |
| `<leader>zw` | Weekly note | Open this week's weekly note |

### Linking & Navigation
| Command | Action | Description |
|---------|--------|-------------|
| `<leader>zl` | Insert link | Create link to another note |
| `<leader>zb` | Show backlinks | See what links TO current note |
| `<Enter>` | Follow link | Follow link under cursor |

### Organization
| Command | Action | Description |
|---------|--------|-------------|
| `<leader>z#` | Show tags | Browse all tags |
| `<leader>zc` | Calendar | Visual date navigation |
| `<leader>zi` | Insert image | Add and link images |

## 📝 Best Practices

### 1. The Atomic Principle

**Good: One Clear Idea**
```markdown
# Vim's Modal Editing Benefits
Modal editing reduces hand movement because you don't need to reach for modifier keys constantly. Instead of Ctrl+C for copy, you simply press 'y' in normal mode.
```

**Bad: Multiple Ideas**
```markdown
# Vim Tips and Tricks
Modal editing is great because...
Also, here's how to configure plugins...
And speaking of productivity...
```

### 2. Link Everything
- Use `[[Note Title]]` to link to other notes
- `<leader>zl` helps you insert links quickly
- Follow links with `<Enter>`

### 3. Use Tags Strategically
```markdown
Tags: #productivity #vim #learning #programming
```

### 4. Build Gradually
- Start with daily notes (`<leader>zd`)
- Capture interesting ideas as separate notes
- Link related concepts over time

## 🎯 Workflow Examples

### Daily Workflow
1. **Morning**: `<leader>zd` - Open today's daily note
2. **During the day**: Capture ideas in daily note
3. **Evening**: Extract important ideas into separate atomic notes
4. **Link**: Connect new notes to existing ones

### Research Workflow
1. **Create topic note**: `<leader>zn` "Machine Learning Fundamentals" 
2. **Create specific notes**: Individual concepts like "Gradient Descent", "Overfitting"
3. **Link them**: Connect related concepts
4. **Tag appropriately**: `#ml #algorithms #statistics`

## 🔗 Linking Example

```markdown
# Machine Learning Fundamentals

The core of ML is pattern recognition in data. 

Key concepts:
- [[Supervised Learning]] - Learning with labeled examples
- [[Unsupervised Learning]] - Finding patterns without labels
- [[Gradient Descent]] - Optimization algorithm
- [[Overfitting]] - When models memorize instead of generalize

See also: [[Statistics Fundamentals]], [[Linear Algebra Basics]]

Tags: #ml #fundamentals #overview
```

## 📋 Note Templates

### Default Note Template
```markdown
# {{ title }}

Date: {{ date }}
Tags: #

## Content

{{ cursor }}

## Links
- 

## References
- 
```

### Daily Note Template
```markdown
# Daily Note - {{ date }}

## Today's Focus
- 

## Tasks
- [ ] 

## Notes
{{ cursor }}

## Reflections
- 

## Tomorrow
- 
```

## 🎨 Advanced Features

- **Backlinks**: `<leader>zb` shows what links TO current note
- **Calendar**: `<leader>zc` for visual date navigation  
- **Images**: `<leader>zi` to insert and link images
- **Templates**: Automatically applied when creating notes
- **Search**: Powerful telescope integration for finding content

## 💡 Pro Tips

1. **Start small**: Don't worry about perfect organization initially
2. **Daily notes are gold**: Capture everything there first
3. **Review and refactor**: Regularly review notes and improve connections
4. **Embrace messiness**: Let structure emerge naturally
5. **Use telescope**: `<leader>zf` and `<leader>zg` are your best friends
6. **Link liberally**: Create connections even if they seem weak initially
7. **One idea per note**: Keep notes atomic and focused
8. **Use consistent naming**: Develop your own conventions for titles
9. **Regular maintenance**: Spend time weekly reviewing and connecting notes
10. **Don't overthink**: The system works best when you use it regularly

## 🚦 Getting Started Checklist

- [ ] Restart Neovim to install telekasten
- [ ] Press `<leader>zz` to open the zettelkasten panel
- [ ] Create your first note with `<leader>zn`
- [ ] Try the daily note feature with `<leader>zd`
- [ ] Practice linking with `<leader>zl`
- [ ] Search your notes with `<leader>zf`
- [ ] Set up a regular review habit

## 📚 Further Reading

- [How to Take Smart Notes](https://www.soenkeahrens.de/en/takesmartnotes) by Sönke Ahrens
- [Zettelkasten Method](https://zettelkasten.de/) - Community and resources
- [Building a Second Brain](https://www.buildingasecondbrain.com/) by Tiago Forte

---

**Remember**: The zettelkasten method becomes powerful over time as your network of ideas grows. Start simple, be consistent, and let the connections emerge naturally! 🚀
