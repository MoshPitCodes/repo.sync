# GitHub Workflows Setup Summary

This document summarizes the GitHub Actions workflows added to the repo-sync project.

## Created Files

### Workflow Files (`.github/workflows/`)
1. **ci.yml** - Continuous Integration workflow
2. **build.yml** - Cross-platform build verification
3. **lint.yml** - Code quality and style checks
4. **security.yml** - Security vulnerability scanning
5. **release.yml** - Automated release creation
6. **README.md** - Workflow documentation

### Configuration Files
1. **.golangci.yml** - golangci-lint configuration
2. **.goreleaser.yml** - GoReleaser configuration

---

## Workflow Overview

### 1. CI Workflow (`ci.yml`)
**Triggers:** Push and PR to main

**Features:**
- Multi-platform testing (Ubuntu, macOS, Windows)
- Go 1.24.x version matrix
- Race condition detection
- Code coverage with Codecov integration
- Format and tidy checks
- Concurrency control

**Jobs:**
- `test`: Runs tests across platforms with race detector
- `lint`: Executes golangci-lint
- `format`: Validates gofmt and go mod tidy

**Status Badge:**
```markdown
[![CI](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml)
```

---

### 2. Build Workflow (`build.yml`)
**Triggers:** Push and PR to main

**Features:**
- Cross-compilation verification
- Multiple OS/architecture targets
- Build artifact uploads (7-day retention)
- Static binary builds (CGO_ENABLED=0)

**Build Matrix:**
- Linux: amd64, arm64
- macOS: amd64, arm64
- Windows: amd64, arm64

**Status Badge:**
```markdown
[![Build](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml)
```

---

### 3. Lint Workflow (`lint.yml`)
**Triggers:** Push and PR to main

**Features:**
- Comprehensive linting with golangci-lint
- Format validation (gofmt, goimports)
- Static analysis (go vet, staticcheck)
- Nil pointer analysis (nilaway)
- Concurrency control

**Jobs:**
- `golangci-lint`: Runs configured linters
- `gofmt`: Code formatting check
- `goimports`: Import organization check
- `go-mod-tidy`: Dependency tidiness check
- `go-vet`: Official Go analyzer
- `staticcheck`: Advanced linting
- `nilaway`: Nil safety analysis

**Status Badge:**
```markdown
[![Lint](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml)
```

---

### 4. Security Workflow (`security.yml`)
**Triggers:**
- Weekly schedule (Mondays 9 AM UTC)
- Push and PR to main
- Manual trigger (workflow_dispatch)

**Features:**
- Multiple security scanning tools
- SARIF integration with GitHub Security
- Dependency vulnerability checking
- License compliance validation

**Jobs:**
- `govulncheck`: Go vulnerability database scan
- `gosec`: Security-focused analysis
- `dependency-review`: PR dependency changes (PR only)
- `trivy`: Filesystem security scan
- `nancy`: Sonatype dependency check

**Status Badge:**
```markdown
[![Security](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml)
```

---

### 5. Release Workflow (`release.yml`)
**Triggers:** Tags matching `v*` pattern (e.g., v1.0.0)

**Features:**
- GoReleaser integration
- Cross-platform binary builds
- Checksum generation
- Automatic changelog creation
- GitHub release creation
- Fallback manual release

**Release Assets:**
- Binaries for all platforms
- Archives (tar.gz for Unix, zip for Windows)
- SHA256 checksums
- Automated release notes

**Status Badge:**
```markdown
[![Release](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml)
```

---

## Configuration Details

### golangci-lint Configuration (`.golangci.yml`)

**Key Settings:**
- Timeout: 10 minutes
- 30+ enabled linters
- Custom rules for TUI/CLI projects
- Import ordering with local prefix
- Complexity thresholds (cyclomatic: 15, cognitive: 20)
- Function length limits (100 lines, 50 statements)

**Enabled Linters:**
- Core: errcheck, gosimple, govet, ineffassign, staticcheck, unused
- Style: revive, stylecheck, whitespace, wsl, gci
- Quality: gocyclo, gocognit, funlen, gocritic
- Security: gosec, errorlint
- Others: gofmt, goimports, misspell, goconst, prealloc

**Special Rules:**
- Test files excluded from complexity checks
- Bubble Tea event handling style exemptions
- Dot imports allowed in tests

---

### GoReleaser Configuration (`.goreleaser.yml`)

**Build Targets:**
- Linux: amd64, arm64
- macOS: amd64, arm64
- Windows: amd64 (arm64 excluded)

**Features:**
- Pre-release test execution
- Trimmed binaries with stripped symbols
- Version/commit/date injection via ldflags
- Platform-specific archives
- SHA256 checksums
- Semantic changelog grouping
- Auto-detection of prereleases

**Changelog Groups:**
1. New Features
2. Bug Fixes
3. Performance Improvements
4. Refactorings
5. Documentation
6. Other Changes

---

## Next Steps

### 1. Add Status Badges to README
Add these badges to the top of your README.md:

