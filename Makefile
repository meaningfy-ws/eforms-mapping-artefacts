BUILD_PRINT = \e[1;34mSTEP: \e[0m
MINIMAL_PACKAGE = package_cn_v1.9_minimal
JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
CANONICAL_TEST_OUTPUT = src/output.ttl
CANONICAL_RML_DIR = src/mappings

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
	@ echo "Validating test output w/ $(JENA_TOOLS_DIR)"
	@ $(JENA_TOOLS_RIOT) --validate $(CANONICAL_TEST_OUTPUT)

clean:
	@ rm -v jena.zip