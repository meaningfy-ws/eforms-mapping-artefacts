# eForms Mapping Artefacts

To create/update the minimal test package `package_cn_v1.9_minimal` from the
contents in `src` (latest developmental RML rules), simply run `make`, which
resolves to the default (first) Make target `package_minimal`.

The package `package_cn_v1.9` is kept for reference with old RML file(s), but
will be updated with the RML rules in development. In the meantime, feel free
to create derived packages with more or less data. Some helper Make commands
are provided for this:

```
make package_sdk_examples # all example data of SDK v1.9
make package_cn_samples # all sample data for SDK v1.9
```

These will output temporary packages in an `output` folder.

## Testing

There are semi-automated tests which are mainly for _checking_ and
investigating, run with `make test_output` (uses Apache Jena `arq` to run some
queries). Otherwise, there is GitHub Actions CI integration for validating RDF
files using Jena's `riot` tool.

## Requirements

Users need only to install the following external software tools, libraries
and/or runtimes if developing and testing the RML mapping:

- Java 11
- RMLMapper-Java==v6.2.2
- A UNIX-compatible environment w/ `make`, `curl`, etc.
- Apache Jena 4.10 (for the command-line tools `arq` and `riot`)

Make, cURL and other UNIX/Bash tools may be accessible on Windows via
Chocolatey (e.g. `choco install make`).

## Development Workflow

For collaboration, create branches with a three-fragment scheme
`feature/{internal-ticket-id}/{understandable-short-label}` where
`{internal-ticket-id}` could be a JIRA ticket ID, and
`{understandable-short-label}` representing some meaningful label
understandable among collaborators, such as a deliverable name (e.g. `part1`),
optionally hyphen-suffixed with relevant component/concept names (e.g. `-Lot`
yielding the ending branch segment `part1-Lot`).

Please note that feature branches are bound to change often and therefore
collaborators (on the same branch) may need to run `git reset --hard
origin/{feature-branch-name}` instead of `git pull`, OR, _always_ use `git pull
--rebase` to ensure local changes come on top (and to check whether or not the
local changes conflict).

Otherwise, feature branches should also always merge in _main_ (or whatever the
parent is) whenever possible so as to reduce surprises (avoid rebases against
parents as that can cause frustration not worth the clean history pursuit).
