# Prompt Engine — Flutter + PocketBase

> **This file defines how Manager AI sequences and generates prompts.**

---

## Step 1: Receive Project Analysis

After `startjp`, the Manager AI has a structured analysis:

```
- App name
- App description
- PocketBase URL (from REQUIREMENTS.md)
- Entities (collections) with fields, types, relationships
- Auth type (email, Google, Apple)
- Features detected (storage, realtime, hooks, notifications, payments, offline)
- UI/UX requirements
```

---

## Step 2: Load Configuration

Load from templates/:

1. **DEVELOPMENT_PHASES.json** → Get available phases
2. **PROMPT_TEMPLATES.json** → Get available templates
3. **TECH_STACKS.json** → Get Flutter + PocketBase patterns

Load from knowledge/:

4. **SAFETY_RULES.json** → Get protection phrases
5. **VERIFICATION.json** → Get verification methods
6. **ANTI_PATTERNS.json** → List of what NOT to do
7. **PAIN_POINTS.json** → Failure modes to mitigate

---

## Step 3: Determine Phase Sequence

### 3.1 Always Include
- PHASE_00: PocketBase VPS Setup
- PHASE_01: Foundation
- PHASE_02: PocketBase Collections
- PHASE_03: API Rules
- PHASE_05: Layout & Navigation
- PHASE_06: State Management
- PHASE_07: Core Features
- PHASE_11: UI Polish
- PHASE_15: Error Handling
- PHASE_16: Testing
- PHASE_17: Security Audit
- PHASE_18: Deployment

### 3.2 Include If Feature Detected

| Feature Detected | Include Phase |
|------------------|---------------|
| Any auth | PHASE_04: Authentication |
| File uploads | PHASE_08: File Storage |
| Realtime / chat / live | PHASE_09: Realtime (SSE) |
| Backend logic / triggers | PHASE_10: Server Hooks |
| Push notifications / FCM | PHASE_12: Notifications |
| Payments / Stripe | PHASE_13: Payments |
| Offline / caching | PHASE_14: Offline & Cache |

### 3.3 Skip If Not Needed

Phases not in the detected feature list are skipped entirely. No prompts generated for them.

---

## Step 4: Generate Prompt Sequence

### 4.1 Calculate Total Prompts

```
total = 0
for each included_phase:
    if phase == PHASE_07 (Core Features):
        total += entities.length * 4  (list, detail, create, edit per entity)
    else:
        total += phase.estimated_prompts
```

### 4.2 Generate One Prompt at a Time

For each prompt:

1. **Check phase type** from DEVELOPMENT_PHASES.json:
   - If `prompt_style` = `"exact_code"` → **BACKEND prompt** (Manager AI writes exact JS code)
   - If `prompt_style` = `"instructions_only"` → **FRONTEND prompt** (instructions only, no code)
   - If `prompt_style` = `"mixed"` → Check `prompt_style_note` to determine per-task

2. **For BACKEND prompts** (migrations, hooks, API rules):
   - Read `PROJECT_REPORT.md` for entity definitions
   - Read `research/POCKETBASE_CODER_GUIDE.md` for Schema/Rules/JS logic
   - **Manager AI writes the EXACT JavaScript code** in the prompt
   - Coding agent just creates the file and saves code — does NOT modify it
   - Use Backend Prompt Format (see Step 5)
   - Self-check = `bash deploy.sh` + `curl health check`

3. **For FRONTEND prompts** (Flutter screens, services, widgets):
   - Write natural language instructions only — **NO code**
   - Coding agent writes all Dart code based on instructions
   - Use Frontend Prompt Format (see Step 5)
   - Self-check = `flutter analyze` → 0 issues
   - **CRITICAL — Schema Bridge Rule:**
     - If the frontend prompt touches PocketBase data, include `📊 BACKEND SCHEMA` section
     - List the EXACT collection name, every field name + type, and all relations
     - Reference which backend prompt created this collection (e.g., "from Prompt 3")
     - The coding agent is a SEPARATE MIND — it knows NOTHING about backend unless you tell it

4. **Fill variables** with project-specific values:
   - Entity names → collection names, model names
   - File paths → lib/screens/{entity}/{action}_{entity}_screen.dart
   - Package names → from TECH_STACKS.json
   - Styling → from project UI requirements
5. **Inject safety rules** from SAFETY_RULES.json based on task type
6. **Add verification** from VERIFICATION.json based on task type
7. **Add NEXT preview** → brief description of what comes next

### 4.3 Phase 7 Entity Expansion

For each entity, generate 4 prompts in order:
1. Service layer (PT016 + PT017 combined if simple)
2. List screen (PT018)
3. Create form (PT020)
4. Detail + Edit + Delete (PT019 + PT021 combined)

This repeats for every entity identified in the project.

---

## Step 5: Format Output

Write each prompt to PROMPTS_OUTPUT.md using the correct format based on phase type.

### 5A: Backend Prompt Format (exact_code)

For backend prompts, **Manager AI writes the exact JavaScript code**. Coding agent just saves it.

