# 🧠 Zettelkasten Master Cheat Sheet

## 🚀 **Quick Start**
1. **Open panel**: `<leader>zz` - Your main command center
2. **Create daily note**: `<leader>zd` - Start here every day (with automatic task rollover!)
3. **Search notes**: `<leader>zg` - Find anything instantly
4. **Create new note**: `<leader>zn` - Capture atomic ideas

---

## ⌨️ **Complete Keybind Reference**

### 📝 **Note Management**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>zz` | **Panel** | Main zettelkasten interface - start here! |
| `<leader>zn` | **New note** | Create atomic note with template |
| `<leader>zf` | **Find notes** | Telescope search by filename |
| `<leader>zg` | **Grep notes** | Search text within all notes (powered by ripgrep) |
| `<leader>zp` | **Person note** | Create coworker/contact note with template |

### 📅 **Daily & Weekly Notes**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>zd` | **Daily note** | Open today's note with **automatic task rollover** |
| `<leader>zdc` | **Clean daily** | Create daily note without rollover |
| `<leader>zdr` | **Manual rollover** | Rollover tasks from specific date |
| `<leader>zw` | **Weekly note** | Open this week's weekly review |

### 🔗 **Link Creation (NEW!)**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>z2` | **2-word link** | Wrap "Pharma Eng" → `[[Pharma Eng]]` ⭐ |
| `<leader>zw1` | **1-word link** | Wrap current word → `[[word]]` |
| `<leader>z[` | **Visual link** | Wrap selection → `[[selection]]` |
| `<leader>zl` | **Insert link** | Create link to existing note |
| `sa2iwz` | **Surround link** | Mini.surround: 2 inner words → `[[words]]` |

### 🧭 **Navigation & Discovery**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>zb` | **Backlinks** | Enhanced view of what links TO current note |
| `<leader>zB` | **Browse backlinks** | Interactive backlinks explorer |
| `<leader>z#` | **Show tags** | Enhanced tag browser with counts |
| `<leader>zT` | **Search by tag** | Find notes with specific tag |
| `<Enter>` | **Follow link** | Jump to link under cursor |
| `<leader>zj` | **Jump to link** | Alternative link following |

### 🔧 **Utilities**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>zt` | **Toggle todo** | Mark task as done/undone |
| `<leader>zi` | **Insert image** | Add and link images |
| `<leader>zc` | **Calendar** | Visual date navigation |

