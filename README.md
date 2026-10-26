# StorySpark — Kids Story Quiz

A mobile-friendly static web conversion of the StorySpark SwiftUI app. The app stays centered at a maximum width of 480px, including on desktop browsers, and fits smaller screens without horizontal scrolling.

## Run locally

Requires Node.js 22 or newer.

```sh
npm ci
npm run dev
```

Open http://localhost:4173. Phone testing on the same Wi-Fi: open http://YOUR_COMPUTER_LAN_IP:4173.

```sh
npm test
npm run build
```

The production site is the `dist/` folder. No backend, runtime dependencies, external fonts, account service, or API keys are required.

## Included

- Splash screen and iOS-style explorer sign-in: a colorful A–Z letter keyboard and a sliding age wheel (4–14).
- Device-local explorer profiles keyed by lowercase name + age (e.g. `ava6`). "I Am Done Exploring" keeps progress; entering the same name and age brings it back. An unknown name/age asks whether the kid is new (creates a profile) or returning (suggests checking spelling and age). Several kids can share one device.
- Journey dashboard, 10 illustrated topics, and all 100 original stories.
- Search, topic filters, story details, page-by-page reading, and reading resume.
- Original story quizzes, mixed topic quizzes, randomized answer ordering, delayed fact popups, points, badges, and game passes.
- Bubble Pop, Snake Trail, Block Stack, Tic-Tac-Toe (robot or two players), and Memory Match with illustrated card sets (animals, fruits, vegetables, tools).
- Browser-local progress via localStorage (`storyspark.web.v2`; older single-profile saves are migrated automatically).
- Saved data is versioned and checked on load; damaged values are cleaned instead of breaking the app. Open tabs pick up each other's saves.
- Profile page: "Keep My Progress Safe" (Add to Home Screen guidance or install button, plus a backup code), "I Am Done Exploring", and a confirmed "Reset My Progress".
- Backup codes (`STORYSPARK-…`) carry one explorer's progress to another browser, device, the Home Screen app, or a future custom domain; restore them from "Have a backup code?" on the sign-in screen.
- Installable: web app manifest and icons in `public/`; the app asks the browser to keep its storage. On iPhone/iPad, Home Screen apps are exempt from Safari's 7-day storage cleanup but start with their own empty storage, so use a backup code to move progress in.
- A quiz in progress resumes after a refresh; leaving the quiz screen after answering asks first. Explore remembers its search text and scroll position.
- Read To Me: the browser's built-in speech reads each page aloud and highlights words as they are spoken (hidden when the browser has no speech support).
- Play Zone shows time left on unlocked games and best scores for every game. Tic-Tac-Toe has Easy Robot, Clever Robot and Two Players modes.
- Offline: `sw.js` caches the app files (network first, so updates appear immediately) and every image once shown. Bump `VERSION` in `sw.js` after replacing an image under the same file name. Data stays on the current browser/device; clearing browser data removes it. Changing from localhost to a hosted domain starts a separate progress collection.
- Each correct answer earns 10 points. An 80% quiz score earns a badge and game pass. A pass or 120 points unlocks one game for 24 hours. Replaying quizzes earns rewards, matching the iOS behavior.

## GitHub Pages — prepared, not published

`.github/workflows/pages.yml` is **manual only** so pushes do not publish the app while local testing is underway.

When ready:

1. In repository Settings → Pages, select **GitHub Actions** as the source.
2. In Actions → **Deploy to GitHub Pages**, choose **Run workflow** on `main`.
3. The workflow runs tests, builds `dist/`, and deploys it.

Relative asset URLs and hash routes support both `https://nuhil.github.io/kids-story-quiz/` and a future custom domain without a routing server. Add the custom domain in Pages settings later; no domain is configured now. GitHub's workflow reference: https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages

## Source organization

- `app.js`, `styles.css`, `index.html`: browser app.
- `public/stories/`: per-topic story source files. `public/content.json` is the combined copy the app loads; when editing a story, change both.
- `public/content.json`: combined story content for browser loading.
- `public/assets/`, `public/assets.json`: illustrations and lookup manifest. Story pages are 1080×720 JPEG named `StoryPage_<story_id>_<page>`; covers are `StoryCover<Topic><nn>`. A story page without its own image falls back to the topic backdrop, and a test fails if any are missing.
- `docs/ios-reference/`: original design system, tokens, product strategy, and image-generation handoff. These are historical iOS references; image counts in them may predate the current catalog.
- `reference/ios/`: original Swift implementation retained for migration reference.
- `tests/`: content integrity and interaction tests.

The original iOS repository remains separate and unchanged. This repository implements web-native equivalents; native haptics and system controls are replaced by accessible browser controls. Story quizzes and mixed category quizzes are included.
