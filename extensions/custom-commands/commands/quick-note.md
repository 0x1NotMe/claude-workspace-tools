# Quick Note

You are given the following context: $ARGUMENTS

## Instructions

1. **Find today's daily note** in the folder `{{OBSIDIAN_VAULT_PATH}}/daily-notes/YYYY/MM-Month/` with filename format `YYYY-MM-DD.md`

2. **If today's note doesn't exist**:
   - Create it using the same template as the daily-note command
   - Follow the same folder structure (YYYY/MM-Month/)

3. **Add the quick note entry**:
   - Add a timestamp entry in the "## 📝 Notes" section
   - Format: `**[HH:MM]** - [Note content from $ARGUMENTS]`
   - Insert entries chronologically (latest at the bottom)

4. **Smart features**:
   - If $ARGUMENTS contains task-like language ("need to", "todo", "remember to"), also add it to the appropriate Tasks section
   - If $ARGUMENTS contains scheduling language ("at 3pm", "tomorrow", "next week"), highlight it in the note
   - If $ARGUMENTS is very short (< 10 words), treat it as a simple note entry
   - If $ARGUMENTS is longer, parse for actionable items

5. **Task detection patterns**:
   - "need to [action]" → Add to Normal Priority tasks
   - "must [action]" → Add to High Priority tasks
   - "should [action]" → Add to Normal Priority tasks
   - "remind me to [action]" → Add to Normal Priority tasks
   - "don't forget to [action]" → Add to High Priority tasks

6. **Entry format examples**:

   ```markdown
   **14:30** - Quick thought about the project structure
   **15:45** - Meeting with Sarah went well, need to follow up on budget
   **16:20** - Idea: What if we automated the report generation?
   ```

7. **If actionable items are detected**:
   - Add to the Notes section with timestamp
   - Also add to the appropriate Tasks section as a checkbox item
   - Include a note like "(Added from quick note at 14:30)"

8. **Special handling**:
   - If the note contains gratitude ("grateful for", "thankful", "appreciate"), also add to Gratitude section
   - If the note mentions mood/energy ("feeling tired", "energetic", "stressed"), update the Weather & Mood section
   - If the note is about a goal or accomplishment, consider adding to Goals section

9. **Preserve existing content**:
   - Don't overwrite any existing sections
   - Maintain the chronological order in the Notes section
   - Keep all existing tasks and formatting intact 