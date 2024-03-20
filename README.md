# eForms Mapping Artefacts

To create/update the minimal test package `package_cn_v1.9_minimal` from the
contents in `src` (latest developmental RML rules), simply run `make`, which
resolves to the default (and currently only) Make target `package_minimal`.
Make can be installed on Windows via Chocolatey (`choco install make`).

The package `package_cn_v1.9` is kept for reference with old RML file(s), but
is not expected to be updated while the RML rules are in development. Feel free
to take test data files from this package and dump them in the minimal package
to create a bigger test package with the developmental RML rules.

For collaboration, create branches with a three-fragment scheme
`feature/{internal-ticket-id}/{understandable-short-label}` where
`{internal-ticket-id}` could be a JIRA ticket ID, and
`{understandable-short-label}` representing some meaningful label
understandable among collaborators, such as a deliverable name (e.g. `part1`),
optionally hyphen-suffixed with relevant component/concept names (e.g. `-Lot`
yielding the ending branch segment `part1-Lot`).
