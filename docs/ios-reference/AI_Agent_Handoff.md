# StorySpark iOS App Handoff (AI Agent Spec)

## 1. Project Overview
- App name: **StorySpark** (Kids Story & Quiz).
- Platform: **iOS (SwiftUI)**.
- Xcode project: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz.xcodeproj`
- Repo root: `/Users/nuhil/Documents/Kids_Story_Quiz`
- Main app source folder: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz`

## 2. Product Spec Summary
- Target audience: kids (roughly 6-12).
- Core loop:
1. Pick a topic/category.
2. Open a story and read page-by-page.
3. Take quiz for that story.
4. Earn points and badges.
- Launch flow:
1. Splash screen.
2. Explorer onboarding (name + age).
3. Main tab app.
- Tabs:
1. Journey (home/progress)
2. Explore (story browsing/filter)
3. Play Zone (bubble game)
4. Achievements (profile, spark, badges, signout)

## 3. Key UX/Behavior
- Onboarding:
1. Title: `Let's Meet Our Explorer`
2. Name via colorful letter tiles.
3. Age via wheel picker, default `5`.
4. Name max length: `7`.
- Reading:
1. Read-only (no Read|Listen switch).
2. Page-by-page with next/previous.
3. Main story text enlarged and kid-friendly rounded typography.
- Quiz:
1. No `Question x of y` text.
2. `Check Answer` shows selection state first, then waits `~1s`.
3. During delay button shows spinner + `Loading Facts...`.
4. Feedback appears as popup modal (not inline).
- Achievements:
1. `Today's Spark` shows one random story from random category.
2. `Try Another` refreshes preview.
3. `Start Spark` opens currently previewed story.
4. Signout button text: `I Am Done Exploring` with kid-friendly confirmation.
- Play Zone:
1. Slower bubble drift, easier for kids.
2. Haptics added for tap/correct/miss/pause/round complete.
3. Bubble selection target is always chosen from visible tones.

## 4. Data Model and Story Pattern
- Story source: JSON files in `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/Stories`
- Category JSON pattern:
1. `category_name`, `category_id`
2. `stories[]`
3. Each story has `story_id`, `title`, `learning_objectives[]`, `pages[]`, `quiz[]`

### Current content totals
- Categories: `10`
- Stories: `100`
- Story pages: `1002`
- Quiz questions: `1000`

### Category files
1. `animals.json`
2. `culture.json`
3. `emotions_social.json`
4. `geography.json`
5. `history.json`
6. `math.json`
7. `ocean_life.json`
8. `science.json`
9. `space.json`
10. `technology.json`

## 5. Design System Sources
- Primary doc: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/Docs/DesignSystem.md`
- Token JSON: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/Docs/DesignTokens.json`
- Shared Swift tokens/styles: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/DesignSystem/DesignSystem.swift`

## 6. Image Strategy (Critical for Continuation)

### 6.1 Visual style used for generated assets
- Style keywords:
1. flat vector illustration
2. kids cartoon style
3. clean rounded shapes
4. smooth gradients
5. bright playful colors
6. simple shading
7. modern 2D educational illustration
- Hard avoid list:
1. no text
2. no logos
3. no watermark
4. no photorealism
5. no texture
6. no sketch lines
7. no clutter

### 6.2 Category card background images (Journey)
- Asset names:
1. `HomeOceanBackdrop`
2. `HomeAnimalsBackdrop`
3. `HomeSpaceBackdrop`
4. `HomeScienceBackdrop`
5. `HomeMathBackdrop`
6. `HomeCultureBackdrop`
7. `HomeEmotionsBackdrop`
8. `HomeHistoryBackdrop`
9. `HomeGeographyBackdrop`
10. `HomeTechnologyBackdrop`
- Integration reference:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/MainTabView.swift` (`HomeCategoryBackdrop`)

