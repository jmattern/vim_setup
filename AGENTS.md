# Contributor guidance

- Keep editor, shell, and installation behavior compatible with the documented
  setup flow.
- Run `bash scripts/check_setup.sh` for installation and editor behavior checks.
- Run the standards check with `python3 .standards/tools/standards.py --repo .`;
  install pinned dependencies from `requirements.txt` and
  `.standards/linters/package-lock.json` first.
- Keep the vendored catalog and checker tied to the immutable commit recorded in
  `TOOLCHAINS.md`. Review local profile changes in
  `.standards/rules/profiles.json` and update `.standards/VENDORED_FROM.md` when
  changing the vendor revision.
