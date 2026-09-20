# Aprecture Roadmap

Aprecture is a Flutter app for exploring and discovering Android apps from multiple APK sources, starting with F-Droid and expanding toward a richer, more flexible app catalog experience.

## Product vision

Build a modern, privacy-friendly app discovery client that helps users:

- browse curated app collections by category
- search quickly across app names, summaries, and tags
- view detailed metadata, screenshots, and developer links
- install or open apps from trusted sources
- manage app sources and keep data refreshed

## Current state

The app already has a working foundation:

- Flutter app shell with bottom navigation
- F-Droid repository indexing and parsing
- app list grouped by category
- search screen with fuzzy matching
- app detail screen with metadata and screenshots
- cache management and refresh actions

## Roadmap

### Phase 1: Stabilize the core experience (1-2 sprints)

Goal: Make the current app dependable and polished.

Planned work:

- fix loading, empty-state, and error-state UX
- improve app image loading and fallback handling
- make search results more consistent and readable
- tune category grouping and sort behavior
- add app refresh status, loading indicators, and retry flows
- improve settings screen with real configuration options

Success criteria:

- app opens reliably on supported Android devices
- indexing and cache logic works without crashes
- search and browsing feel smooth even with large datasets
- empty/error states are understandable and actionable

### Phase 2: Better app discovery and browsing (2-3 sprints)

Goal: Make the catalog easier to explore beyond a simple list.

Planned work:

- add featured apps and trending/updated sections
- support sorting by newest, most popular, category, and name
- add app cards with metadata like rating, download count, and update status
- support filtering by category and developer
- add recent searches and saved favorites
- improve search ranking and relevance

Success criteria:

- users can discover apps without knowing exact names
- category pages feel useful and intentional
- common browsing patterns are fast and discoverable

### Phase 3: Install and launch flows (3-4 sprints)

Goal: Turn the catalog into an app manager, not just a browser.

Planned work:

- integrate APK download flow from trusted repositories
- support install prompts and permission-aware behavior
- show package metadata, version history, and changelog
- add install/update/uninstall actions when appropriate
- add local app tracking and installed-state indicators
- introduce app open/download status feedback

Success criteria:

- user can install or open an app from the detail screen
- update/install states are clear and reliable
- app detail pages communicate trust and provenance

### Phase 4: Multi-source support and source management (3-5 sprints)

Goal: Let users browse apps from more than one provider.

Planned work:

- add provider abstraction so multiple sources can coexist
- support F-Droid, APKMirror, GitHub Releases, and custom repositories
- add provider selection and priority rules
- merge duplicate package records carefully
- support source health checks and connectivity errors
- add a provider configuration screen with per-source toggles

Success criteria:

- users can enable or disable providers independently
- sources remain usable even when one provider fails
- duplicates and metadata conflicts are handled predictably

### Phase 5: Personalization and trust layers (2-3 sprints)

Goal: Make the app feel tailored without sacrificing transparency.

Planned work:

- favorites, watchlist, and recent installs
- app recommendations based on installed or liked apps
- trust badges for verified or curated sources
- warnings for apps with missing metadata or suspicious links
- dark mode and accessibility improvements
- polished onboarding and first-run experience

Success criteria:

- users can build a personal app collection
- trust and safety signals are visible and understandable
- the app is comfortable to use over long sessions

### Phase 6: Community and long-term platform growth (future)

Goal: Expand the app beyond a basic catalog into a broader open-source discovery platform.

Planned work:

- community submissions and app review workflows
- local repository syncing for offline access
- advanced analytics and app health signals
- export/import of user settings and app lists
- optional account-backed sync across devices
- broader support for Android package metadata and update channels

Success criteria:

- app remains open, transparent, and community-oriented
- source metadata quality improves over time
- users trust the app as a safe, useful app source manager

## Priority order

1. reliability and bug fixing
2. discovery UX and search quality
3. install/download workflow
4. multi-provider architecture
5. personalization and trust
6. broader platform features

## Recommended next milestone

The next milestone should be: "A stable, polished app catalog with reliable search, browsing, and install-ready metadata from F-Droid."

This is the best near-term target because the app already has the foundation for it, and it will make the longer-term source-management work much easier to build on top of.

## Suggested delivery cadence

- sprint 1-2: polish the existing UI and stabilize data flows
- sprint 3-4: add richer discovery and sorting
- sprint 5-7: implement install and update flows
- sprint 8+: expand to multiple providers and personalization

## Open questions

- Should Aprecture support only app discovery, or also full install/update management?
- Is the primary market Android-only or cross-platform?
- Which providers should be considered primary in v1?
- Should app trust scores be community-driven or source-driven?
- Is offline caching a must-have for the first public release?

## Summary

The app has a strong MVP base and is positioned well for a catalog-first release. The best path is to stabilize the experience, improve discovery, then add installation and multi-source support. That sequence reduces risk and keeps the product aligned with the project’s original goal: a front-end for all APK providers.