### 6.3 Story cover images
- Implemented covers:
1. Ocean: `StoryCoverOcean01...10`
2. Animals: `StoryCoverAnimals01...10`
3. Space: `StoryCoverSpace01...10`
4. Geography: `StoryCoverGeography01...10`
5. Technology: `StoryCoverTechnology01...10`
- Total cover assets: `50`
- Cover resolver (title -> asset) lives in:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/ArtworkViews.swift`

### 6.4 Page image naming and runtime lookup
- Runtime naming format:
`StoryPage_<story_id_normalized>_<2-digit-page>`
- Example:
`StoryPage_space_02_04`
- Lookup code:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/ArtworkViews.swift`
- Important logic:
1. `storyID` is normalized to lowercase + underscores.
2. If page asset exists, use it.
3. If missing, fallback is generated geometric topic artwork (not story cover).

## 7. Current Page Image Coverage

Coverage is by `story_id` prefix (because asset naming uses story IDs):

| Prefix | Expected Pages | Existing Page Assets |
|---|---:|---:|
| ocean | 101 | 101 |
| animals | 100 | 100 |
| space | 101 | 101 |
| geography | 100 | 7 |
| technology | 100 | 0 |
| science | 100 | 0 |
| math | 100 | 0 |
| culture | 100 | 0 |
| history | 100 | 0 |
| emotions | 100 | 0 |

Notes:
- `ocean_life.json` stories use `story_id` prefix `ocean`, so assets are `StoryPage_ocean_*_*`.
- `technology.json` uses category id `technology`, app maps it to topic `technologyMachines`.

## 8. How We Generated Page Images (Exact Workflow)

### 8.0 Goal
- Generate one distinct page illustration per story page, using the page text from JSON as the scene source, while preserving a consistent visual style across all categories.
- Keep image size optimized for shipping app size and for the horizontal artwork container used in the reader.

