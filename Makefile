BUILD_PRINT = \e[1;34mSTEP: \e[0m
MINIMAL_PACKAGE = package_cn_v1.9_minimal
JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq
CANONICAL_TEST_OUTPUT = src/output.ttl
CANONICAL_RML_DIR = src/mappings
TEST_QUERIES_DIR = test_queries
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
	@ rm -v jena.zip
