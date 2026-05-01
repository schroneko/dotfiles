# Agent Notes

## New Mac Bootstrap

If this Mac has not been bootstrapped yet, run this first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/schroneko/dotfiles/main/setup.sh)"
```

What it does:

- installs Homebrew if needed
- installs `ghq` and `stow` if needed
- clones `schroneko/dotfiles` into `~/ghq/github.com/schroneko/dotfiles`
- links dotfiles into `$HOME`
- enables the `com.schroneko.dotfiles-sync` LaunchAgent
- runs the first sync

After that, dotfiles, Homebrew state, and `ghq` repo list sync automatically every 5 minutes.

## Interaction Rule

- When the user asks a direct question, answer only that question.
- Do not make edits, revert changes, or take any additional action unless the user explicitly asks for it.
- Minimize user effort and avoid making the user ask follow-up questions for the obvious next step.
- When the next required action is clear, provide the exact command or commands the user should run.
