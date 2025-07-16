# Daily Note

You are given the following context: $ARGUMENTS

## Instructions

1. **Create a new daily note** in the folder `{{OBSIDIAN_VAULT_PATH}}/daily-notes/YYYY/MM-Month/` with filename format `YYYY-MM-DD.md`
   - Create year and month folders if they don't exist
   - Month folder should be formatted as "01-January", "02-February", etc.

2. **Include the following sections** in the note:
   - Daily header with date (format: "# Thursday, January 9, 2025")
   - Yesterday's link (if it exists)
   - Tomorrow's link (placeholder)
   - Weather/mood prompt section
   - Goals for today (based on context if provided)
   - Schedule/time blocks
   - Tasks checklist
   - Notes section
   - Reflections (empty for end of day)
   - Gratitude (3 items placeholder)

3. **Auto-linking**:
   - Link to yesterday's note if it exists
   - Add this note to a running index in `{{OBSIDIAN_VAULT_PATH}}/daily-notes/Index.md`
   - Tag with #daily-note and current week tag (#week-02-2025)

4. **Smart features**:
   - If context mentions specific tasks/goals, include them
   - If previous day exists, carry over any unchecked tasks
   - If it's Monday, add a "Week Overview" section
   - If it's Friday, add a "Week Review" section

5. **Template structure**:
```markdown
# [Day], [Month] [Date], [Year]

[[Previous Day]] | [[Next Day]]

## 🌤️ Weather & Mood
- Weather: 
- Energy Level: /10
- Mood: 

## 🎯 Goals for Today
[Parse from $ARGUMENTS or leave placeholder]
- [ ] 
- [ ] 
- [ ] 

## 📅 Schedule
- 09:00 - 
- 12:00 - 
- 15:00 - 
- 18:00 - 

## ✅ Tasks
### High Priority
- [ ] 

### Normal Priority
- [ ] 

### Low Priority
- [ ] 

## 📝 Notes
[Main notes section for the day]

## 🤔 Reflections
[End of day reflections]

## 🙏 Gratitude
1. 
2. 
3. 

---
Tags: #daily-note #week-[XX]-[YYYY] #[month]-[year]
```

6. **After creating the note**, update the index file and check for any carried-over tasks from yesterday.
