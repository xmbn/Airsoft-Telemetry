# A Guide to Conventional Commit Prefixes

Using standardized prefixes in your commit messages is a best practice known as **Conventional Commits**. This approach makes your project's history more readable, enables automation, and helps everyone on the team quickly understand the nature of every change.

## Why Use Conventional Commits?

-   **Readability**: Quickly scan the commit log to understand what has changed.
-   **Automation**: Automatically generate changelogs from your commit history.
-   **Semantic Versioning**: Automatically determine a semantic version bump (e.g., `feat` triggers a minor version bump, while a `fix` triggers a patch).

---

## Common Prefixes

Here are the most widely used commit prefixes and their meanings.

### `feat`
A new feature for the user. This will typically correlate with a `MINOR` version bump in semantic versioning.

*   **Example**: `feat: allow users to upload a profile picture`

### `fix`
A bug fix for the user. This will typically correlate with a `PATCH` version bump.

*   **Example**: `fix: correct issue where login button was unresponsive`

### `docs`
Changes to documentation only. This does not trigger a release.

*   **Example**: `docs: update README with installation instructions`

### `style`
Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.). This does not trigger a release.

*   **Example**: `style: apply linter rules across the codebase`

### `refactor`
A code change that neither fixes a bug nor adds a feature, but improves the internal structure. This does not trigger a release.

*   **Example**: `refactor: extract user authentication logic into a separate service`

### `perf`
A code change that improves performance. This may trigger a `PATCH` or `MINOR` release depending on the impact.

*   **Example**: `perf: improve image loading speed by using a cache`

### `test`
Adding missing tests or correcting existing tests. This does not trigger a release.

*   **Example**: `test: add unit tests for the new payment module`

### `build`
Changes that affect the build system or external dependencies (e.g., updating npm, changing build scripts).

*   **Example**: `build: upgrade to the latest version of Flutter`

### `ci`
Changes to your Continuous Integration (CI) configuration files and scripts.

*   **Example**: `ci: add a new step to the GitHub Actions workflow`

### `chore`
Other changes that don't modify `src` or `test` files (e.g., updating `.gitignore`, managing dependencies).

*   **Example**: `chore: update .gitignore to exclude log files`

### `revert`
Used when reverting a previous commit. The body of the commit message should explain which commit is being reverted.

*   **Example**: `revert: feat: add user profile page`

---

## Scopes and Breaking Changes

### Scopes
You can add a scope in parentheses after the type to provide additional context. This is optional but highly recommended for larger projects.

*   `feat(auth): add password reset functionality`
*   `docs(readme): clarify setup process`
*   `fix(api): correct pagination error on user endpoint`

### Breaking Changes
To indicate a breaking change (which corresponds to a `MAJOR` version bump), an exclamation mark `!` can be added after the type/scope. A `BREAKING CHANGE:` footer must also be included in the commit body.

*   `feat(auth)!: replace JWT with session-based authentication`
    <br>
    `BREAKING CHANGE: The authentication mechanism has been changed. All clients must be updated.`

