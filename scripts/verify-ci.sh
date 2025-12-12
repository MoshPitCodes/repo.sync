#!/bin/bash
# Verify CI/CD setup locally before pushing to GitHub
# This script runs the same checks that GitHub Actions will run

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================================================"
echo "Local CI/CD Verification Script"
echo "================================================================================"
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to run check
run_check() {
    echo ""
    echo -e "${YELLOW}Running:${NC} $1"
    echo "--------------------------------------------------------------------------------"
}

# Check if we're in the right directory
if [ ! -f "go.mod" ]; then
    echo -e "${RED}Error: go.mod not found. Run this script from the project root.${NC}"
    exit 1
fi

# 1. Check Go version
run_check "Go version check"
go version
print_status $? "Go version check"

# 2. Download dependencies
run_check "Download dependencies"
go mod download
print_status $? "Dependencies downloaded"

# 3. Verify dependencies
run_check "Verify dependencies"
go mod verify
print_status $? "Dependencies verified"

# 4. Check go mod tidy
run_check "Check go mod tidy"
cp go.mod go.mod.bak
cp go.sum go.sum.bak
go mod tidy
if diff -q go.mod go.mod.bak && diff -q go.sum go.sum.bak; then
    print_status 0 "go.mod and go.sum are tidy"
    rm go.mod.bak go.sum.bak
else
    echo -e "${RED}go.mod or go.sum needs to be tidied${NC}"
    echo "Differences found - restoring original files"
    mv go.mod.bak go.mod
    mv go.sum.bak go.sum
    print_status 1 "go mod tidy check"
fi

# 5. Run gofmt
run_check "Check gofmt formatting"
unformatted=$(gofmt -l . | grep -v vendor || true)
if [ -z "$unformatted" ]; then
    print_status 0 "All files are properly formatted"
else
    echo -e "${RED}The following files need formatting:${NC}"
    echo "$unformatted"
    print_status 1 "gofmt check"
fi

# 6. Run go vet
run_check "Run go vet"
if go vet ./...; then
    print_status 0 "go vet passed"
else
    print_status 1 "go vet failed"
fi

# 7. Run tests
run_check "Run tests"
if go test -v ./...; then
    print_status 0 "Tests passed"
else
    print_status 1 "Tests failed"
fi

# 8. Run tests with race detector
run_check "Run tests with race detector"
if go test -race ./...; then
    print_status 0 "Race detector tests passed"
else
    print_status 1 "Race detector tests failed"
fi

# 9. Run golangci-lint if available
run_check "Run golangci-lint"
if command -v golangci-lint &> /dev/null; then
    if golangci-lint run --timeout=5m; then
        print_status 0 "golangci-lint passed"
    else
        print_status 1 "golangci-lint failed"
    fi
else
    echo -e "${YELLOW}⚠${NC} golangci-lint not installed, skipping"
    echo "Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# 10. Run govulncheck if available
run_check "Run govulncheck"
if command -v govulncheck &> /dev/null; then
    if govulncheck ./...; then
        print_status 0 "govulncheck passed"
    else
        print_status 1 "govulncheck found vulnerabilities"
    fi
else
    echo -e "${YELLOW}⚠${NC} govulncheck not installed, skipping"
    echo "Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"
fi

# 11. Try building
run_check "Build binary"
if go build -v -o dist/repo-sync .; then
    print_status 0 "Build successful"
    rm -rf dist/
else
    print_status 1 "Build failed"
fi

# Summary
echo ""
echo "================================================================================"
echo "Verification Complete"
echo "================================================================================"
echo ""
echo "If all checks passed, you're ready to push to GitHub!"
echo ""
echo "Next steps:"
echo "  1. git add ."
echo "  2. git commit -m 'your message'"
echo "  3. git push origin main"
echo ""
echo "To create a release:"
echo "  1. git tag -a v0.1.0 -m 'Initial release'"
echo "  2. git push origin v0.1.0"
echo ""
