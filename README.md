# Product Feed Batcher (Ruby 2.x)

Parses a Google Merchant-style RSS feed, extracts `id`, `title`, and `description`, and sends products in JSON batches **strictly smaller than 5 MB**.

## Why this approach?

- **Streaming parser**: uses `Nokogiri::XML::Reader` to process `<item>` one by one without loading the whole file.
- **Namespace-aware**: reads `g:id` from `http://base.google.com/ns/1.0`.
- **Fast batch sizing**: computes JSON size incrementally (no O(n²) re-serializations).
- **Small modules**: simple classes with clear responsibilities.

## Requirements

- Ruby 2.x
- Bundler

## Setup

```bash
bundle install
ruby assignment.rb
```