```markdown
[![CI](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml)
[![Build](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml)
[![Lint](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml)
[![Security](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml)
[![Release](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml)
```

### 2. Configure GitHub Secrets (Optional)
Navigate to Settings → Secrets and variables → Actions:

- **CODECOV_TOKEN** (optional): For code coverage uploads
  - Sign up at https://codecov.io
  - Connect your repository
  - Copy the token and add it as a secret

### 3. Set Up Branch Protection
Navigate to Settings → Branches → Add rule for `main`:

**Required settings:**
- ✓ Require a pull request before merging
- ✓ Require status checks to pass before merging
- ✓ Require branches to be up to date before merging

**Required status checks:**
- `test (ubuntu-latest, 1.24.x)` (from CI)
- `golangci-lint` (from Lint)
- `gofmt Check` (from Lint)
- `go mod tidy Check` (from Lint)
- `govulncheck` (from Security)

### 4. Test the Workflows

**Test CI and Build:**
```bash
# Push changes to trigger workflows
git add .github/workflows/*.yml .golangci.yml .goreleaser.yml
git commit -m "ci: add GitHub Actions workflows"
git push origin main
```

**Test Release:**
```bash
# Create and push a version tag
git tag -a v0.1.0 -m "Initial release"
git push origin v0.1.0
```

### 5. Monitor First Run
1. Go to Actions tab in GitHub
2. Watch workflows execute
3. Fix any issues that arise
4. Verify artifacts are created

---

## Local Development Commands

### Run Linters Locally
```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run all linters
golangci-lint run

# Auto-fix issues
golangci-lint run --fix
```

### Run Security Scans Locally
```bash
# Install and run govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...

# Install and run gosec
go install github.com/securego/gosec/v2/cmd/gosec@latest
gosec ./...
```

### Test Release Build Locally
```bash
# Install GoReleaser
go install github.com/goreleaser/goreleaser@latest

# Test release build (without publishing)
goreleaser release --snapshot --clean

# Check generated binaries
ls -la dist/
```

### Run Tests with Coverage
```bash
# Run tests with coverage
go test -v -race -coverprofile=coverage.out ./...

# View coverage in browser
go tool cover -html=coverage.out
```

---

## Troubleshooting

### Common Issues

**1. Workflow fails on first run**
- Check workflow logs in Actions tab
- Ensure all paths and file references are correct
- Verify Go version compatibility

**2. golangci-lint fails**
- Run locally first: `golangci-lint run`
- Fix issues or adjust `.golangci.yml` configuration
- Consider using `--fix` for auto-fixable issues

**3. Release workflow fails**
- Verify tag format matches `v*` pattern
- Check GoReleaser configuration
- Ensure `GITHUB_TOKEN` has write permissions

**4. Security scans fail**
- Review vulnerability reports
- Update dependencies: `go get -u ./...`
- Consider adding exceptions if false positives

**5. Build fails on specific platform**
- Check platform-specific code
- Verify CGO requirements
- Test locally with GOOS/GOARCH env vars

---

## Maintenance

### Regular Tasks

**Weekly:**
- Review security scan results
- Check for dependency updates via Dependabot

**Monthly:**
- Update GitHub Actions versions
- Review and update linter configurations
- Check workflow performance metrics

**As Needed:**
- Adjust golangci-lint rules based on team feedback
- Update GoReleaser configuration for new platforms
- Modify branch protection rules

### Updating Dependencies

**GitHub Actions:**
```yaml
# Update to latest versions in workflow files
actions/checkout@v4        → check for v5
actions/setup-go@v5        → check for newer
golangci/golangci-lint-action@v4 → check for newer
```

**Go Dependencies:**
```bash
# Update all dependencies
go get -u ./...
go mod tidy

# Update specific dependency
go get -u github.com/package/name
```

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [golangci-lint Documentation](https://golangci-lint.run/)
- [GoReleaser Documentation](https://goreleaser.com/)
- [Go Vulnerability Database](https://vuln.go.dev/)
- [Codecov Documentation](https://docs.codecov.com/)

---

## File Locations

```
repo.sync/
├── .github/
│   └── workflows/
│       ├── ci.yml           # Continuous Integration
│       ├── build.yml        # Cross-platform builds
│       ├── lint.yml         # Code quality checks
│       ├── security.yml     # Security scanning
│       ├── release.yml      # Release automation
│       └── README.md        # Workflow documentation
├── .golangci.yml            # golangci-lint config
├── .goreleaser.yml          # GoReleaser config
└── WORKFLOWS_SETUP.md       # This file
```

---

## Summary

All GitHub Actions workflows have been successfully configured for the repo-sync project. The workflows provide:

✅ Comprehensive testing across platforms
✅ Automated code quality checks
✅ Security vulnerability scanning
✅ Cross-platform build verification
✅ Automated release creation
✅ Code coverage reporting
✅ Dependency management

The project now follows industry best practices for Go development with automated CI/CD pipelines.
