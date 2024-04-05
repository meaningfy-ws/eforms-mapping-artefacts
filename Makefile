BUILD_PRINT = \e[1;34mSTEP: \e[0m
MINIMAL_PACKAGE = package_cn_v1.9_minimal
JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq
CANONICAL_TEST_OUTPUT = src/output.ttl
CANONICAL_RML_DIR = src/mappings
TEST_QUERIES_DIR = test_queries
TEST_QUERY_ORPHANS = $(TEST_QUERIES_DIR)/test_orphans.rq
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_"
TEST_QUERY_RESULTS_FORMAT = CSV

package_minimal:
	@ cp -rv src/mappings mappings/$(MINIMAL_PACKAGE)/transformation/
	@ cp -rv src/transformation mappings/$(MINIMAL_PACKAGE)/

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

test_output_orphans:
	@ echo "Validating test output orphans w/ $(JENA_TOOLS_ARQ) in $(TEST_QUERY_RESULTS_FORMAT) format"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERY_ORPHANS) --data $(CANONICAL_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)

clean:
	@ rm -v jena.zip
