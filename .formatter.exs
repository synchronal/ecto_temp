[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "guides/*.md",
    "*.md"
  ],
  line_length: 120,
  locals_without_parens: [
    deftemptable: :*,
    column: :*
  ],
  markdown: [line_length: 100],
  plugins: [MarkdownFormatter]
]
