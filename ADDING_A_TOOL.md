# Adding a new tool to this tap

Recipe for wiring a Rust CLI from a GitHub repo to this tap. Every step in order. If something breaks, see "Gotchas" at the bottom.

**Audience:** future-you or an AI agent setting up a new tool. Not end users.

---

## Prerequisites

1. The source repo must be **public**. Homebrew cannot authenticate to download release binaries from a private repo.
2. The tool must already publish to crates.io (release-plz handles this). If not, that comes first.
3. `dist` CLI installed locally: `cargo install cargo-dist` (version 0.31.0 or newer).

---

## The recipe

### 1. `Cargo.toml`

Add `homepage` to `[package]` (cargo-dist warns without it):

```toml
homepage = "https://github.com/adamatan/<TOOL>"
```

Add these two sections at the bottom:

```toml
[profile.dist]
inherits = "release"
lto = "thin"

[workspace.metadata.dist]
cargo-dist-version = "0.31.0"
ci = "github"
installers = ["shell", "homebrew"]
tap = "adamatan/homebrew-tap"
publish-jobs = ["homebrew"]
targets = ["aarch64-apple-darwin", "aarch64-unknown-linux-gnu", "x86_64-apple-darwin", "x86_64-unknown-linux-gnu"]
pr-run-mode = "plan"
install-path = "CARGO_HOME"
install-updater = false
```

### 2. Generate `release.yml` (DO NOT hand-write it)

```bash
dist generate --mode=ci
```

This creates `.github/workflows/release.yml`. **Never edit that file afterwards.** cargo-dist validates it byte-for-byte on every run and refuses to run if it doesn't match what it would regenerate. Even whitespace changes break it.

To update it later: edit `[workspace.metadata.dist]`, run `dist generate --mode=ci` again.

### 3. `release-plz.toml`

Add at the top:

```toml
[workspace]
# cargo-dist owns GitHub Release creation (it attaches the binaries).
# release-plz still pushes the tag, bumps Cargo.toml, and publishes to crates.io.
git_release_enable = false
```

Without this, release-plz creates the GitHub Release first, then cargo-dist's `gh release create` fails with HTTP 422 "already exists."

### 4. `.github/workflows/test_and_release.yml`

Two changes. In the checkout step, add a `token:` line:

```yaml
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.RELEASE_PLZ_TOKEN }}   # <-- add this
```

In the release step, switch both token refs from `GITHUB_TOKEN` to `RELEASE_PLZ_TOKEN`:

```yaml
      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.RELEASE_PLZ_TOKEN }}   # <-- was GITHUB_TOKEN
          CARGO_REGISTRY_TOKEN: ${{ secrets.CRATES_IO_TOKEN }}
        run: |
          release-plz update --verbose
          if [[ -n $(git status -s) ]]; then
            git add .
            git commit -m "chore: release"
            git push origin main
          fi
          release-plz release --verbose --git-token "${{ secrets.RELEASE_PLZ_TOKEN }}" --backend github
          #                                                  ^^^ was GITHUB_TOKEN
```

Why: GitHub Actions suppresses workflow triggers on pushes made with `GITHUB_TOKEN` (loop prevention). Without this change, release-plz's tag push won't fire `release.yml` and cargo-dist never runs.

### 5. Repo secrets

Three secrets are required on the source repo (Settings → Secrets and variables → Actions):

- `CRATES_IO_TOKEN` — crates.io publish token
- `RELEASE_PLZ_TOKEN` — GitHub fine-grained PAT for release-plz
- `HOMEBREW_TAP_TOKEN` — GitHub fine-grained PAT for cargo-dist to push the formula

For exact scopes, token rotation policy, and the secret-layout rationale, see the private setup notes (out-of-band). Don't publish scope details in public docs, they're attacker reconnaissance shortcuts.

Create PATs at https://github.com/settings/personal-access-tokens/new. Set 1-year expiration, calendar-reminder to rotate.

### 6. Workflow permissions → write

```bash
gh api -X PUT repos/adamatan/<TOOL>/actions/permissions/workflow \
  --field default_workflow_permissions=write \
  --field can_approve_pull_request_reviews=false
```

Without this, cargo-dist's `gh release create` fails with `HTTP 403: Resource not accessible by integration`. The `permissions: contents: write` in the workflow file alone is not enough.

### 7. Commit and push

```bash
git add Cargo.toml release-plz.toml .github/workflows/
git commit -m "ci: add cargo-dist for prebuilt binaries and Homebrew tap"
git push origin main
```

### 8. Trigger the first real release

The pipeline only fires for `feat:`, `fix:`, `perf:`, or `BREAKING CHANGE:` commits. A `ci:` or `chore:` commit won't bump the version. If you just committed only setup (`ci:`), push any real feature or fix next.

---

## What happens on every subsequent main commit

```
feat: / fix: commit → main
       │
       ▼
test_and_release.yml (RELEASE_PLZ_TOKEN):
  1. cargo fmt + clippy + test
  2. release-plz bumps Cargo.toml + CHANGELOG
  3. release-plz commits "chore: release" and pushes
  4. release-plz publishes to crates.io
  5. release-plz pushes git tag (does NOT create GitHub Release)
       │
       ▼
tag push (via PAT, not GITHUB_TOKEN) fires release.yml
       │
       ▼
cargo-dist:
  1. Builds binaries for 4 platforms
  2. Creates the GitHub Release with binaries
  3. Commits updated formula to adamatan/homebrew-tap
```

---

## How to verify it worked

After the first real release:

```bash
# Check crates.io
curl -s -A "check" "https://crates.io/api/v1/crates/<TOOL>" | jq '.crate.max_stable_version'

# Check tap formula
cat /opt/homebrew/Library/Taps/adamatan/homebrew-tap/Formula/<TOOL>.rb | grep version

# Both should match. The daily drift-check workflow in this tap will confirm.
```

---

## Gotchas

- **Private repo = no Homebrew.** Release assets inherit repo visibility. No way around it short of self-hosting authenticated binaries.
- **`release.yml` is owned by cargo-dist.** Never hand-edit. Regenerate with `dist generate --mode=ci` after `Cargo.toml` config changes.
- **GITHUB_TOKEN does not trigger workflows.** Any tag or commit push that should trigger another workflow must be authenticated with a PAT.
- **crates.io API requires a User-Agent header.** Without one, you get HTTP 403.
- **release-plz + cargo-dist both want to create the GitHub Release.** Set `git_release_enable = false` in `release-plz.toml` to give cargo-dist exclusive ownership.
- **Default workflow permissions are `read`.** Must be set to `write` via the API call in step 6 (setting `permissions: contents: write` in the workflow file alone doesn't override the repo-level default for all operations).
- **If a run fails with "bad credentials" during checkout, the RELEASE_PLZ_TOKEN secret value is wrong.** Regenerate the PAT and re-paste. The value can't be read back once saved, so any pasting mistake is silent.
- **Version jumps happen.** If you delete the tag or release to retry, release-plz will bump to the next version on the next run rather than re-using the deleted one. That's fine, the drift check compares against `max_version`, not a specific tag.
