# How to contribute

We welcome contributions of all sizes: new questions, improved answers, clearer examples, or documentation fixes.

Workflow
- Fork the repository and create a branch named `feature/<short-description>` or `fix/<short-description>`.
- Make small, focused commits and keep PRs scoped to a single topic.
- Update or add matching files in `questions/` and `answers/`. For runnable code examples, place them under `examples/` with a short runner guarded by `if __FILE__ == $0`.
- Add tests if the change includes code that can be executed in isolation.
- Open a pull request and reference the issue (if any). Use the PR template to explain the change and list any manual verification steps.

Guidelines
- Use clear, concise language in questions and answers.
- Prefer examples that are dependency-free Ruby scripts unless you are demonstrating a Rails-specific pattern — then place them under `examples/rails/` and explain any Rails requirements.
- If adding a new question, add a matching answer in `answers/` and link them from the docs if appropriate.

Formatting & checks
- Follow `docs/question-format.md` for Q&A structure.
- Run any linters or formatting tools configured in CI before opening a PR.

If you're unsure how to get started, file an issue requesting help and we'll assign a good first task.
