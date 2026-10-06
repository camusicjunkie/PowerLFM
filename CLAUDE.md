## Agent skills

### Issue tracker

Issues live as GitHub issues on `camusicjunkie/PowerLFM` (uses the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Running tests

`./build.ps1 -Task QuickTest -TestPath <file or folder>` builds the module at 0.0.0 and runs those tests without coverage; omit `-TestPath` for the whole suite. `-Task Analyze` lints the source. CI runs `Analyze`, `Build` and `Test`.
