MAPPINGS_DIR = mappings
OUTPUT_DIR = dist
PKG_PREFIX_CN = package_cn
PKG_PREFIX_CAN = package_can
SDK_NAME = eforms-sdk
DEFAULT_SDK_VERSION = 1.9
SDK_DATA_NAME_CN = sdk_examples_cn
SDK_DATA_NAME_CAN = sdk_examples_can
SAMPLES_NAME_CN = sampling_20231001-20240311
SAMPLES_NAME_CAN = sampling_manual_CAN_202404
SAMPLES_NAME_LANG = sampling_multilingual
SAMPLES_RANDOM_NAME = sampling_random
ROOT_CONCEPTS_GREPFILTER = "_Organization_|_TouchPoint_|_Notice|_ProcurementProcessInformation_|_Lot_|_VehicleInformation_|_ChangeInformation_"
TEST_QUERY_RESULTS_FORMAT = CSV
XLSX_STRDATA = xl/sharedStrings.xml
CM_ID_PREFIX_CN = package_eforms
CM_TITLE_PREFIX_CN = Package EF
CM_ID_PREFIX_CAN = package_eforms
CM_TITLE_PREFIX_CAN = Package EF
TRIM_DOWN_SHACL = 1
EXCLUDE_INEFFICIENT_VALIDATIONS = 1
INCLUDE_RANDOM_SAMPLES = 1
EXCLUDE_PROBLEM_SAMPLES = 1
INCLUDE_INVALID_EXAMPLES = 0
EXCLUDE_LARGE_EXAMPLE = 1
REPLACE_CM_METADATA_ID = 1
REPLACE_CM_METADATA_ID_EXAMPLES = 0

CN_TEST_OUTPUT = src/output-cn.ttl
CAN_TEST_OUTPUT = src/output-can.ttl
CANONLY_TEST_OUTPUT = src/output-canonly.ttl
VERSIONED_OUTPUT_DIR = src/output-versioned
CANONICAL_EXAMPLE = cn_24_maximal
CN_RML_DIR = src/mappings
CAN_RML_DIR = src/mappings-can
TEST_DATA_DIR = test_data
TEST_QUERIES_DIR = test_queries
TEST_SCRIPTS_DIR = test_scripts
POST_SCRIPTS_DIR = src/scripts
TX_DIR = transformation
CM_FILENAME = conceptual_mappings.xlsx
CM_ATTR_FILENAME = conceptual_mappings_CN+CAN_Attributes.xlsx
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
ANLYS_SCRIPTS_DIR = analysis_scripts

BUILD_PRINT = \e[1;34mSTEP: \e[0m
SDK_DATA_DIR_CN = $(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)
SDK_DATA_DIR_CAN = $(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)
SAMPLES_DIR_CN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_CN)
SAMPLES_DIR_CAN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_CAN)
SAMPLES_DIR_LANG_CN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_LANG)_cn
SAMPLES_DIR_LANG_CAN = $(TEST_DATA_DIR)/$(SAMPLES_NAME_LANG)_can
SAMPLES_RANDOM_DIR = $(TEST_DATA_DIR)/$(SAMPLES_RANDOM_NAME)
CM_FILE = $(TX_DIR)/$(CM_FILENAME)

VERSIONS := $(shell seq 3 10)
# some versions don't currently have systematic and/or random samples
VERSIONS_SAMPLES := $(3 6 7 8 9)

package_sync: $(addprefix package_sync_v, $(VERSIONS))
package_release_cn: $(addprefix package_release_cn_v, $(VERSIONS))
package_release_can: $(addprefix package_release_can_v, $(VERSIONS))
reformat_package_cn: $(addprefix reformat_package_cn_v, $(VERSIONS))
reformat_package_can: $(addprefix reformat_package_can_v, $(VERSIONS))
package_cn_minimal: $(addprefix package_cn_minimal_v, $(VERSIONS))
package_can_minimal: $(addprefix package_can_minimal_v, $(VERSIONS))
export_cn_minimal: $(addprefix export_cn_minimal_v, $(VERSIONS))
export_can_minimal: $(addprefix export_can_minimal_v, $(VERSIONS))
package_cn_examples: $(addprefix package_cn_examples_v, $(VERSIONS))
package_can_examples: $(addprefix package_can_examples_v, $(VERSIONS))
export_cn_examples: $(addprefix export_cn_examples_v, $(VERSIONS))
export_can_examples: $(addprefix export_can_examples_v, $(VERSIONS))
package_cn_samples: $(addprefix package_cn_samples_v, $(VERSIONS))
package_can_samples: $(addprefix package_can_samples_v, $(VERSIONS))
export_cn_samples: $(addprefix export_cn_samples_v, $(VERSIONS))
export_can_samples: $(addprefix export_can_samples_v, $(VERSIONS))
package_cn_maximal: $(addprefix package_cn_maximal_v, $(VERSIONS))
package_can_maximal: $(addprefix package_can_maximal_v, $(VERSIONS))
export_cn_maximal: $(addprefix export_cn_maximal_v, $(VERSIONS))
export_can_maximal: $(addprefix export_can_maximal_v, $(VERSIONS))
package_cn_lang: $(addprefix package_cn_lang_v, $(VERSIONS))
package_can_lang: $(addprefix package_can_lang_v, $(VERSIONS))
export_cn_lang: $(addprefix export_cn_lang_v, $(VERSIONS))
export_can_lang: $(addprefix export_can_lang_v, $(VERSIONS))
test_versioned: $(addprefix test_versioned_v, $(VERSIONS))
test_output_versioned: $(addprefix test_output_versioned_v, $(VERSIONS))