### 8.1 JSONL job files used
- Folder: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/tmp/imagegen`
- Examples:
1. `whaley_page_images_01_11.jsonl`
2. `page_images_remaining_5cats.jsonl`
3. `page_images_missing_resume.jsonl`
4. `space_pages_missing_only.jsonl`

### 8.2 JSONL line shape
Each line is one JSON object:
```json
{
  "out": "story_page_space_02_01.jpeg",
  "prompt": "Illustrate this kids story page from 'Luna the Moon That Travels': ...",
  "use_case": "illustration-story",
  "scene": "kid-friendly outer space scene",
  "subject": "Main scene should match this page and keep recurring character continuity for story 'Luna the Moon That Travels'.",
  "style": "flat vector illustration, kids cartoon style, clean rounded shapes, smooth gradients, modern 2D educational illustration",
  "composition": "horizontal image, centered main subject, safe margins, single clear focal point, readable on mobile",
  "lighting": "soft friendly lighting with clear contrast",
  "palette": "bright playful colors matching the story category",
  "materials": "simple shading only, no texture, no sketch lines",
  "constraints": "no text, no logos, no watermark, no photorealism, no clutter"
}
```

### 8.2.1 Prompt construction logic from story JSON
For each missing page asset:
1. Read story metadata from `Stories/*.json` (`title`, `learning_objectives`, `pages[]`).
2. For each page text, generate a prompt using:
   - Story title (for character continuity context).
   - Exact page text (primary scene instruction).
   - Category context (ocean/animals/space/etc.) for palette and motifs.
3. Keep character continuity phrase in every page prompt of the same story.
4. Keep composition constraints stable so UI crop stays consistent.

Prompt template used:
```text
Illustrate this kids story page from '<STORY_TITLE>': <PAGE_TEXT>
Main scene should match this page and keep recurring character continuity for story '<STORY_TITLE>'.
Flat vector illustration, kids cartoon style, clean rounded shapes, smooth gradients, modern 2D educational illustration.
Horizontal image, centered main subject, safe margins, single clear focal point.
Bright playful colors with good contrast on mobile.
No text, no logos, no watermark, no photorealism, no texture, no clutter.
```

### 8.3 Generation command pattern
Used local image skill CLI:
```bash
cd /Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz
python3 "$HOME/.codex/skills/imagegen/scripts/image_gen.py" generate-batch \
  --input "tmp/imagegen/<jobs>.jsonl" \
  --out-dir "output/imagegen/<batch_folder>" \
  --output-format jpeg \
  --concurrency 3 \
  --max-attempts 2
```

### 8.3.1 Size and optimization settings
- Target generation framing: horizontal (landscape) to match story artwork region.
- Generated outputs are optimized JPEG files before import (balanced quality/size).
- Naming pattern is deterministic and lowercased:
  - Output file: `story_page_<story_id>_<page>.jpeg`
  - Asset catalog set: `StoryPage_<story_id>_<page>.imageset`
- Keep assets only slightly larger than rendered view needs (avoid oversized source files).

### 8.4 Import to Xcode assets pattern
After generation, each output file `story_page_<prefix>_##_##.jpeg` is imported to:
`Assets.xcassets/StoryPage_<prefix>_##_##.imageset/image.jpeg`
with a standard `Contents.json`.

Implementation references:
- Import scripts/helpers: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/scripts`
- Temporary job definitions: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/tmp/imagegen`
- Generated outputs: `/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/output/imagegen`

### 8.5 Validation pattern used
1. Verify expected vs existing assets by reading story JSON and checking `.imageset` existence.
2. Build in Xcode CLI:
```bash
cd /Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project KidsStoryQuiz.xcodeproj \
  -scheme KidsStoryQuiz \
  -configuration Debug \
  -destination "generic/platform=iOS Simulator" build
```
3. Check warnings/errors, especially duplicate asset symbol warnings.

### 8.6 Duplicate-symbol warning avoidance (important)
- Xcode symbol generation can warn if two asset names normalize to the same Swift symbol.
- Rule enforced: use only one canonical asset naming style:
  - `StoryPage_<prefix>_##_##` (exact casing and underscore layout)
- Do not keep alternate variants for same page like:
  - `StoryPage_ocean_01_01` and `StoryPageOcean0101`
- If duplicates happen, delete/rename the non-canonical imageset and clean build folder.

## 9. Image Continuation Plan for Next Agent

### 9.1 Next targets
1. Finish **Geography** page images (remaining after 7 existing).
2. Generate **Technology** page images (currently 0).
3. Then complete Science, Math, Culture, History, Emotions.

### 9.2 Recommended continuation algorithm
1. Parse all category JSON.
2. For each story page, compute expected asset name: `StoryPage_<story_id>_<page:02d>`.
3. Compare against existing `.imageset`s.
4. Create JSONL only for missing pages.
5. Generate with same style keywords and constraints.
6. Import generated files into `Assets.xcassets`.
7. Re-run coverage check + build check.

### 9.3 Continuity rules
1. Keep recurring character look consistent within each story.
2. Keep one clear focal subject centered for horizontal crop safety.
3. Keep kid-friendly educational clarity over detail density.
4. Keep naming deterministic so resolver code works without changes.
5. Page scenes must evolve with page text (avoid reusing the same composition across many pages in one story).

## 10. Core Code References
- App entry:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/KidsStoryQuizApp.swift`
- Main tabs / Journey / Play Zone / Achievements:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/MainTabView.swift`
- Explore / Story detail / Reader:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/ExploreStoryViews.swift`
- Quiz flow:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/QuizViews.swift`
- Artwork resolution (cover/page/fallback):
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Views/ArtworkViews.swift`
- Models / topic mapping / progress:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Models/StoryModels.swift`
- Story JSON loader:
`/Users/nuhil/Documents/Kids_Story_Quiz/KidsStoryQuiz/KidsStoryQuiz/Data/StoryRepository.swift`

## 11. Git and Workspace Notes
- Repo root is now:
`/Users/nuhil/Documents/Kids_Story_Quiz`
- Previous folder name was `New project`.
- `.gitignore` now includes generated folders:
1. `tmp/`
2. `output/imagegen/`
3. `KidsStoryQuiz/tmp/`
4. `KidsStoryQuiz/output/imagegen/`
