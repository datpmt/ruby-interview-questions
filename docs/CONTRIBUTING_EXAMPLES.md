# Contribution examples

This file shows example filled forms for the GitHub issue and pull request templates used in this repository. Use these as a model when opening issues or PRs.

---

## Example: Bug report (filled)

Title: [Bug] Typo and incorrect code example in `answers/intermediate/blocks_procs_lambdas.md`

Issue type: Bug

What is incorrect?
- File path: `answers/intermediate/blocks_procs_lambdas.md`
- Current content: The code example under "Proc vs lambda" uses `return` inside a Proc which is presented as identical to lambda behavior.
- Expected content / suggested fix: Explain the difference in `return` behavior and provide a corrected code snippet showing how `return` in a Proc returns from the enclosing method.

Reproduction or context:
- See the code block under the heading "Proc vs lambda".

Additional information:
- Suggested replacement snippet:

```ruby
def demo
  p = Proc.new { return :from_proc }
  p.call
  :after_proc
end

puts demo # => :from_proc
```

Steps to validate the fix:
1. Update the answer file with the corrected explanation and snippet.
2. Run `ruby` on the example snippet locally to verify behavior.

---

## Example: Question / improvement (filled)

Title: [Question] Add an example for `Module#prepend` vs `Module#include`

Summary:
- Request: Add a short example comparing `Module#prepend` and `Module#include` to the `modules_mixins.md` question/answer pair.

Examples or context:
- Current file: `questions/intermediate/modules_mixins.md`
- Suggestion: Add two tiny snippets showing method lookup order with `prepend` vs `include` and a one-paragraph explanation.

What would help?
- [x] Better example code
- [ ] More detailed explanation
- [ ] New question or topic

Additional context:
- This would help clarify a common interview question about mixin behavior and method lookup order.

---

## Example: Pull request (filled)

Title: [Improved answer] Clarify Proc vs Lambda in `answers/intermediate/blocks_procs_lambdas.md`

Type of change:
- [x] Improved or corrected answer

Description:
- Clarify differences between `Proc` and `lambda` with respect to arity and `return` behavior; added two small runnable snippets.

Related issues:
- Closes #123 (example bug report linked here)

Changes made:
- Updated `answers/intermediate/blocks_procs_lambdas.md` with the corrected explanation and two code snippets.
- Added `examples/snippets/blocks_proc_lambda_demo.rb` demonstrating behavior.

### Running the demo example

You can run the small demo added in this repo with:

```bash
ruby examples/snippets/blocks_proc_lambda_demo.rb
```

Expected output roughly:

```
demo_lambda =>  after lambda: lambda returned: 6
demo_proc  =>  proc returned: 6
```

Testing:
- Ran the example snippet locally with `ruby examples/snippets/blocks_proc_lambda_demo.rb` and confirmed output matches the explanation.

Checklist:
- [x] I have followed the style guide in `docs/style-guide.md`
- [x] I have added matching question and answer files (if applicable)
- [x] My code examples are runnable or clearly explained
- [x] I have not introduced linting errors

---

These examples are intentionally concise; adapt them to your actual issue/PR. When filing a real issue or opening a PR, include the exact file paths, small code snippets, and clear instructions for how a reviewer can validate the change.