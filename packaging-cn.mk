# FIXME: don't think anyone would use it like this wholesale (but rather more selectively)
reformat_package_cn_v%:
	@ echo "Reformatting RML files for packaging $(PKG_PREFIX_CN)_v1.$*, with $(OWLCLI_BIN)"
	for i in `find mappings/$(PKG_PREFIX_CN)_v1.$*/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_cn_minimal_v%:
	@ echo "Preparing minimal CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_minimal)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(CM_ID_PREFIX_CN)_v1.$*_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$* (minimal data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_minimal_v%:
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX_CN)_v1.$*_minimal.zip $(PKG_PREFIX_CN)_v1.$*_minimal
	@ echo "Minimal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_minimal.zip"

# we exclude large file *100_lots in this package, but include it in maximal (allData)
package_cn_examples_v%:
	@ echo "Preparing SDK examples CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_examples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)_invalid-1.$*
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
ifeq ($(REPLACE_CM_METADATA_ID_EXAMPLES), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(CM_ID_PREFIX_CN)_v1.$*_examples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$* (SDK example data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_examples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_examples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "SDK examples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_examples.zip"

package_cn_samples_v%:
	@ echo "Preparing samples CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_samples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
	@ echo "Including EF10-24 systematic sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No systematic samples for v1.$*"
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including EF10-24 random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$*
	@ test -d $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* \; || echo "No random samples for v1.$*"
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic sample notices"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* -name 665610-2023.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 135016-2024.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 725041-2023.xml -exec rm -fv {} \;
endif
	@ echo "Removing any SDK examples"
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR_CN)*
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(CM_ID_PREFIX_CN)_v1.$*_samples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$* (sample data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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
# @ [ -z `ls -A $(PKG_DIR)/$(SAMPLES_DIR_CN)` ] && rm -rfv $(PKG_DIR)

export_cn_samples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_samples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Samples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_examples.zip"

package_cn_maximal_v%:
	@ echo "Preparing maximal CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CN SDK v1.$* example data, INVALIDs"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)_invalid-1.$*
endif
# TODO: not working, use Bash notation or bring out into separate target
# but also not needed as they are already tracked in the default/minimal packages we copy from
# ifeq ($($*), 9)
# 	@ echo "Including CN OP test data"
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_d2.1 $(PKG_DIR)/test_data
# 	@ cp -rv $(TEST_DATA_DIR)/op_test_cn_gh_issues $(PKG_DIR)/test_data
# endif
	@ echo "Including EF10-24 systematic sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No manual samples for v1.$*"
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including EF10-24 random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$*
	@ test -d $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* \; || echo "No random samples for v1.$*"
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic sample notices"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* -name 665610-2023.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 135016-2024.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 725041-2023.xml -exec rm -fv {} \;
endif
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>$(CM_ID_PREFIX_CN)_v1.$*_maximal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$* (all data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_maximal_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_allData)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Maximal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_examples.zip"

package_cn_lang_v%:
	@ echo "Preparing multilingual CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_multilang)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* multilingual example data"
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/*multilingual* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
	@ echo "Including CN multilingual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$* \; || echo "No multilingual samples for CN v1.$*"
	@ echo "Including attributes CM"
	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_10-24+29</t>|<t>$(CM_ID_PREFIX_CN)_10-24_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN)10-EF24, SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CN)10-EF24, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_lang_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_multilang)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Multilingual package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_multilang.zip"

package_cn_attribs_v%:
	@ echo "Preparing attributes CN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_attribs)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CN)_v1.$* $(PKG_DIR)
	@ echo "Including CN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
	@ echo "Including EF10-24 systematic sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No manual samples for v1.$*"
	@ echo "Including CN multilingual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$* \; || echo "No multilingual samples for CN v1.$*"
ifeq ($(INCLUDE_RANDOM_SAMPLES), 1)
	@ echo "Including EF10-24 random sampling data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$*
	@ test -d $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$* && find $(SAMPLES_RANDOM_DIR)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* \; || echo "No random samples for v1.$*"
endif
ifeq ($(EXCLUDE_PROBLEM_SAMPLES), 1)
	@ echo "Removing problematic sample notices"
	@ find $(PKG_DIR)/$(SAMPLES_RANDOM_DIR)-1.$* -name 665610-2023.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 135016-2024.xml -exec rm -fv {} \;
	@ find $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* -name 725041-2023.xml -exec rm -fv {} \;
endif
	@ echo "Including attributes CM"
	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_10-24+29</t>|<t>$(CM_ID_PREFIX_CN)_10-24_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN)10-EF24, SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CN)10-EF24, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_cn_attribs_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CN)_v1.$*_attribs)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Attributes package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CN)_v1.$*_attribs.zip"

package_cn_all_variants: package_cn_minimal package_cn_examples package_cn_samples package_cn_maximal

export_cn_all_variants: export_cn_minimal export_cn_examples export_cn_samples export_cn_maximal
