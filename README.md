# adamatan/homebrew-tap

[![Channel drift check](https://github.com/adamatan/homebrew-tap/actions/workflows/drift-check.yml/badge.svg)](https://github.com/adamatan/homebrew-tap/actions/workflows/drift-check.yml)

Homebrew tap for CLI tools by [@adamatan](https://github.com/adamatan). Green badge = every formula here matches its crates.io version. Red = at least one formula is lagging behind its source release.

## Usage

```bash
brew tap adamatan/tap
brew install <formula>
```

Or install directly without tapping first:

```bash
brew install adamatan/tap/<formula>
```

## Available formulae

| Tool | Description |
|---|---|
| [`hale`](https://github.com/adamatan/hale) | Instant network connection quality monitor |

More tools will be added as they graduate from the [lab monorepo](https://github.com/adamatan/lab).

## How it works

Formulae in this tap are generated and updated automatically by [cargo-dist](https://opensource.axo.dev/cargo-dist/) from each source repo on every release. No formula is maintained by hand.

To add a new project to this tap, configure `cargo-dist` in that project's `Cargo.toml`:

```toml
[workspace.metadata.dist]
installers = ["shell", "homebrew"]
tap = "adamatan/homebrew-tap"
publish-jobs = ["homebrew"]
```

The source repo needs a `HOMEBREW_TAP_TOKEN` secret: a fine-grained PAT with `contents: write` on this tap repo.
