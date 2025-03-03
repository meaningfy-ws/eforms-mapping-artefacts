CN_RML_DIR = src/mappings
CAN_RML_DIR = src/mappings-can
PIN_RML_DIR = src/mappings-pin

CN_TEST_OUTPUT = src/output-cn.ttl
CAN_TEST_OUTPUT = src/output-can.ttl
PIN_TEST_OUTPUT = src/output-pin.ttl
VERSIONED_OUTPUT_DIR = src/output-versioned
CANONICAL_EXAMPLE = cn_24_maximal

JENA_TOOLS_DIR = $(shell test ! -z ${JENA_HOME} && echo ${JENA_HOME} || echo `pwd`/jena)
JENA_TOOLS_RIOT = $(JENA_TOOLS_DIR)/bin/riot
JENA_TOOLS_ARQ = $(JENA_TOOLS_DIR)/bin/arq

VERSIONS := $(shell seq 3 13)

include development.mk
include testing.mk
include documentation.mk
