# Git Workflow Skill

Git workflow automation tool for standardized development processes.

## Features

- **Feature Branch Workflow**: Create and manage feature branches
- **Code Review Integration**: Generate review requests
- **Changelog Generation**: Auto-generate changelogs from commits
- **Version Tagging**: Semantic versioning with auto-tags
- **Branch Cleanup**: Clean up merged branches
- **Commit Templates**: Enforce commit message standards

## Usage

```bash
# Start new feature
git-workflow feature start <feature-name>

# Finish feature (merge and cleanup)
git-workflow feature finish <feature-name>

# Create release branch
git-workflow release start <version>

# Generate changelog
git-workflow changelog [--from-tag v1.0.0] [--to-tag v2.0.0]

# Tag new version
git-workflow version bump <major|minor|patch>

# Clean up merged branches
git-workflow cleanup [--dry-run]

# Setup commit template
git-workflow init
```

## Workflows

### Feature Branch Workflow
```
git-workflow feature start login
# → creates feature/login from develop
# → checkout feature/login

# ... make changes ...

git-workflow feature finish login
# → merge to develop
# → delete feature/login
# → checkout develop
```

### Release Workflow
```
git-workflow release start 1.2.0
# → creates release/1.2.0 from develop
# → bump version
# → checkout release/1.2.0

# ... final testing ...

git-workflow release finish
# → merge to main and develop
# → tag v1.2.0
# → delete release branch
```

## Commit Message Convention

Format: `<type>(<scope>): <subject>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

Examples:
```
feat(auth): add OAuth2 login
fix(api): handle null response
docs(readme): update installation guide
```

## Examples

```bash
# Initialize in a repo
git-workflow init

# Start a feature
git-workflow feature start user-dashboard

# Generate changelog since last release
git-workflow changelog --since-tag v1.0.0

# Bump minor version and tag
git-workflow version bump minor
```
