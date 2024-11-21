test:
	@ echo "Using $(JENA_TOOLS_RIOT)"
	@ echo "Validating RML files"
	@ $(JENA_TOOLS_RIOT) --validate $(CN_RML_DIR)/*
	@ $(JENA_TOOLS_RIOT) --validate $(CAN_RML_DIR)/*
	@ test -d $(CN_RML_DIR)-versioned && $(JENA_TOOLS_RIOT) --validate $(CN_RML_DIR)-versioned/* || echo "No versioned dir"
	@ echo -n "Validating reference test outputs.."
	@ $(JENA_TOOLS_RIOT) --validate $(CN_TEST_OUTPUT)
	@ $(JENA_TOOLS_RIOT) --validate $(CAN_TEST_OUTPUT)
	@ $(JENA_TOOLS_RIOT) --validate $(CANONLY_TEST_OUTPUT)
	@ echo "done"

test_versioned_v%: test
# @ echo "Using $(JENA_TOOLS_RIOT)"
	@ echo -n "Validating example test output, v1.$*.."
	@ $(JENA_TOOLS_RIOT) --validate $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl
	@ echo "done"

test_output:
	@ echo "Testing output w/ $(JENA_TOOLS_ARQ) in $(TEST_QUERY_RESULTS_FORMAT) format"
	@ echo "==> Test output orphans"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(VALIDATION_DIR_SPARQL_RDF)/orphans_exist.select.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(VALIDATION_DIR_SPARQL_RDF)/orphans_exist.select.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)
	@ echo
	@ echo "==> Test output runts"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_runts.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_runts.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output mixed types"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_mixed_types.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_mixed_types.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output malformed dateTime"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_malformed_dateTime.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_malformed_dateTime.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output untyped date or time"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_untyped_dateOrTime.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_untyped_dateOrTime.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output overloaded rels"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_overloaded_rels.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_overloaded_rels.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output suspect iri name"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_suspect_iri_name.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_suspect_iri_name.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output dupe identifiers"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_dupe_identifiers.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_dupe_identifiers.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "==> Test output missing playedBy"
	@ echo "-> CN (EF10-24)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
	@ echo "-> CAN (EF29)"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CAN_TEST_OUTPUT) --results=$(TEST_QUERY_RESULTS_FORMAT)
	@ echo
# TODO think about how to do this for CN, CAN together and separately both
	@ echo "Testing mapping rules coverage against CN output"
	@ echo "==> Test RML predicate mapping coverage CN"
	@ $(TEST_SCRIPTS_DIR)/test_predicate_coverage.sh $(CN_RML_DIR) $(CN_TEST_OUTPUT)
	@ echo
	@ echo "==> Test RML subject reference coverage CN"
	@ $(TEST_SCRIPTS_DIR)/test_reference_coverage.sh $(CN_RML_DIR) $(CN_TEST_OUTPUT)
	@ echo
	@ echo "==> Test RML subject template coverage CN"
	@ $(TEST_SCRIPTS_DIR)/test_template_coverage.sh $(CN_RML_DIR) $(CN_TEST_OUTPUT)
	@ echo

test_output_versioned_v%:
	@ echo "==> Test example output, v1.$*"
	@ echo "-> Test output orphans, v1.$*"
	@ $(JENA_TOOLS_ARQ) --query $(VALIDATION_DIR_SPARQL_RDF)/orphans_exist.select.rq --data $(VERSIONED_OUTPUT_DIR)/$(CANONICAL_EXAMPLE)-1.$*.ttl --results=$(TEST_QUERY_RESULTS_FORMAT) | grep -vE $(ROOT_CONCEPTS_GREPFILTER)
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
	@ echo "Testing CN output post-processing scripts"
	@ echo "==> Test link role playedBy"
	@ $(POST_SCRIPTS_DIR)/link_role_playedBy.sh
	@ echo
	@ echo "==> Test output missing playedBy"
	@ $(JENA_TOOLS_ARQ) --query $(TEST_QUERIES_DIR)/test_missing_playedBy.rq --data $(CN_TEST_OUTPUT) --data output/source/link_role_playedBy.ttl --results=$(TEST_QUERY_RESULTS_FORMAT)
