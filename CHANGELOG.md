## [1.20.0] - 2023-11-07
### Added
- precompiled dynamic libraries for libcrypto 1.1 and libssl  1.1 added to android/main/src/jniLibs folders - all standard android ABI types included

### Changed
- precomiled java libraries - jniLibs - included in sourcesets for build.gradles

## [1.19.3] - 2023-11-07
### Changed
- resolved Dart analyser Warnings
- pubspec updated to use cubixd version from Conciel org private repo - no code change in cubixd compared to local repo

### Removed
- Sharing intent not required in Chat List and Chat Share files

## [1.19.1] - 2023-11-01
### Added
- Configure primary Conciel UI text to use L10n translations - default of US English
- ConcielTalkBase and ConcielTalkBaseConfig enables translation

### Changed
- Social - Favorites typo fixed
- TALK, SHOP, BOOK - primary UI now use L10nn translations
- L10n translation defined after login

## [1.18.0] - 2023-10-30
### Added
- this will result in a major version change as the whole UI will be changed
- Conciel registers or opens Firebase data store - stores device id -> to enable direct and background notifications

### Changed
- LinesSplines, ChatList views and StandardDrawer widgets - all updated to use Screen Utils package
- Started changes to introduce screen size independence for UI - using the Screen Utils package
- Conciel Icon - adjusted to meet standard Material3 guidelines
- UI changes to suit device size variance - maintains design standard across mobile phones
- SOCIAL, CLOUD, PLAN - updates to button titles to suit updated Conciel design standard
- EMAIL - updates top button titles to suit updated Conciel design standard
- Sharing intent allows sharing from external apps into Conciel Talk - direct into private chat component
- Corrections to CallManager - Conciel app name and channel details
- Map search operates through Where - When - What and standard Search
- Google Maps registration at app startup
- Using standard Firebase plugins - replaces custom plugin from Matrix SDK developer - improves integration with notifications and maps

## [1.17.2] - 2023-10-10
### Changed
- info dots in local contacts are now horizontal

## [1.17.1] - 2023-10-10
### Changed
- Chat avatars have option of outline as new msg indicator
- Chat avatars default outline is none for normal and single width in red for fav
- Splines extended to meet UI ring

## [1.17.0] - 2023-10-10
### Changed
- Android Release Model 11
- biuld.gradle and AndroidManifest.xml to support local and key properties correctly
- what\_views.dart now allows search of restaurant sub-type
- Android SDK, plugins and gradle upgraded
- Where When What now populate a template for map search and progress through each to complete the search
- MAPS API key was incorrect

### Fixed
- Google Maps API key
- Google maps controller call now at current version

## [1.16.35] - 2023-10-09
### Added
- standard firebase messaging and storage mechanisms for notifcations
- Google Maps API and services for map search and what search overview
- map\_ui.dart - primary Maps page and Conciel wheel selections
- map\_search.dart - places search functions

### Changed
- all plugins and android sdk working with version 34
- SearchDrawer - to use new map\_ui page
- Conciel ArcButton to use specific colors for Conciel UI components
- Android pre-release 11 in build.gradle

### Removed
- background push notifications and custom fcm\_isolate\_plugin
- custom fcmpushservice.kt

## [1.16.33] - 2023-10-05
### Changed
- back press - no longer drops to biometrics page
- conciel icon press: single tap - back to home context (talk/shop/book)
- conciel icon press: double tap - open settings
- conciel icon press: long press - drop to biometrics page
- back press - reset where when what index
- defaultheaderwidget: set default values for conciel press and back press

### Removed
- boiler plate code for back press and conciel icon press handling

## [1.16.32] - 2023-10-05
### Changed
- Android pre-release 8 in build.gradle
- removed random calendar events in personal contacts detail page
- All startup tutorial changes as indicated in Intro\_app.pdf
- NewPrivateChat view - User invite always shows the Conciel user ID regardless of path taken

### Fixed
- bug where group room would always open on startup if unread or open invites
- issue where a none existing user would still be valid for creating a new direct chat - now will not progress unless user found

## [1.16.31] - 2023-10-04
### Changed
- Updated to Android pre-release 6
- Layout of settings now shows name and id clearer
- java version updated for WebRTC
- chat tile highlight on unread message to false
- voipPlugin is always attempted - calls are not experimental on Conciel
- disabled encryption for none direct chats

### Fixed
- Change password requested new password twice, in fact it should be existing followed by new - fixed

### Removed
- constraint on com.google.firebase:firebase messaging version

## [1.16.28] - 2023-10-03
### Fixed
- updates to remove Dart editor warnings, clean-up unused imports and code formatting

### Removed
- unnecessary files from github workflows
- flutter\_openssl ad flutter\_olm not required now that Matrix SDK is being pulled from the primary PUB DEV package archive

## [1.16.25] - 2023-10-03
[1.20.0]: https://github.com/Conciel/conciel_talk/compare/1.19.3...1.20.0
[1.19.3]: https://github.com/Conciel/conciel_talk/compare/1.19.1...1.19.3
[1.19.1]: https://github.com/Conciel/conciel_talk/compare/1.18.0...1.19.1
[1.18.0]: https://github.com/Conciel/conciel_talk/compare/1.17.2...1.18.0
[1.17.2]: https://github.com/Conciel/conciel_talk/compare/1.17.1...1.17.2
[1.17.1]: https://github.com/Conciel/conciel_talk/compare/1.17.0...1.17.1
[1.17.0]: https://github.com/Conciel/conciel_talk/compare/1.16.35...1.17.0
[1.16.35]: https://github.com/Conciel/conciel_talk/compare/1.16.33...1.16.35
[1.16.33]: https://github.com/Conciel/conciel_talk/compare/1.16.32...1.16.33
[1.16.32]: https://github.com/Conciel/conciel_talk/compare/1.16.31...1.16.32
[1.16.31]: https://github.com/Conciel/conciel_talk/compare/1.16.28...1.16.31
[1.16.28]: https://github.com/Conciel/conciel_talk/compare/1.16.25...1.16.28
[1.16.25]: https://github.com/Conciel/conciel_talk/releases/tag/1.16.25
