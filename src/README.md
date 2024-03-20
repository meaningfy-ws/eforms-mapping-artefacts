# Source RML Rules and Reference Transformation Artefacts

This folder contains the source RML rules that will be used in different
mapping packages/suites. It also contains files and other folders necessary to
test the RML rules directly with RMLMapper, with a structure that is _not_
compatible with packages.

- `data/` Data folder with a `source.xml` file for direct RMLMapper testing
- `mappings/` The source RML files (modules) that can be packaged or tested
- `output.ttl` The test output generated from direct RMLMapper testing
- `transformation/` Secondary data such as vocabularies in `resources`

In packages, the `mappings/` folder would be found under `transformation`
alongside a conceptual mapping (CM), and there would be a `test_data/` folder
instead of `data/` with numerous data files, not `source.xml`.

A master CM file with the same name as the CMs in individual packages
`conceptual_mapping.xlsx` may also be tracked under `transformation/` here.

Run with:

```sh
java -jar /path/to/rmlmapper.jar -m mappings/* -s Turtle > output.ttl
```

The current RML rules require and are tested for RMLMapper versions 6.2.2 and
6.3.0 with Java 11. Later versions require Java 17 and may work, but are
untested. Earlier versions will _not_ work due to RML funtion namespace
differences (currently used in _languageMaps_).
