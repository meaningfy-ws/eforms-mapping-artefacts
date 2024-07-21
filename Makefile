MAPPINGS_DIR = mappings
OUTPUT_DIR = dist
DEFAULT_PKG_PREFIX = package_cn
SDK_NAME = eforms-sdk
DEFAULT_SDK_VERSION = 1.9
SDK_DATA_NAME = sdk_examples_cn
SAMPLES_CN_NAME = sampling_20231001-20240311
SAMPLES_RANDOM_NAME = sampling_random
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_|_VehicleInformation_|_ChangeInformation_"
TEST_QUERY_RESULTS_FORMAT = CSV
XLSX_STRDATA = xl/sharedStrings.xml
DEFAULT_CM_ID_PREFIX_CN = package_eforms_10-24
DEFAULT_CM_DESC_PREFIX_CN = Package EF10-EF24
TRIM_DOWN_SHACL = 1
EXCLUDE_INEFFICIENT_VALIDATIONS = 1
INCLUDE_RANDOM_SAMPLES = 1
EXCLUDE_PROBLEM_SAMPLES = 1
INCLUDE_INVALID_EXAMPLES = 0
EXCLUDE_LARGE_EXAMPLE = 1
REPLACE_CM_METADATA_ID = 1
REPLACE_CM_METADATA_ID_EXAMPLES = 0

CANONICAL_TEST_OUTPUT = src/output.ttl
VERSIONED_OUTPUT_DIR = src/output-versioned
CANONICAL_EXAMPLE = cn_24_maximal
CANONICAL_RML_DIR = src/mappings
TEST_DATA_DIR = test_data
TEST_QUERIES_DIR = test_queries
TEST_SCRIPTS_DIR = test_scripts
POST_SCRIPTS_DIR = src/scripts
TX_DIR = transformation
CM_FILENAME = conceptual_mappings.xlsx
SHACL_FILE_EPO = ePO_core_shapes.ttl
SHACL_PATH_EPO = validation/shacl/epo/$(SHACL_FILE_EPO)
RELEASE_DIR = ../ted-rdf-mapping-eforms
# override with make RELEASE_DIR=$your-dir ...

JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq
OWLCLI_DIR = $(shell test ! -z ${OWLCLI_HOME} && echo ${OWLCLI_HOME} || echo `pwd`/owlcli)
OWLCLI_BIN = OWLCLI_DIR/owl-cli.jar
OWLCLI_CMD = java -jar ~/.rmlmapper/owl-cli.jar write --indentSize 4
MULTIVER_SCRIPT = scripts/prep-multiver.sh

