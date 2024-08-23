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
- [Node.js](https://nodejs.org/en/download/package-manager) for generating documentation

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

## eForms SDK Change Analysis

There is support for some automated, quantitative analyses through some tools
in `analysis_scripts`, namely for extracting [eForms
SDK](https://github.com/OP-TED/eForms-SDK) changes across versions, given a
locally available Git copy of the project (override with `$SDK_DIR`).

Run `eforms_field_vercmp.sh` or `eforms_node_vercmp.sh` to quickly analyse an
eForm field or node against a min, max and reference version, including whether
and how _absolute XPath_ differs ([Levenshtein-based similarity score](https://github.com/seatgeek/thefuzz?tab=readme-ov-file#simple-ratio)).

```
$ bash analysis_scripts/eforms_node_vercmp.sh ND-ServiceProviderParty 1.3 1.10
==> Diff of earliest min 1.3 (1.3.0) vs. reference 1.9.1

--- /dev/fd/63  2024-08-01 09:59:10.627734937 +0100
+++ /dev/fd/62  2024-08-01 09:59:10.627734937 +0100
@@ -3,5 +3,10 @@
   "parentId": "ND-ServiceProvider",
   "xpathAbsolute": "/*/cac:ContractingParty/cac:Party/cac:ServiceProviderParty",
   "xpathRelative": "cac:ServiceProviderParty",
+  "xsdSequenceOrder": [
+    {
+      "cac:ServiceProviderParty": 18
+    }
+  ],
   "repeatable": true
 }

No Abs XPath changes in v1.3-1.9
Saved to /home/user/work/eforms-mapping-artefacts/ref/eForms-SDK/diffs/ND-ServiceProviderParty_v1.3-1.9.diff

==> Diff of latest max 1.10 (1.10.2) vs. reference 1.9.1

--- /dev/fd/63  2024-08-01 09:59:10.647734938 +0100
+++ /dev/fd/62  2024-08-01 09:59:10.647734938 +0100
@@ -1,6 +1,6 @@
 {
   "id": "ND-ServiceProviderParty",
-  "parentId": "ND-Buyer",
+  "parentId": "ND-ServiceProvider",
   "xpathAbsolute": "/*/cac:ContractingParty/cac:Party/cac:ServiceProviderParty",
   "xpathRelative": "cac:ServiceProviderParty",
   "xsdSequenceOrder": [

No Abs XPath changes v1.10-1.9
Saved to /home/user/work/eforms-mapping-artefacts/ref/eForms-SDK/diffs/ND-ServiceProviderParty_v1.10-1.9.diff

==> Diff of earliest min 1.3 (1.3.0) vs. latest max 1.10 (1.10.2)

--- /dev/fd/63  2024-08-01 01:59:10.657734939 +0600
+++ /dev/fd/62  2024-08-01 01:59:10.657734939 +0600
@@ -1,7 +1,12 @@
 {
   "id": "ND-ServiceProviderParty",
-  "parentId": "ND-ServiceProvider",
+  "parentId": "ND-Buyer",
   "xpathAbsolute": "/*/cac:ContractingParty/cac:Party/cac:ServiceProviderParty",
   "xpathRelative": "cac:ServiceProviderParty",
+  "xsdSequenceOrder": [
+    {
+      "cac:ServiceProviderParty": 18
+    }
+  ],
   "repeatable": true
 }

No Abs XPath changes in v1.3-1.10
Saved to /home/user/work/eforms-mapping-artefacts/ref/eForms-SDK/diffs/ND-ServiceProviderParty_v1.3-1.10.diff
```

Running `analyse_versions.sh` on a conceptual mapping (CM) Excel (XLSX) file
with versioned mappings will generate such diffs across version ranges under
`ref`. This can then be followed up with `make get_xpath_similarity_stats` to
produce some statistics on XPath similarity scores across versions.

```
$ bash analysis_scripts/analyse_versions.sh mappings/package_cn_v1.3/transformation/conceptual_mappings.xlsx
...
$ make get_xpath_similarity_stats

Frequency of Abs XPath similarity scores (no. of field-version range comparisons, score):

     18 92
     14 96
      8 91
      6 90
      6 89
      5 93
      4 77
      4 68
      3 95
      3 87
      2 85
      2 80
      2 76

Min: 68
Max: 96
Avg: 89.28571428571429
Med: 92
```

Analyse XPath similarities for all versioned mappings grouped by score, with
the added and removed XPath context, using `make get_xpath_similarity_grouped`.
View a unique list of fields/nodes via `make get_xpath_similarity_table`, the
output of which can be directly put into a spreadsheet.

As (absolute) XPaths are the key identity of XML data, based upon which the SDK
is designed, these numbers can be used to inform which mappings need to be
carefully considered for _versioned implementation_ under
`src/mappings-versioned`.
