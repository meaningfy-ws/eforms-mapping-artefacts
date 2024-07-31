# eForms Mapping Artefacts

To update (synchronize) all tracked packages in toplevel `mappings` against the
latest developmental RML rules in `src`, simply run `make`, which resolves to
the default (first) Make target `package_sync`.

These packages, or "mapping suites", are _minimal_ in nature, meaning they
contain very little (currently just one) test data. They serve as reference to
the package _variants_ that can be generated from `src`.

The contents in `src` are laid out in a way that is conducive to local
development, which packages are not. However, varying amounts of data can be
combined to generate new packages. Helper Make commands are provided for this:

```
make package_cn_all_variants
make export_cn_all_variants
```

These will output complete packages in a `dist` folder, along with their ZIP
archive files, suitable for loading into mapping tools such as [Mapping
Workbench (MWB)](https://meaningfy.ws/mapping-workbench). Currently, they are
based around the following variants:

- **minimal** One SDK example only, e.g. `cn_24_maximal.xml`
- **examples** All SDK examples, _except_ any `*100_lots.xml` or similar large data
- **samples** All systematic, manual and random sample data, no SDK example
- **maximal** All SDK examples and all sample data, _including_ any large data

You are free to modify any package and rerun the relevant export Make target,
e.g. `make export_cn_minimal`.

## Testing

There are semi-automated _local_ tests which are mainly for _checking_ sanity
of the reference output(s) for (mostly) qualitative analysis, executed with
`make test_output` (uses Apache Jena `arq` to run some queries).

There is automated validation of RDF files via running `make test`, which uses
Jena's `riot` tool. This is also integrated into the main (GitHub Actions)
Continuous Integration (CI) workflow.

## Requirements

Users need only to install the following external software tools, libraries
and/or runtimes if developing and testing the RML mapping:

- [Java](https://www.oracle.com/java/technologies/downloads/) 11+ (tested up to 17)
- [RMLMapper-Java==v6.2.2](https://github.com/RMLio/rmlmapper-java/releases/tag/v6.2.2)
- A UNIX-compatible environment w/ `make`, `curl`, `zip`, etc. (for packaging)
- [Apache Jena 4.10](https://jena.apache.org/download/index.cgi#previous-releases) (for testing using the [command-line tools](https://jena.apache.org/documentation/tools/index.html) `arq` and `riot`)
- [Python](https://www.python.org/downloads/) and `jq` for running some other (namely analysis) tools/scripts/targets

Make, cURL, ZIP, JQ and other UNIX/Bash tools may be accessible on Windows via
[Chocolatey](https://chocolatey.org/install), and on Mac via [HomeBrew](https://brew.sh/). Python and Java should be installed from their respective official sources, but [pyenv](https://github.com/pyenv/pyenv)[(-win)](https://github.com/pyenv-win/pyenv-win)
and [SDKMAN!](https://sdkman.io/usage) are good options as well.

RMLMapper is currently tied to v6.2.2 because of an [issue with conditional
instantiation](https://github.com/RMLio/rmlmapper-java/issues/236) (currently
fixed but yet unreleased).

## RDF URI Scheme

The eForms RML mappings use the URI scheme `{ns}id_{notice-id}_{concept}_{trailer}`, where:

- `{ns}` is a base namespace, in this case `http://data.europa.eu/a4g/resource/`
- `{concept}` is either (i) an ontology fragment label or (ii) source element label, with a suffix or prefix
- `{trailer}` is either (i) an ID value (if the resource has one) or (ii) an _online_ computed, deterministic hash
- Root concepts such as `epo:Notice` end up to only the `{concept}`

Expanding on some of the components for further clarity:

- Whether a `concept` is an ontology fragment or source element label, and whether this label has a suffix (rarely) or prefix, depends on the subjective (human) evaluation of whether only having the class name is sufficient hint of what the URI represents.
- The trailer, when a hash, is computed (seeded) with the XPath named element (e.g. `cbc:ID`) or (often relative) path (e.g. `path(cbc:ID)`) of what is being mapped, and therefore lends a unique identity to the URI. This yields reproducible URIs across RML TripleMaps, in case a resource needed to be instantiated at different XPaths, for whatever purpose.
  - A Lot or any other resource with an inherent ID, would simply have its `cbc:ID` value as the trailer, for e.g. `epd:id_14549263-b47b-4e59-96a1-2d0d13e19343_Lot_LOT-0001`, which is very useful for linking purposes at orthogonal XPaths (e.g. wherever an `id-ref` is concerned, that ID could simply be used to produce a linkable URI without having to navigate XPaths).
  - Any other resource where there is no inherent ID would have a hash that is unique to the XPath it represents, e.g. an `epo:Purpose` instance, if instantiated at different XPaths for associating different attributes, would have the same URI across those instantiations, resulting in one unique instance and no duplication due to multiple mappings.
    - The `adms:Identifier`, although having an ID, may still get a hash instead of ID in its trailer, as it may not have a short ID that is sensible to use/read (however we may not have enforced this rule strongly)

Note: Wherever _URI_ is mentioned, [IRI](https://www.w3.org/2001/Talks/0912-IUC-IRI/paper.html#:~:text=In%20principle%2C%20the%20definition%20of,us%2Dascii%20characters%20in%20URIs) is meant. Also, the generation of hashes is done _online_ against a remote HTTP web API endpoint offering this function, during transformation (which can otherwise be an offline process).

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