package_prep:
	@ echo "Staging versioned folders"
	@ cd src && bash $(MULTIVER_SCRIPT)

# TODO: move src subfolders around to be more compatible w/ packages (mappings -> transformation)
# we are not copying over CM for now -- leaving it under manual control
# also not copying over data
package_sync_v%: package_prep
	@ echo "Syncing CN v1.$*"
	@ mkdir -p mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/
	@ rm -rfv mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/mappings*
	@ cp -rv src/mappings mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/
	@ cp -v src/mappings-common/* mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/mappings/
	@ cp -v src/mappings-1.$*/* mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/mappings/
	@ rm -rfv mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/mappings/*can_v*
	@ rm -rfv mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/
	@ rm -rfv mappings/$(PKG_PREFIX_CN)_v1.$*/validation
	@ cp -rv src/validation mappings/$(PKG_PREFIX_CN)_v1.$*/
	@ echo "Syncing CAN v1.$*"
	@ mkdir -p mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/	
	@ rm -rfv mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/mappings*
	@ cp -rv src/mappings mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/
	@ cp -v src/mappings-can/* mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/mappings/
	@ cp -v src/mappings-common/* mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/mappings/
	@ cp -v src/mappings-1.$*/* mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/mappings/
	@ rm -rfv mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/resources
	@ cp -rv src/$(TX_DIR)/resources mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/
	@ rm -rfv mappings/$(PKG_PREFIX_CAN)_v1.$*/validation
	@ cp -rv src/validation mappings/$(PKG_PREFIX_CAN)_v1.$*/
ifeq ($(TRIM_DOWN_SHACL), 1)
	@ echo "Modifying ePO SHACL file to suppress rdf:PlainLiteral violations"
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' mappings/$(PKG_PREFIX_CN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:datatype rdf:PlainLiteral/sh:or ( [ sh:datatype xsd:string ] [ sh:datatype rdf:langString ] )/' mappings/$(PKG_PREFIX_CAN)_v1.$*/$(SHACL_PATH_EPO)
	@ echo "Modifying ePO SHACL file to substitute at-voc constraint with IRI"
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' mappings/$(PKG_PREFIX_CN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' mappings/$(PKG_PREFIX_CN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' mappings/$(PKG_PREFIX_CN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc.*;/sh:nodeKind sh:IRI ;/' mappings/$(PKG_PREFIX_CAN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i 's/sh:class at-voc:environmental-impact,/sh:nodeKind sh:IRI ;/' mappings/$(PKG_PREFIX_CAN)_v1.$*/$(SHACL_PATH_EPO)
	@ sed -i '/.*at-voc:green-public-procurement-criteria ;/d' mappings/$(PKG_PREFIX_CAN)_v1.$*/$(SHACL_PATH_EPO)	
endif

package_release_cn_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(PKG_PREFIX_CN)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing CN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
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

package_release_can_v%: package_prep
	@ $(eval PKG_DIR := $(RELEASE_DIR)/mappings/$(PKG_PREFIX_CAN)_v1.$*)
	@ $(eval PKG_EXISTS := $(shell test -d $(PKG_DIR) && echo yes || echo no))
	@ if [ "$(PKG_EXISTS)" = "yes" ]; then \
		echo "Syncing CAN v1.$* to $(RELEASE_DIR)"; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/mappings ; \
		cp -rv src/mappings $(PKG_DIR)/$(TX_DIR)/ ; \
		cp -v src/mappings-can/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-common/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		cp -v src/mappings-1.$*/* $(PKG_DIR)/$(TX_DIR)/mappings/ ; \
		rm -rv $(PKG_DIR)/$(TX_DIR)/resources ; \
		cp -rv src/$(TX_DIR)/resources $(PKG_DIR)/$(TX_DIR)/ ; \
	  fi

include packaging-cn.mk
include packaging-can.mk
include testing.mk
include documentation.mk

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

clean:
	@ rm -fv jena.zip
	@ rm -rfv dist
	@ rm -rfv tmp
	@ rm -rfv src/mappings-1*

# requires jq, python (pandas for reading Excel, thefuzz for XPath str similarity)
# credit https://unix.stackexchange.com/a/249799 by nisetama
# TODO generate the diffs and handle different versions
# recommended to first generate diffs with analyse_versions.sh against a master CM (filtered to CN or CAN)
get_xpath_similarity_stats:
	@ echo "Frequency of Abs XPath similarity scores (no. of field-version range comparisons, score):" && echo && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | uniq -c | sort -nr
	@ echo
	@ echo -n "Min: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s min
	@ echo -n "Max: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s max
	@ echo -n "Avg: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s add/length
	@ echo -n "Med: " && grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end'

get_xpath_similarity_grouped:
	@ bash $(ANLYS_SCRIPTS_DIR)/xpath_sim_stats_grouped.sh

get_xpath_similarity_table:
	@ bash $(ANLYS_SCRIPTS_DIR)/xpath_sim_stats_table.sh

get_languageMap_reflengths: clean
	@ bash $(ANLYS_SCRIPTS_DIR)/langMap_ref_lengths.sh

get_languageMap_reflength_stats: clean
	@ echo "XPath reference lengths of languageMaps (no. of @languageId occurences, XPath length):"
	@ bash $(ANLYS_SCRIPTS_DIR)/langMap_ref_lengths.sh | awk -F" " '{print $$2}' | sort | uniq -c | sort -nr
