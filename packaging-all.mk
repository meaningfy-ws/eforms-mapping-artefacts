reformat_package_v%:
	@ echo "Reformatting RML files for packaging $(PKG_PREFIX)_v1.$*, with $(OWLCLI_BIN)"
	for i in `find mappings/$(PKG_PREFIX)_v1.$*/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_minimal_v%:
	@ echo "Preparing minimal combined package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_minimal)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Removing all CN SDK v1.$* example data except cn_24_maximal"
	@ find $(PKG_DIR)/$(TEST_DATA_DIR) -type f -not -path "*cn_24_maximal.xml" -exec rm -fv {} \;
	@ echo "Removing all CAN SDK v1.$* example data except can_24_maximal"
	@ find $(PKG_DIR)/$(TEST_DATA_DIR) -type f -not -path "*can_24_maximal*" -exec rm -fv {} \;
	@ echo "Removing all PIN SDK v1.$* example data except any pin*_24_maximal"
	@ find $(PKG_DIR)/$(TEST_DATA_DIR) -type f -not -path "*pin*_24_maximal*" -exec rm -fv {} \;
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>package_v1.$*_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>eForms Mappings, SDK v1.$* (minimal data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

package_examples_v%:
	@ echo "Preparing combined examples package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_examples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(EXCLUDE_LARGE_EXAMPLE), 1)
	@ echo "Removing large file cn_24_maximal_100_lots.xml"
	@ find $(PKG_DIR) -name "cn_24_maximal_100_lots.xml" -exec rm -v {} \;
endif
ifeq ($(REPLACE_CM_METADATA_ID_EXAMPLES), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>package_v1.$*_examples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>eForms Mappings, SDK v1.$* (SDK example data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

package_samples_v%:
	@ echo "Preparing combined samples package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_samples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
ifeq ($(INCLUDE_OLD_SAMPLES), 1)
	@ echo "Including (old) EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including (old) EF29 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$*
	@ test -d $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$* \; || echo "No old samples for v1.$*"
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
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) CN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$*
	@ test -d $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including all (new) CAN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$*
	@ test -d $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$* \; || echo "No new samples for v1.$*"
	@ echo "Including all (new) PIN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	@ test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
	@ echo "Removing any SDK examples"
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR_CN)*
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR_CAN)*
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR_PIN)*
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>package_v1.$*_samples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>eForms Mappings, SDK v1.$* (sample data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

package_maximal_v%:
	@ echo "Preparing maximal combined package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(INCLUDE_OLD_SAMPLES), 1)
	@ echo "Including (old) EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including (old) EF29 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$*
	@ test -d $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$* \; || echo "No old samples for v1.$*"
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
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) CN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$*
	@ test -d $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including all (new) CAN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$*
	@ test -d $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$* \; || echo "No new samples for v1.$*"
	@ echo "Including all (new) PIN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	@ test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>package_v1.$*_allData</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>eForms Mappings, SDK v1.$* (all data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

package_lang_v%:
	@ echo "Preparing multilingual combined package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_multilang)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including SDK v1.$* multilingual example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/*multilingual* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
# NOTE: CANs don't have multilingual examples
# @ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*
# @ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/*multilingual* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*/
	@ echo "Including multilingual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$* \; || echo "No multilingual samples for CN v1.$*"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN)-1.$* \; || echo "No multilingual samples for CAN v1.$*"
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_v1.$*</t>|<t>package_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN), SDK v1.$*</t>|<t>eForms Mappings, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

package_attribs_v%:
	@ echo "Preparing attributes combined package for v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX)_v1.$*_attribs)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX)_v1.$* $(PKG_DIR)
	@ echo "Including SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)-1.$*/
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_CAN)_invalid-1.$*
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(INCLUDE_OLD_SAMPLES), 1)
	@ echo "Including (old) EF10-24 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$*
	@ test -d $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including (old) EF29 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$*
	@ test -d $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CAN)-1.$* \; || echo "No old samples for v1.$*"
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
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) CN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$*
	@ test -d $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CN)-1.$* \; || echo "No old samples for v1.$*"
	@ echo "Including all (new) CAN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$*
	@ test -d $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_CAN)-1.$* \; || echo "No new samples for v1.$*"
	@ echo "Including all (new) PIN sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	@ test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
	@ echo "Including multilingual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CN)-1.$* \; || echo "No multilingual samples for CN v1.$*"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN)-1.$*
	@ test -d $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN)-1.$* \; || echo "No multilingual samples for CAN v1.$*"
	@ echo "Including attributes CM"
	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CN)_10-24+29</t>|<t>package_v1.$*_attribs</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CN)10-EF24, SDK v1.3-1.10</t>|<t>eForms Mappings, SDK v1.$* (attributes)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
	@ echo "Removing SPARQL validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
endif
	@ echo "Removing any empty test_data subfolders"
	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

export_minimal_v%:
	@ $(MAKE) package_minimal_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_minimal.zip $(PKG_PREFIX)_v1.$*_minimal

export_examples_v%:
	@ $(MAKE) package_examples_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_examples.zip $(PKG_PREFIX)_v1.$*_examples

export_samples_v%:
	@ $(MAKE) package_samples_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_samples.zip $(PKG_PREFIX)_v1.$*_samples

export_maximal_v%:
	@ $(MAKE) package_maximal_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_allData.zip $(PKG_PREFIX)_v1.$*_allData

export_lang_v%:
	@ $(MAKE) package_lang_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_multilang.zip $(PKG_PREFIX)_v1.$*_multilang

export_attribs_v%:
	@ $(MAKE) package_attribs_v$*
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX)_v1.$*_attribs.zip $(PKG_PREFIX)_v1.$*_attribs

package_all_variants: package_minimal package_examples package_samples package_maximal package_attribs

export_all_variants: export_minimal export_examples export_samples export_maximal export_attribs
