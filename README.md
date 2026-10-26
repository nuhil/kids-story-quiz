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

- Explorer onboarding with name and age.
- Journey dashboard, 10 illustrated topics, and all 100 original stories.
- Search, topic filters, story details, page-by-page reading, and reading resume.
- Original story quizzes, mixed topic quizzes, randomized answer ordering, delayed fact popups, points, badges, and game passes.
- Bubble Pop, Snake Trail, Block Stack, two-player Tic-Tac-Toe, and Memory Match.
- Browser-local progress via localStorage. Data stays on the current browser/device; clearing browser data removes it. Changing from localhost to a hosted domain starts a separate progress collection.
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
- `public/stories/`: untouched original JSON source files.
- `public/content.json`: combined story content for browser loading.
- `public/assets/`, `public/assets.json`: copied iOS illustrations and lookup manifest.
- `docs/ios-reference/`: original design system, tokens, product strategy, and image-generation handoff. These are historical iOS references; image counts in them may predate the current catalog.
- `reference/ios/`: original Swift implementation retained for migration reference.
- `tests/`: content integrity and interaction tests.

The original iOS repository remains separate and unchanged. This repository implements web-native equivalents; native haptics and system controls are replaced by accessible browser controls. Story quizzes and mixed category quizzes are included.
