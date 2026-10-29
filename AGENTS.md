# Agent Notes

## New Mac Bootstrap

If this Mac has not been bootstrapped yet, run this first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

What it does:

- installs Homebrew if needed
- clones `schroneko/dotfiles` into `~/ghq/github.com/schroneko/dotfiles`
- links dotfiles into `$HOME`
- enables the `com.schroneko.dotfiles-sync` LaunchAgent
- runs the first sync

After that, dotfiles, Homebrew state, and the filtered `ghq` repo list sync automatically every hour. The `ghq` sync covers GitHub repos only; Hugging Face repos are not synced.

## Interaction Rule

- When the user asks a direct question, answer only that question.
- Do not make edits, revert changes, or take any additional action unless the user explicitly asks for it.
- Minimize user effort and avoid making the user ask follow-up questions for the obvious next step.
- When the next required action is clear, provide the exact command or commands the user should run.

## iPhone Development Distribution

- For NiceNotes / nice-notes-local iPhone changes, prefer the user's existing TestFlight distribution so the user can install and test while away. Do not require USB as the normal delivery path.
- Before declaring delivery complete, verify the build has uploaded, finished processing, and is available to the user's existing tester registration; provide the installation link or exact TestFlight installation steps.
- Use existing signing and App Store Connect access. Stop and hand off new credentials, access expansion, or legal agreement acceptance to the user. Do not publish to the public App Store or expand the tester audience without explicit authorization.
- Preserve existing recordings and offline audio processing.
