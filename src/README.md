# Source RML Rules and Reference Transformation Artefacts

This folder contains the source RML rules that will be used in different
mapping packages/suites. It also contains files and other folders necessary to
test the RML rules directly with RMLMapper, with a structure that is _slightly
incompatible_ with packages:

- `data/` Data folder with SDK examples and a reference sample file `source.xml`
- `mappings/` The source RML files (modules) that can be packaged or tested
- `mappings-versioned/` Version-specific RML files including versioned RML rules
- `output.ttl` The reference test output generated from `data/source.xml`
- `output-versioned/` Test output of versioned SDK examples and reference sample
- `transformation/` Conceptual mapping file and external vocabularies in `resources`
- `scripts` Helper scripts for development

In packages, the `mappings/` folder would be found under `transformation`
alongside the conceptual mapping (CM) XLSX file `conceptual_mapping.xlsx`, and
there would be a `test_data/` folder instead of `data/` with data files, _none
of which_ would be named `source.xml`. The output and version-specific folders
would also not exist, as packages would be organized per version with the right
RML files.

A specific version is assumed for transformation with RMLMapper, and therefore
we expect two input parameters for the `-m` argument -- the first for the
"common" or general mappings, and the second for the version-specific ones. The
full command to run with Java in that case is as follows:

```sh
java -jar /path/to/rmlmapper.jar -m mappings/* mappings-$ver/* -s Turtle > output.ttl
```

Where `$ver` is a version number of the form `MAJOR.MINOR`, e.g.
`mappings-1.9`, containing version-specific mappings reproduced from the
`mappings-versioned` folder. A helper script `prep-multiver.sh` is provided in
`scripts` to distribute the proper version-ranged files into the temporary
versioned folders.

Two scripts, `tx_example-multiver.sh` and `tx_reference-multiver.sh`, are
provided to run batch transformations for all of the SDK (versioned) examples,
and the reference sample for all versions (to track the impact of versioned
rules upon just one representative version). The reference sample is based on a
specific version of a specific example, `cn_24_maximal.xml` from eForms SDK
v1.9, but with modifications to yield more coverage.

> Note: Scripts may expect RMLMapper to be aliased or the path to it be
> modified within the script. Please check the code of any script with a glance
> before running it.

The current RML rules require and are tested for RMLMapper versions 6.2.2 and
6.3.0 with Java 11. Later versions require Java 17 and may work, but are
untested. Earlier versions will _not_ work due to RML funtion namespace
differences (currently used in _languageMaps_).

The structure of the RML files (we call them _modules_ because they are modular
files with RML rules that work together when combined) is based on the
primary/root class of a set of mapping rules, which are part of one or more
_Mapping Groups_ (MGs) that share such a root class (the final segment of an MG
name). An MG represents a logical grouping of related instances/resources (like
a `foaf:Person` with all of its properties _and_ relationships together with
the instances of those relationships).

## Replacing `rr:template` with `rml:reference` for conditional subject creation
```

rr:template "
rml:reference "if (exists(REL_XPATH_1) or exists(REL_XPATH_2)) then '

{
' || 

}
 || '


{
' || 

}"
 else null"
```