BUILD_PRINT = \e[1;34mSTEP: \e[0m
SDK_DATA_DIR = $(TEST_DATA_DIR)/$(SDK_DATA_NAME)
SAMPLES_CN_DIR = $(TEST_DATA_DIR)/$(SAMPLES_CN_NAME)
SAMPLES_RANDOM_DIR = $(TEST_DATA_DIR)/$(SAMPLES_RANDOM_NAME)
CM_FILE = $(TX_DIR)/$(CM_FILENAME)

VERSIONS := $(shell seq 3 10)
# some versions don't currently have systematic and/or random samples
VERSIONS_SAMPLES := $(3 6 7 8 9)

package_sync: $(addprefix package_sync_v, $(VERSIONS))
package_release: $(addprefix package_release_v, $(VERSIONS))
reformat_package_cn: $(addprefix reformat_package_cn_v, $(VERSIONS))
package_cn_minimal: $(addprefix package_cn_minimal_v, $(VERSIONS))
export_cn_minimal: $(addprefix export_cn_minimal_v, $(VERSIONS))
package_cn_examples: $(addprefix package_cn_examples_v, $(VERSIONS))
export_cn_examples: $(addprefix export_cn_examples_v, $(VERSIONS))
package_cn_samples: $(addprefix package_cn_samples_v, $(VERSIONS))
export_cn_samples: $(addprefix export_cn_samples_v, $(VERSIONS))
package_cn_maximal: $(addprefix package_cn_maximal_v, $(VERSIONS))
export_cn_maximal: $(addprefix export_cn_maximal_v, $(VERSIONS))
test_versioned: $(addprefix test_versioned_v, $(VERSIONS))
test_output_versioned: $(addprefix test_output_versioned_v, $(VERSIONS))

package_prep:
	@ echo "Staging versioned folders"
	@ cd src && bash $(MULTIVER_SCRIPT)

# TODO: move src subfolders around to be more compatible w/ packages (mappings -> transformation)
# we are not copying over CM for now -- leaving it under manual control
package_sync_v%: package_prep
	@ echo "Syncing CN v1.$*"
	@ rm -rfv mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/mappings*
	@ cp -rv src/mappings mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/
	@ cp -v src/mappings-1.$*/* mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/mappings/
	@ rm -rfv mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/
	@ rm -rfv mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/validation
	@ cp -rv src/validation mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(SHACL_PATH_EPO)
endif

package_release_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(DEFAULT_PKG_PREFIX)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing CN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/resources ; \
		cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/ ; \
	  fi
#   @ rm -rv $(PKG_DIR)/validation
#	@ cp -rv src/validation $(PKG_DIR)/
# ifeq ($(TRIM_DOWN_SHACL), 1)
# # TODO: is it better to just create and apply a patch?
# 	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
# 	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
# 	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' $(PKG_DIR)/$(SHACL_PATH_EPO)
# 	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' $(PKG_DIR)/$(SHACL_PATH_EPO)
# endif

# FIXME: don't think anyone would use it like this wholesale (but rather more selectively)
reformat_package_cn_v%:
	@ echo "Reformatting RML files for packaging $(DEFAULT_PKG_PREFIX)_v1.$*, with $(OWLCLI_BIN)"
	for i in `find mappings/$(DEFAULT_PKG_PREFIX)_v1.$*/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_cn_minimal_v%:
	@ echo "Preparing minimal CN package, v1.$*"
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_minimal)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(DEFAULT_PKG_PREFIX)_v1.$* $(PKG_DIR)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$*</t>|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$* (minimal data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_minimal_v%:
	@ cd $(OUTPUT_DIR) && zip -r $(DEFAULT_PKG_PREFIX)_v1.$*_minimal.zip $(DEFAULT_PKG_PREFIX)_v1.$*_minimal
	@ echo "Minimal package exported to $(OUTPUT_DIR)/$(DEFAULT_PKG_PREFIX)_v1.$*_minimal.zip"

# we exclude large file *100_lots in this package, but include it in maximal (allData)
package_cn_examples_v%:
	@ echo "Preparing SDK examples CN package, v1.$*"
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_examples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(DEFAULT_PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* example data"
	@ cp -rv $(SDK_DATA_DIR)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME)/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ cp -rv $(SDK_DATA_DIR)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME)_invalid
endif
# TODO: not working, use Bash notation or bring out into separate target
# ifeq ($($*), 9)
# 	@ echo "Including CN OP test data"
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_d2.1 $(PKG_DIR)/test_data
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_gh_issues $(PKG_DIR)/test_data
# endif
ifeq ($(EXCLUDE_LARGE_EXAMPLE), 1)
	@ echo "Removing large file cn_24_maximal_100_lots.xml"
	@ find $(PKG_DIR) -name "cn_24_maximal_100_lots.xml" -exec rm -v {} \;
endif
ifeq ($(REPLACE_METADATA_ID_EXAMPLES), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*_examples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$*</t>|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$* (SDK example data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_examples_v%:
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_examples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "SDK examples package exported to $(OUTPUT_DIR)/$(DEFAULT_PKG_PREFIX)_v1.$*_examples.zip"

package_cn_samples_v%:
	@ echo "Preparing samples CN package, v1.$*"
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_samples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(DEFAULT_PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including EF10-24 systematic sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ test -d $(SAMPLES_CN_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_CN_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \; || echo "No systematic samples for v1.$*"
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including EF10-24 random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)
	@ test -d $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) \; || echo "No random samples for v1.$*"
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic sample notices"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) -name 665610-2023.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_CN_DIR) -name 135016-2024.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_CN_DIR) -name 725041-2023.xml -exec rm -fv {} \;
endif
	@ echo "Removing any SDK examples"
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR)*
ifeq ($(REPLACE_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*_samples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$*</t>|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$* (sample data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif
# TODO: not working in any way for some reason
# @ echo "Cleaning up invalid samples packages (no actual samples)"
# @ [ -z `ls -A $(PKG_DIR)/$(SAMPLES_CN_DIR)` ] && rm -rfv $(PKG_DIR)

export_cn_samples_v%:
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_samples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Samples package exported to $(OUTPUT_DIR)/$(DEFAULT_PKG_PREFIX)_v1.$*_examples.zip"

package_cn_maximal_v%:
	@ echo "Preparing maximal CN package, v1.$*"
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(DEFAULT_PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* example data"
	@ cp -rv $(SDK_DATA_DIR)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME)/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ cp -rv $(SDK_DATA_DIR)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME)_invalid
endif
# TODO: not working, use Bash notation or bring out into separate target
# ifeq ($($*), 9)
# 	@ echo "Including CN OP test data"
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_d2.1 $(PKG_DIR)/test_data
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_gh_issues $(PKG_DIR)/test_data
# endif
	@ echo "Including EF10-24 systematic sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ test -d $(SAMPLES_CN_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_CN_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \; || echo "No systematic samples for v1.$*"
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including EF10-24 random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)
	@ test -d $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) \; || echo "No random samples for v1.$*"
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic sample notices"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) -name 665610-2023.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_CN_DIR) -name 135016-2024.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_CN_DIR) -name 725041-2023.xml -exec rm -fv {} \;
endif
ifeq ($(REPLACE_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(DEFAULT_CM_ID_PREFIX_CN)_v1.$*_maximal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$*</t>|<t>$(DEFAULT_CM_DESC_PREFIX_CN), SDK v1.$* (all data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_maximal_v%:
	@ $(eval PKG_NAME := $(DEFAULT_PKG_PREFIX)_v1.$*_allData)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Maximal package exported to $(OUTPUT_DIR)/$(DEFAULT_PKG_PREFIX)_v1.$*_examples.zip"

package_cn_all_variants: package_cn_minimal package_cn_examples package_cn_samples package_cn_maximal

export_cn_all_variants: export_cn_minimal export_cn_examples export_cn_samples export_cn_maximal

setup-jena-tools:
	@ echo "Installing Apache Jena CLI tools locally"
	@ curl "https://archive.apache.org/dist/jena/binaries/apache-jena-4.10.0.zip" -o jena.zip
	@ unzip jena.zip
	@ mv apache-jena-4.10.0 jena
	@ echo "Done installing Jena tools, accessible at $(JENA_TOOLS_DIR)/bin"

setup-owl-cli:
	@ echo "Installing OWL CLI tool locally"
	@ mkdir -p owlcli
	@ curl -L "https://github.com/atextor/owl-cli/releases/download/snapshot/owl-cli-snapshot.jar" -o owlcli/owl-cli.jar
	@ echo "Done installing OWL CLI tool, accessible at $(OWLCLI_DIR)/owl-cli.jar"

test:
	@ echo "Using $(JENA_TOOLS_RIOT)"
	@ echo "Validating RML files"
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_RML_DIR)/*
	@ test -d $(CANONICAL_RML_DIR)-versioned && $(JENA_TOOLS_RIOT) --validate $(CANONICAL_RML_DIR)-versioned/* || echo "No versioned dir"
	@ echo -n "Validating reference test output.."
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_TEST_OUTPUT)
	@ echo "done"

test_versioned_v%: test
# @ echo "Using $(JENA_TOOLS_RIOT)"
	@ echo -n "Validating example test output, v1.$*.."
	@ $(JENA_TOOLS_RIOT) --validate $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl
	@ echo "done"

test_output:
	@ echo "Testing output w/ $(JENA_TOOLS_ARQ) in $(TEST_QUERY_RESULTS_FORMAT) format"
	@ echo "==> Test output orphans"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_orphans.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)
	@ echo
	@ echo "==> Test output runts"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_runts.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output mixed types"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_mixed_types.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output malformed dateTime"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_malformed_dateTime.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output untyped date or time"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_untyped_dateOrTime.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output overloaded rels"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_overloaded_rels.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output suspect iri name"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_suspect_iri_name.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output dupe identifiers"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_dupe_identifiers.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output missing playedBy"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "Testing mapping rules coverage against output"
	@ echo "==> Test RML predicate mapping coverage"
	@ $(TEST_SCRIPTS_DIR)/test_predicate_coverage.sh $(CANONICAL_RML_DIR) $(CANONICAL_TEST_OUTPUT)
	@ echo
	@ echo "==> Test RML subject reference coverage"
	@ $(TEST_SCRIPTS_DIR)/test_reference_coverage.sh $(CANONICAL_RML_DIR) $(CANONICAL_TEST_OUTPUT)
	@ echo
	@ echo "==> Test RML subject template coverage"
	@ $(TEST_SCRIPTS_DIR)/test_template_coverage.sh $(CANONICAL_RML_DIR) $(CANONICAL_TEST_OUTPUT)
	@ echo

test_output_versioned_v%:
	@ echo "==> Test example output, v1.$*"
	@ echo "-> Test output orphans, v1.$*"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_orphans.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)
	@ echo
	@ echo "-> Test output runts, v1.$*"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_runts.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
# @ echo "-> Test output mixed types, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_mixed_types.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output malformed dateTime, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_malformed_dateTime.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output untyped date or time, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_untyped_dateOrTime.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output overloaded rels, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_overloaded_rels.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output suspect iri name, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_suspect_iri_name.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output dupe identifiers, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_dupe_identifiers.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo
# @ echo "-> Test output missing playedBy, v1.$*"
# @ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
# @ echo

test_output_postproc:
	@ echo "Testing output post-processing scripts"
	@ echo "==> Test link role playedBy"
	@ $(POST_SCRIPTS_DIR)/link_role_playedBy.sh
	@ echo
	@ echo "==> Test output missing playedBy"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CANONICAL_TEST_OUTPUT) --data output/source/link_role_playedBy.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)

clean:
	@ rm -fv jena.zip
	@ rm -rfv dist
	@ rm -rfv tmp
	@ rm -rfv src/mappings-1*

install-node:
	@ echo -e "$(BUILD_PRINT)Installing the NodeJS$(END_BUILD_PRINT)"
	@ sudo apt install npm
	@ mkdir -p ~/.npm
	@ npm config set prefix ~/.npm
	@ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
	@ nvm list-remote
	@ nvm install lts/gallium
	@ source ~/.bashrc

install-antora:
	@ echo -e "$(BUILD_PRINT)Installing the Antora$(END_BUILD_PRINT)"
	@ npm install

build-site:
	@ echo -e "$(BUILD_PRINT)Build site$(END_BUILD_PRINT)"
	@ npx antora --fetch antora-playbook.yml
