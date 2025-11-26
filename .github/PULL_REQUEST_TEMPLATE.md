---
name: Pull request
about: Submit changes to the repository
title: '[Type] Brief description'
labels: ''
assignees: ''
---

## What type of change is this?

- [ ] New question + answer
- [ ] Improved or corrected answer
- [ ] New example or example update
- [ ] Documentation or formatting
- [ ] Chore (maintenance, CI, tooling)

## Summary

Provide a concise description of the change (1-3 short sentences). Explain the motivation and high-level approach.

## Related issues / links

- Closes: #
- Relates to: #
- Files affected: (list key file paths changed, e.g. `questions/..`, `answers/..`, `examples/..`)

## What I changed

- Bullet the main changes so reviewers can scan quickly.

## How to verify

Describe steps a reviewer can run locally to validate the change. For example:

```bash
# Run a small example
ruby examples/snippets/blocks_examples.rb

# Or lint markdown (if applicable)
# bundle exec mdl README.md
```

Include expected output or screenshots for visual changes.

## Migration notes (if applicable)

If the change introduces migrations, data changes, or recipe updates, document them here and include rollback steps.

## Docs & examples

If your change adds or updates examples, list them and confirm they're runnable and documented in `README.md` or `docs/CONTRIBUTING_EXAMPLES.md`.

## Checklist for contributors

- [ ] I have followed `docs/style-guide.md` for wording and examples
- [ ] I added or updated matching question and answer files (if applicable)
- [ ] I included or updated runnable examples (if applicable)
- [ ] I ran any linters or formatting checks and fixed issues
- [ ] My changes are small and focused (or clearly grouped with rationale)

## Reviewers / assignees suggestions

Recommend 1-2 reviewers and any labels to add (e.g., `documentation`, `bug`, `enhancement`).

## Release notes (optional)

One-line summary suitable for changelog or release notes.