```
═══════════════════════════════════════════════════════════
📋 PROMPT [X] of [TOTAL]
Phase: [Phase Name]
Task: [Task Name]
Type: 🔧 BACKEND (Code Provided by Manager AI)
📁 Read CODING_AGENT_CONTEXT.md first
═══════════════════════════════════════════════════════════

📋 INSTRUCTION:
[Brief explanation of what this migration/hook does and WHY]

📝 CREATE FILE: [exact path, e.g., pb_migrations/001_create_users.js]

```js
[EXACT JavaScript code — written by Manager AI]
[Coding agent saves this EXACTLY as-is. Do NOT modify.]
```

⛔ DO NOT:
- Modify the provided code
- Change file names or paths
- Skip any file

🔧 DEPLOY:
[CLI]: bash deploy.sh

✅ SELF-CHECK:
1. File created at correct path
2. deploy.sh ran without errors
3. curl https://{domain}/api/health → 200
4. Verify: collections exist / hooks loaded / rules applied
5. **Update PROJECT_STATUS.md** → mark this prompt ✅

👤 USER MANUAL STEPS (if any):
[Things only the USER can do — NOT the coding agent]
[If none: "None — coding agent handles everything."]

💬 CONFIRM IN CHAT:
"Prompt [X] complete. Backend deployed. Zero errors."

⏭️ NEXT: [preview]
═══════════════════════════════════════════════════════════
```

### 5B: Frontend Prompt Format (instructions_only)

For frontend prompts, Manager AI writes **instructions only**. Coding agent writes all Dart code.

```
═══════════════════════════════════════════════════════════
📋 PROMPT [X] of [TOTAL]
Phase: [Phase Name]
Task: [Task Name]
Type: 📱 FRONTEND (Instructions Only)
📁 Read CODING_AGENT_CONTEXT.md first
═══════════════════════════════════════════════════════════

📋 INSTRUCTION:
[What exactly to create or modify — natural language only]

📊 BACKEND SCHEMA (if this task touches PocketBase data):
Collection: "{collection_name}"
Created in: Prompt [X] (Phase [Y])
Fields:
  - field_name (type, constraints)
  - field_name (relation → other_collection)
  - ... [list ALL fields with exact names and types]
[If task doesn't touch PocketBase data: omit this section]

📝 CREATE/MODIFY:
File: [exact file path]

📋 REQUIREMENTS:
[Filled requirements — bullet points, behavior specs]

🎨 STYLING: (if UI task)
[Visual requirements — colors, spacing, typography]

📦 USE:
[Dependencies and imports]

⛔ DO NOT:
[Safety rules injected]

───────────────────────────────────────────────────────────
🔧 EXECUTE:
[CLI]: flutter analyze
───────────────────────────────────────────────────────────

✅ SELF-CHECK:
1. Run `flutter analyze` → 0 issues
2. [Task-specific verification]
3. Recheck: Is EVERY requirement implemented? (Y/N)
4. If ANY issue → fix NOW before confirming
5. **Update PROJECT_STATUS.md** → mark this prompt ✅

👤 USER MANUAL STEPS (if any):
[Things only the USER can do — NOT the coding agent]
[If none: "None — coding agent handles everything."]

💬 CONFIRM IN CHAT:
"Prompt [X] complete. Code is 100% functional. Zero errors."

⏭️ NEXT: [preview]
═══════════════════════════════════════════════════════════
```

---

## Notes

### Backend Code Generation Rule
- **Manager AI writes ALL PocketBase JS code** — migrations, hooks, API rules
- PocketBase JS syntax is niche — coding agents won't know it
- Coding agent's only job for backend: create file, paste code, run `bash deploy.sh`
- **Never give backend instructions without exact code** — that's a prompt failure

### Frontend Instructions Rule
- **Manager AI writes INSTRUCTIONS ONLY for Flutter** — no Dart code in prompts
- Flutter is mainstream — coding agents know it well
- Giving Flutter code = wasted prompt space, coding agent can do better
- **Never write Dart code in frontend prompts** — that's a prompt failure

### Dependency Awareness
- Never reference a file that hasn't been created in a previous prompt
- Always check phase dependencies before generating
- If a prompt needs a file from a later phase → reorder

### Pain Point Mitigation
- ONE file per prompt (prevents CTX001 overflow)
- Reference existing files explicitly (prevents HAL003)
- Include Dart types requirement (prevents DSF003)
- Specify PocketBase v0.23+ (prevents PBF001)
- Check mounted after async (prevents DSF001)

### Quality Checklist for Each Prompt
- [ ] Has clear INSTRUCTION
- [ ] Has specific file path
- [ ] Has complete REQUIREMENTS list (frontend) or exact code block (backend)
- [ ] Has EXECUTE commands (`bash deploy.sh` for backend, `flutter analyze` for frontend)
- [ ] Has SELF-CHECK with correct verification for type
- [ ] Has CONFIRM IN CHAT
- [ ] Has DO NOT constraints
- [ ] Has NEXT preview
- [ ] Has correct Type label (🔧 BACKEND or 📱 FRONTEND)
- [ ] Has 👤 USER MANUAL STEPS (or "None" if not applicable)
- [ ] References only files created in previous prompts
- [ ] Uses correct PocketBase SDK patterns from TECH_STACKS.json
- [ ] Backend prompts contain exact JS code, NOT instructions
- [ ] Frontend prompts contain instructions, NOT Dart code
- [ ] Frontend prompts that touch PocketBase data have 📊 BACKEND SCHEMA section
- [ ] Schema lists exact collection name, ALL fields with types, ALL relations
- [ ] Schema references which backend prompt created it
