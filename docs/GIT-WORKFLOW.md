# 🌿 Git Workflow Guide

We follow a structured branching strategy based on [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) with Conventional Commits for consistent version control.

**📖 Learn more:**
- [Git Flow Cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [Atlassian Git Flow Tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Conventional Commits](https://www.conventionalcommits.org/)

## 📝 Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification for all commit messages.

### Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Commit Types

- **feat** - New feature
- **fix** - Bug fix
- **docs** - Documentation changes
- **style** - Code style changes (formatting, semicolons, etc.)
- **refactor** - Code refactoring
- **perf** - Performance improvements
- **test** - Adding or updating tests
- **build** - Build system or dependencies
- **ci** - CI/CD changes
- **chore** - Other changes that don't modify src or test files
- **revert** - Revert previous commit

### Commit Examples

```bash
# Feature
git commit -m "feat(auth): implement JWT authentication"

# Bug fix
git commit -m "fix(api): resolve CORS issue on user endpoint"

# Documentation
git commit -m "docs(readme): update installation instructions"

# Breaking change
git commit -m "feat(api)!: migrate to GraphQL API

BREAKING CHANGE: REST API endpoints are deprecated"

# Multiple scopes
git commit -m "fix(frontend,backend): resolve timezone inconsistency"

# With body and footer
git commit -m "feat(dashboard): add real-time metrics

- Add WebSocket connection
- Implement metric cards
- Add auto-refresh functionality

Closes #123"
```

### Scope Examples

- **auth** - Authentication/Authorization
- **api** - API changes
- **ui** - UI components
- **db** - Database
- **docker** - Docker configuration
- **k8s** - Kubernetes configuration
- **ci** - CI/CD pipeline
- **test** - Testing
- **deps** - Dependencies

## Branch Types

- **`main`** - Production-ready code
- **`develop`** - Integration branch for features
- **`feature/*`** - New features (`feature/user-authentication`)
- **`bugfix/*`** - Bug fixes for develop (`bugfix/login-validation`)
- **`hotfix/*`** - Critical fixes for production (`hotfix/security-patch`)
- **`release/*`** - Release preparation (`release/v1.2.0`)
- **`chore/*`** - Maintenance tasks (`chore/update-dependencies`)

## Branch Workflow

### Creating a Feature Branch

```bash
# Create feature branch
git checkout develop
git checkout -b feature/add-user-dashboard

# Work on feature
git add .
git commit -m "feat(dashboard): add user analytics widget"

# Keep updated with develop
git fetch origin
git rebase origin/develop

# Push and create PR
git push origin feature/add-user-dashboard
```

### Creating a Bugfix Branch

```bash
# Create bugfix branch
git checkout develop
git checkout -b bugfix/fix-login-validation

# Work on bugfix
git add .
git commit -m "fix(auth): resolve login validation issue"

# Push and create PR
git push origin bugfix/fix-login-validation
```

### Creating a Hotfix Branch

```bash
# Create hotfix branch from main
git checkout main
git checkout -b hotfix/security-patch

# Apply the fix
git add .
git commit -m "fix(security): patch critical vulnerability"

# Merge to main
git checkout main
git merge hotfix/security-patch
git tag -a v1.2.1 -m "Hotfix: Security patch"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge hotfix/security-patch
git push origin develop

# Delete hotfix branch
git branch -d hotfix/security-patch
```

### Creating a Release Branch

```bash
# Create release branch
git checkout develop
git checkout -b release/v1.2.0

# Update version numbers and finalize release
# Edit version in pyproject.toml, package.json, Chart.yaml
git commit -am "chore(release): bump version to 1.2.0"

# Merge to main
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge release/v1.2.0
git push origin develop

# Delete release branch
git branch -d release/v1.2.0
```

## 📝 Creating a Pull Request

### Before Creating a PR

1. **Ensure your branch is up to date:**
   ```bash
   git fetch origin
   git rebase origin/develop
   ```

2. **Run tests locally:**
   ```bash
   # Backend tests
   cd backend
   poetry run pytest

   # Frontend tests
   cd frontend
   pnpm test
   ```

3. **Verify code quality:**
   ```bash
   # Backend linting
   poetry run black .
   poetry run flake8

   # Frontend linting
   pnpm lint
   ```

### PR Title Convention

Follow the same convention as commit messages:

```
<type>(<scope>): <subject>
```

**Examples:**
- `feat(auth): implement JWT authentication`
- `fix(api): resolve CORS issue on user endpoint`
- `docs(readme): update installation instructions`
- `refactor(dashboard): optimize data fetching logic`

### PR Description Template

Use this template when creating a pull request:

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Changes Made
- List the main changes
- Include relevant details
- Mention any dependencies

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Test coverage maintained/improved

## Screenshots (if applicable)
Add screenshots or GIFs for UI changes.

## Related Issues
Closes #123
Related to #456

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] Branch is up to date with base branch
```

### Creating the PR

1. **Push your branch:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open GitHub and create PR:**
   - Navigate to the repository
   - Click "Pull requests" → "New pull request"
   - Select your branch
   - Fill in the PR template
   - Add reviewers
   - Add labels (feature, bugfix, documentation, etc.)
   - Link related issues

3. **Request reviews:**
   - Assign at least 2 reviewers
   - Wait for approval before merging
   - Address review comments promptly

### PR Review Guidelines

**For PR Authors:**
- Respond to all comments
- Make requested changes
- Re-request review after updates
- Keep PR scope focused and small
- Rebase if conflicts arise

**For Reviewers:**
- Review within 24 hours
- Be constructive and specific
- Check for code quality, tests, and documentation
- Approve only when fully satisfied
- Use GitHub's review features (Comment, Approve, Request Changes)

### Merging Strategy

We use **Squash and Merge** for most PRs:

1. **Squash and merge** (preferred):
   - Keeps history clean
   - All commits squashed into one
   - Use for feature and bugfix branches

2. **Merge commit**:
   - Use for release branches
   - Preserves all commit history

3. **Rebase and merge**:
   - Use for small, clean PRs
   - Maintains linear history

### After Merge

```bash
# Switch to develop and update
git checkout develop
git pull origin develop

# Delete local branch
git branch -d feature/your-feature-name

# Delete remote branch (if not auto-deleted)
git push origin --delete feature/your-feature-name
```

## Branch Protection Rules

### Main Branch
- Require pull request reviews (2 approvals)
- Require status checks to pass
- Require branches to be up to date
- No direct commits allowed
- No force pushes

### Develop Branch
- Require pull request reviews (1 approval)
- Require status checks to pass
- No force pushes

## Best Practices

1. **Keep branches short-lived** - Merge within 2-3 days
2. **One feature per branch** - Don't mix multiple features
3. **Descriptive branch names** - Use clear, meaningful names
4. **Regular commits** - Commit often with meaningful messages
5. **Update frequently** - Rebase with develop regularly
6. **Clean history** - Squash WIP commits before PR
7. **Test before PR** - Ensure all tests pass locally
8. **Small PRs** - Keep changes focused and reviewable (< 400 lines)
9. **Delete merged branches** - Clean up after merge
10. **Document breaking changes** - Clearly mark and explain

## Common Commands

```bash
# Update local develop
git checkout develop
git pull origin develop

# Create new feature branch
git checkout -b feature/my-feature

# Add and commit changes
git add .
git commit -m "feat(scope): description"

# Push to remote
git push origin feature/my-feature

# Rebase with develop
git fetch origin
git rebase origin/develop

# Interactive rebase (clean up commits)
git rebase -i HEAD~5

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Stash changes
git stash
git stash pop

# View branch history
git log --oneline --graph --decorate

# Check branch status
git status
git branch -vv
```

## Troubleshooting

### Merge Conflicts

```bash
# During rebase
git rebase origin/develop
# Fix conflicts in files
git add .
git rebase --continue

# Abort rebase if needed
git rebase --abort
```

### Accidentally Committed to Wrong Branch

```bash
# Move commits to new branch
git checkout develop
git checkout -b feature/correct-branch
git checkout develop
git reset --hard origin/develop
```

### Need to Update PR After Review

```bash
# Make changes
git add .
git commit -m "fix: address review comments"
git push origin feature/my-feature
```

---

**Questions?** Check the [Git Flow documentation](https://nvie.com/posts/a-successful-git-branching-model/) or ask in team discussions.
