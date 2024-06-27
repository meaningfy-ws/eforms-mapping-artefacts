MAPPINGS_DIR = mappings
OUTPUT_DIR = output
DEFAULT_PACKAGE = package_cn_v1.9
MINIMAL_PACKAGE = $(DEFAULT_PACKAGE)_minimal
SDK_NAME = eforms-sdk
DEFAULT_SDK_VERSION = 1.9
SDK_DATA_NAME = sdk_examples_cn
SAMPLES_CN_NAME = sampling_20231001-20240311
SAMPLES_RANDOM_NAME = sampling_random
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_|_VehicleInformation_|_ChangeInformation_"
TEST_QUERY_RESULTS_FORMAT = CSV
XLSX_STRDATA = xl/sharedStrings.xml
DEFAULT_CM_ID = package_eforms_10-24_v1.9
TRIM_DOWN_SHACL = 1
EXCLUDE_INEFFICIENT_VALIDATIONS = 1
INCLUDE_RANDOM_SAMPLES = 1
EXCLUDE_PROBLEM_SAMPLES = 1

CANONICAL_TEST_OUTPUT = src/output.ttl
CANONICAL_RML_DIR = src/mappings
TEST_DATA_DIR = test_data
TEST_QUERIES_DIR = test_queries
TEST_SCRIPTS_DIR = test_scripts
POST_SCRIPTS_DIR = src/scripts
TX_DIR = transformation
CM_FILENAME = conceptual_mappings.xlsx
SHACL_FILE_EPO = ePO_core_shapes.ttl
SHACL_PATH_EPO = validation/shacl/epo/$(SHACL_FILE_EPO)

JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq
OWLCLI_DIR = $(shell test ! -z ${OWLCLI_HOME} && echo ${OWLCLI_HOME} || echo `pwd`/owlcli)
OWLCLI_BIN = OWLCLI_DIR/owl-cli.jar
OWLCLI_CMD = java -jar ~/.rmlmapper/owl-cli.jar write --indentSize 4

BUILD_PRINT = \e[1;34mSTEP: \e[0m
SDK_DATA_DIR = $(TEST_DATA_DIR)/$(SDK_DATA_NAME)
SAMPLES_CN_DIR = $(TEST_DATA_DIR)/$(SAMPLES_CN_NAME)
SAMPLES_RANDOM_DIR = $(TEST_DATA_DIR)/$(SAMPLES_RANDOM_NAME)
CM_FILE = $(TX_DIR)/$(CM_FILENAME)

package_sync:
	@ cp -rv src/mappings mappings/$(MINIMAL_PACKAGE)/$(TX_DIR)/
	@ cp -rv src/$(TX_DIR) mappings/$(MINIMAL_PACKAGE)/
	@ cp -rv src/validation mappings/$(MINIMAL_PACKAGE)/
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' mappings/$(MINIMAL_PACKAGE)/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' mappings/$(MINIMAL_PACKAGE)/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' mappings/$(MINIMAL_PACKAGE)/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' mappings/$(MINIMAL_PACKAGE)/$(SHACL_PATH_EPO)
endif

reformat_package_cn:
	@ echo "Reformatting RML files for packaging $(MINIMAL_PACKAGE), with $(OWLCLI_BIN)"
	for i in `find mappings/$(MINIMAL_PACKAGE)/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_cn_minimal: package_sync
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(MINIMAL_PACKAGE))
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_minimal:
	@ cd $(OUTPUT_DIR) && zip -r $(MINIMAL_PACKAGE).zip $(MINIMAL_PACKAGE)
	@ echo "Minimal package exported to $(OUTPUT_DIR)/$(MINIMAL_PACKAGE).zip"

package_cn_examples: package_sync
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allExamples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including CN SDK example data"
	@ cp -rv $(SDK_DATA_DIR) $(PKG_DIR)/test_data
	@ cp -rv $(SDK_DATA_DIR)_invalid $(PKG_DIR)/test_data
	@ echo "Including CN OP test data"
	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_d2.1 $(PKG_DIR)/test_data
	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_gh_issues $(PKG_DIR)/test_data
	@ echo "Removing large file cn_24_maximal_100_lots.xml"
	@ find $(PKG_DIR) -name "cn_24_maximal_100_lots.xml" -exec rm -v {} \;
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)_allExamples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_examples:
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allExamples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "SDK examples package exported to $(PKG_DIR).zip"

package_cn_samples: package_sync
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allSamples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ find $(SAMPLES_CN_DIR)/$(SDK_NAME)-$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \;
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)
	@ find $(SAMPLES_RANDOM_DIR)/eforms_sdk_v$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) \;
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic random sample notice 665610-2023"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) -name 665610-2023.xml -exec rm -fv {} \;
endif
	@ echo "Removing any SDK examples"
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)_allSamples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_samples:
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allSamples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Samples package exported to $(PKG_DIR).zip"

package_cn_maximal: package_sync
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including CN SDK example data"
	@ cp -rv $(SDK_DATA_DIR) $(PKG_DIR)/test_data
	@ cp -rv $(SDK_DATA_DIR)_invalid $(PKG_DIR)/test_data
	@ echo "Including CN OP test data"
	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_d2.1 $(PKG_DIR)/test_data
	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_gh_issues $(PKG_DIR)/test_data
	@ echo "Including EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ find $(SAMPLES_CN_DIR)/$(SDK_NAME)-$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \;
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)
	@ find $(SAMPLES_RANDOM_DIR)/eforms_sdk_v$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) \;
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic random sample notice 665610-2023"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR) -name 665610-2023.xml -exec rm -fv {} \;
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_maximal:
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allData)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Maximal package exported to $(PKG_DIR).zip"

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
	@ echo -n "Validating test output.."
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_TEST_OUTPUT)
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

test_output_postproc:
	@ echo "Testing output post-processing scripts"
	@ echo "==> Test link role playedBy"
	@ $(POST_SCRIPTS_DIR)/link_role_playedBy.sh
	@ echo
	@ echo "==> Test output missing playedBy"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CANONICAL_TEST_OUTPUT) --data output/source/link_role_playedBy.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)

clean:
	@ rm -fv jena.zip
	@ rm -rfv output
	@ rm -rfv tmp
