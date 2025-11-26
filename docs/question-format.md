# Question & answer format

Each question and answer in this repository follows a small, consistent convention to make review and automation easy.

Questions
- Place questions under `questions/<level>/` where `<level>` is one of `beginner`, `intermediate`, `advanced`, or `rails`.
- Start the file with a short description and then list numbered prompts or bullets.
- Keep each prompt self-contained; include input/output, constraints, or example code where helpful.

Answers
- Place answers under `answers/<level>/` using the same filename as the corresponding question for easy mapping.
- Use a Q&A style: include the question prompt, a short direct answer, then an explanation and example code (if applicable).
- Keep answers concise. Use headings and code blocks to separate explanation and runnable snippets.

Example mapping
- `questions/beginner/variables.md` ↔ `answers/beginner/variables.md`

Automation notes
- Files are reviewed for formatting; keeping the structure consistent helps automated checks and makes it easier to generate sample tests or flashcards from the content.
