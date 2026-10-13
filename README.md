# Puzzle Pet Hospital — Phase 1

A small offline-friendly Android game prototype for children, built with Godot 4.3.

## Phase 1 features
- Home screen and parent information screen
- Three patients: cat, dog, and bunny
- Simple shape-matching treatment puzzle
- Positive feedback, coins, stars, and recovery screen
- Garden/progress screen
- Local save file
- No ads, purchases, chat, or internet permission in this phase

## Build the APK
This environment did not have Godot, Android SDK, or Android export templates installed, so an APK could not be compiled locally. The included GitHub Actions workflow is configured to build the APK in a Godot CI environment.

1. Create a new GitHub repository and upload all files in this folder.
2. Ensure the default branch is named `main` or `master`.
3. Open the repository's **Actions** tab and run **Build Android APK** (or push a commit to trigger it).
4. When the workflow succeeds, open the run and download the `PuzzlePetHospital-Phase1-APK` artifact.
5. Install the APK on an Android test device. Android may ask you to allow installation from that source.

## Local development
Open this folder with Godot 4.3. For Android exports, configure the Android SDK/JDK and install the matching Godot export templates. Review the Android export preset and signing settings before any public store release.

## Notes
This is a prototype, not a store-ready release. Test gameplay, device scaling, Android export/signing, privacy disclosures, store policies, and child-safety requirements before publishing. The current puzzle is a simple prototype and should be expanded with art, sound, more puzzle variations, and accessibility testing.
