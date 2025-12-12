# GitHub Workflows

This directory contains GitHub Actions workflows for the repo-sync project.

## Workflow Status Badges

Add these badges to your main README.md:

```markdown
[![CI](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/ci.yml)
[![Build](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/build.yml)
[![Lint](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/lint.yml)
[![Security](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/security.yml)
[![Release](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml/badge.svg)](https://github.com/MoshPitCodes/repo.sync/actions/workflows/release.yml)
```

## Workflows Overview

### CI Workflow (`ci.yml`)
**Triggers:** Push and Pull Request to main branch

**Purpose:** Continuous Integration testing across multiple platforms

**Jobs:**
- **test**: Runs tests on Ubuntu, macOS, and Windows with Go 1.24.x
  - Executes `go vet`
  - Runs tests with race detector
  - Generates coverage reports
  - Uploads coverage to Codecov (Ubuntu only)
- **lint**: Runs golangci-lint
- **format**: Checks code formatting with gofmt and go mod tidy

**Features:**
- Multi-platform testing matrix
- Race condition detection
- Code coverage reporting
- Dependency caching for faster builds
- Concurrency control to cancel stale runs

---

### Build Workflow (`build.yml`)
**Triggers:** Push and Pull Request to main branch

**Purpose:** Verify cross-compilation for all target platforms

**Jobs:**
- **build**: Cross-compiles binaries for multiple OS/architecture combinations
  - Linux: amd64, arm64
  - macOS: amd64, arm64
  - Windows: amd64, arm64
- **build-summary**: Aggregates build results

**Features:**
- Cross-platform compilation verification
- Build artifact uploads (7-day retention)
- Static binary builds (CGO_ENABLED=0)
- Build size reporting

---

### Lint Workflow (`lint.yml`)
**Triggers:** Push and Pull Request to main branch

**Purpose:** Comprehensive code quality and style checks

**Jobs:**
- **golangci-lint**: Runs golangci-lint with project configuration
- **gofmt**: Validates code formatting
- **goimports**: Checks import organization
- **go-mod-tidy**: Ensures go.mod and go.sum are tidy
- **go-vet**: Official Go static analyzer
- **staticcheck**: Advanced Go linting
- **nilaway**: Nil pointer analysis (continue-on-error)

**Features:**
- Multiple linting tools for comprehensive coverage
- Custom golangci-lint configuration
- Automated import organization checks
- Nil safety analysis

---

### Security Workflow (`security.yml`)
**Triggers:**
- Weekly schedule (Mondays at 9:00 AM UTC)
- Pull Requests
- Push to main
- Manual trigger (workflow_dispatch)

**Purpose:** Security vulnerability scanning and analysis

**Jobs:**
- **govulncheck**: Go vulnerability database scanning
- **gosec**: Security-focused code analysis with SARIF upload
- **dependency-review**: Reviews dependency changes in PRs
- **trivy**: Container and filesystem security scanning
- **nancy**: Sonatype dependency vulnerability checking

**Features:**
- Multiple security scanning tools
- SARIF format integration with GitHub Security
- Dependency license checking
- Weekly automated scans
- License denial (GPL-2.0, GPL-3.0)

---

### Release Workflow (`release.yml`)
**Triggers:** Git tags matching `v*` pattern

**Purpose:** Automated release creation with cross-platform binaries

**Jobs:**
- **release**: Primary release job using GoReleaser
  - Builds binaries for all platforms
  - Generates checksums
  - Creates GitHub release
  - Uploads artifacts
- **manual-release**: Fallback if GoReleaser fails
  - Manual build process
  - Platform-specific archives (tar.gz/zip)
  - SHA256 checksums
  - Release creation

**Features:**
- GoReleaser integration
- Cross-platform binary builds
- Automatic changelog generation
- Checksum generation
- Release asset uploads
- Fallback manual release process

---

## Configuration Files

### `.golangci.yml`
Comprehensive golangci-lint configuration with:
- 30+ enabled linters
- Custom rules for TUI/CLI projects
- Import ordering preferences
- Complexity thresholds
- Test file exclusions
- Security checks

### `.goreleaser.yml`
GoReleaser configuration with:
- Multi-platform build targets
- Archive generation (tar.gz/zip)
- Checksum creation
- Changelog generation
- Release notes templating
- Optional Homebrew tap support

---

## Setup Requirements

### GitHub Secrets (Optional)
- `CODECOV_TOKEN`: For code coverage uploads to Codecov
- Additional secrets may be needed for announcement integrations

### Branch Protection Rules
Recommended settings for `main` branch:
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Required status checks:
  - `test (ubuntu-latest, 1.24.x)`
  - `golangci-lint`
  - `gofmt Check`
  - `go mod tidy Check`
  - `govulncheck`

### Dependabot Integration
The project includes `.github/dependabot.yml` configuration for automated dependency updates.

---

## Local Development

### Running Linters Locally
```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Run all linters
golangci-lint run

# Auto-fix issues
golangci-lint run --fix

# Run specific linter
golangci-lint run --enable-only=errcheck
```

### Running Security Checks Locally
```bash
# Install govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest

# Run vulnerability check
govulncheck ./...

# Install gosec
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Run security scan
gosec ./...
```

### Testing Release Build Locally
```bash
# Install GoReleaser
go install github.com/goreleaser/goreleaser@latest

# Build snapshot (without publishing)
goreleaser release --snapshot --clean

# Check dist/ directory for built binaries
ls -la dist/
```

### Running Tests Locally
```bash
# Run all tests
go test -v ./...

# Run tests with race detector
go test -v -race ./...

# Run tests with coverage
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

---

## Workflow Maintenance

### Updating Actions Versions
Periodically update action versions to latest:
- `actions/checkout@v4`
- `actions/setup-go@v5`
- `golangci/golangci-lint-action@v4`
- `goreleaser/goreleaser-action@v5`

### Monitoring Workflow Performance
- Check workflow run times
- Review cache hit rates
- Monitor artifact sizes
- Track dependency update frequency

### Troubleshooting
- Check workflow logs in Actions tab
- Verify secrets are properly configured
- Ensure branch protection rules align with workflows
- Test locally before pushing changes