### 🚀 **Buffer Navigation**
| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>[` | **Previous buffer** | Go back one buffer |
| `<leader>]` | **Next buffer** | Go forward one buffer |
| `<leader><leader>` | **Buffer picker** | Telescope buffer switcher |

---

## 🎯 **Recommended Daily Workflow**

### 🌅 **Morning Routine (2 minutes)**
```
1. <leader>zd      → Open today's note (tasks auto-rollover!)
2. Type focus      → Set "Today's Focus" 
3. Add new tasks   → Plan your day
```

### 🎯 **During the Day**
```
1. <leader>zg      → Search for related notes
2. <leader>z2      → Quick-link "Important Concepts"
3. <leader>zn      → Capture new atomic ideas
4. <leader>zb      → Check what connects to current note
```

### 🌙 **Evening Review (5 minutes)**
```
1. <leader>zd      → Return to today's note
2. Fill reflections → What did you learn?
3. Set tomorrow     → Plan next day
4. <leader>z#      → Browse tags, make connections
```

### 📅 **Weekly Review**
```
1. <leader>zw      → Open weekly note
2. Review accomplishments and lessons
3. <leader>z#      → Tag cleanup and organization
4. <leader>zB      → Explore note connections
```

---

## ⚡ **Power User Tips**

### 🎨 **Link Creation Mastery**
- **`<leader>z2`** - Best for phrases like "Machine Learning", "Product Strategy"
- **Visual + `<leader>z[`** - Perfect for exact selections
- **`sa2iwz`** - Mini.surround for advanced users
- **`<leader>zl`** - When you know the target note exists

### 🔍 **Search Like a Pro**
- **`<leader>zg`** → Search content across ALL notes
- **`<leader>zf`** → Find notes by filename
- **`<leader>z#`** → Browse by topic/tag
- **`<leader>zT`** → Search specific tag

### 🧠 **Memory Palace**
- **`<leader>zb`** → "What points here?" (reverse discovery)
- **`<leader>zB`** → Interactive exploration
- **`Enter`** → Follow the curiosity trail
- **`<leader>[` / `<leader>]`** → Navigate your thought journey

---

## 📋 **Note Templates**

### 🗒️ **Atomic Note Structure**
```markdown
# Clear Concept Title

Date: 2024-01-15
Tags: #topic #context

## Core Idea
One clear, focused concept explained simply.

## Connections
- [[Related Concept 1]]
- [[Related Concept 2]]

## References
- Source or inspiration
```

### 📅 **Daily Note Structure** (Auto-generated)
```markdown
# Daily Note - 2024-01-15

## Today's Focus
- Main priority or theme

## Tasks
- [ ] New task
- [ ] Rolled over task ← Automatic!

## Notes
Content and ideas from the day

## Reflections
- Key insights or learnings

## Tomorrow
- Items for next day ← Auto-rolls to tomorrow!

#daily
```

### 👥 **Person Note Structure** (`<leader>zp`)
```markdown
# Person Name

## Background
- Location: 
- Personal: 
- Previous experience: 

## Professional
- Role: 
- Team: 
- Expertise: 
- Years at company: 

## Personal Details
- Family: 
- Interests: 
- Fun facts: 

## Interactions
### 2024-01-15 - First meeting
- 

#people #team
```

---

## 🏗️ **Advanced Workflows**

### 📚 **Research Project**
```
1. <leader>zn "Project Overview"     → Main hub note
2. <leader>z2 on key concepts        → Quick link creation  
3. <leader>zg search related topics  → Find existing knowledge
4. <leader>z# organize with tags     → Structure emerges
5. <leader>zb check connections      → Discover relationships
```

### 💡 **Idea Development**
```
1. <leader>zd capture in daily       → Initial spark
2. <leader>zn create atomic note     → Extract and expand
3. <leader>z2 link to related ideas  → Build connections
4. <leader>zb see what connects      → Discover context
5. Refine and iterate                → Let it grow
```

### 🔄 **Knowledge Maintenance**
```
Weekly:
1. <leader>z# review tag landscape   → See the big picture
2. <leader>zB explore connections    → Follow unexpected paths
3. Merge or split notes as needed    → Keep it atomic
4. Update and strengthen links       → Improve navigation
```

---

## 🎨 **Zettelkasten Philosophy**

### ✨ **Core Principles**
- **Atomic**: One idea per note
- **Connected**: Link everything related
- **Emerging**: Let structure grow naturally
- **Personal**: Use your own language and examples

### 🌱 **Growth Mindset**
- Start messy, refine later
- Capture more than you organize
- Follow your curiosity
- Trust the process

### 🔗 **Connection Strategies**
- Link liberally - connections reveal themselves over time
- Use consistent naming conventions
- Create hub notes for major topics
- Regular review creates unexpected insights

---

## 🚨 **Troubleshooting**

### Common Issues
- **`<leader>zg` not working?** → Install ripgrep: `brew install ripgrep`
- **Links not following?** → Use `<leader>zj` as alternative
- **Tasks not rolling over?** → Use `<leader>zdc` for clean daily note
- **Keybind conflicts?** → Check `:map <leader>z` to see all mappings

### Performance Tips
- Keep notes atomic (< 500 words ideal)
- Use tags consistently but sparingly
- Regular maintenance prevents chaos
- Trust telescope search over manual browsing

---

## 🎯 **Success Metrics**

After 30 days, you should have:
- ✅ Daily note habit established
- ✅ 50+ atomic notes created
- ✅ Natural linking patterns emerged
- ✅ Surprising connections discovered
- ✅ Faster recall of information
- ✅ Ideas building on each other

---

## 🎉 **Quick Reference Card**

**Most Used Commands:**
```
<leader>zd  - Start your day
<leader>zg  - Find anything
<leader>z2  - Link two words
<leader>zn  - Capture idea
<leader>zb  - Explore connections
<leader>z#  - Browse topics
```

**Remember**: Your zettelkasten becomes powerful through **consistent use**, not perfect organization. Start simple, capture everything, and let the magic emerge! 🚀

---

*This system grows with you. The more you use it, the more valuable it becomes. Happy note-taking!* ✨
