# Vendored standards provenance

The checker, schemas, immutable rule definitions, baseline lint configurations,
and npm lockfile in this directory are copied from
`jmattern/common-standards` commit
`1bdfb52e0c72b37c5c2acca5db2e8a87b43f87c5`.

The copied catalog files are `tools/standards.py`, `standards.schema.json`,
`rules/CS-001.json` through `rules/CS-013.json`, `rules/schema.json`, and
`rules/profiles.schema.json`. The copied linter files are `linters/README.md`,
`linters/checkstyle.xml`, `linters/eslint.config.mjs`,
`linters/package.json`, `linters/package-lock.json`, `linters/phpcs.xml`,
`linters/ruff.toml`, `linters/rustfmt.toml`,
`linters/.clang-format`, `linters/.clang-tidy`, `linters/.editorconfig`,
`linters/.golangci.yml`, `linters/.markdownlint-cli2.yaml`,
`linters/.rubocop.yml`, `linters/.shellcheckrc`, `linters/.swiftlint.yml`,
and `linters/.yamllint`. `requirements.txt` is copied from that same commit's
root requirements file, and the top-level `.editorconfig` is copied from its
root `.editorconfig` so active C# and Kotlin profiles have a discoverable config.
The local `rules/profiles.json` is the reviewed project adaptation described
below.

The only local catalog adaptation is `rules/profiles.json`. Its shell profile
adds the repository's extensionless `.vim/download_plugins` and `.vim/update_vim`
scripts alongside the regular Bash files. Profile config paths and commands
point into `.standards/linters/`. The Python profile checks the vendored checker;
other profiles exclude `.standards/**` so copied configs are not mistaken for
consumer source. Every shared language profile remains available for future
source files. Catalog rule definitions and checker behavior are unchanged.

To update the vendor, review one immutable common-standards commit, copy the
listed files together, compare the resulting report, and update this commit pin
and `TOOLCHAINS.md` in the same change.
