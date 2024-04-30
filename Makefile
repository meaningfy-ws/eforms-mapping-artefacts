MAPPINGS_DIR = mappings
OUTPUT_DIR = output
DEFAULT_PACKAGE = package_cn_v1.9
MINIMAL_PACKAGE = $(DEFAULT_PACKAGE)_minimal
SDK_NAME = eforms-sdk
DEFAULT_SDK_VERSION = 1.9
SDK_DATA_NAME = sdk_examples_cn
SAMPLES_CN_NAME = sampling_20231001-20240311
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_"
TEST_QUERY_RESULTS_FORMAT = CSV
XLSX_STRDATA = xl/sharedStrings.xml
DEFAULT_CM_ID = package_eforms_10-24_v1.9

CANONICAL_TEST_OUTPUT = src/output.ttl
CANONICAL_RML_DIR = src/mappings
TEST_DATA_DIR = test_data
TEST_QUERIES_DIR = test_queries
TX_DIR = transformation
CM_FILENAME = conceptual_mappings.xlsx

JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq

BUILD_PRINT = \e[1;34mSTEP: \e[0m
SDK_DATA_DIR = $(TEST_DATA_DIR)/$(SDK_DATA_NAME)
SAMPLES_CN_DIR = $(TEST_DATA_DIR)/$(SAMPLES_CN_NAME)
CM_FILE = $(TX_DIR)/$(CM_FILENAME)

package_minimal:
	@ cp -rv src/mappings mappings/$(MINIMAL_PACKAGE)/$(TX_DIR)/
	@ cp -rv src/$(TX_DIR) mappings/$(MINIMAL_PACKAGE)/
	@ cp -rv src/validation mappings/$(MINIMAL_PACKAGE)/

package_sdk_examples: package_minimal
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allExamples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including SDK example data"
	@ cp -rv $(SDK_DATA_DIR) $(PKG_DIR)/test_data
	@ echo "Removing large file cn_24_maximal_100_lots.xml"
	@ find $(PKG_DIR) -name "cn_24_maximal_100_lots.xml" -exec rm -v {} \;
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)-allExamples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -v $(PKG_DIR)/metadata.json

package_cn_samples: package_minimal
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allSamples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ find $(SAMPLES_CN_DIR)/$(SDK_NAME)-$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \;
	@ echo "Removing any SDK examples"
	@ rm -rv $(PKG_DIR)/$(SDK_DATA_DIR)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)-allSamples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -v $(PKG_DIR)/metadata.json

package_cn_maximal: package_minimal
	@ mkdir -p $(OUTPUT_DIR)
	@ $(eval PKG_NAME := $(DEFAULT_PACKAGE)_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ cp -rv mappings/$(MINIMAL_PACKAGE) $(PKG_DIR)
	@ echo "Including SDK example data"
	@ cp -rv $(SDK_DATA_DIR) $(PKG_DIR)/test_data
	@ echo "Including EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_CN_DIR)
	@ find $(SAMPLES_CN_DIR)/$(SDK_NAME)-$(DEFAULT_SDK_VERSION)/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_CN_DIR) \;
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(DEFAULT_CM_ID)</t>|<t>$(DEFAULT_CM_ID)-allData</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
	@ echo "Removing outdated metadata"
	@ rm -v $(PKG_DIR)/metadata.json

setup-jena-tools:
	@ echo "Installing Apache Jena CLI tools locally"
	@ curl "https://archive.apache.org/dist/jena/binaries/apache-jena-4.10.0.zip" -o jena.zip
	@ unzip jena.zip
	@ mv apache-jena-4.10.0 jena
	@ echo "Done installing Jena tools, accessible at $(JENA_TOOLS_DIR)/bin"

test:
	@ echo "Validating RML files"
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_RML_DIR)/*
	@ echo "Validating test output w/ $(JENA_TOOLS_RIOT)"
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_TEST_OUTPUT)

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

clean:
	@ rm -fv jena.zip
	@ rm -rfv output
	@ rm -rfv tmp
