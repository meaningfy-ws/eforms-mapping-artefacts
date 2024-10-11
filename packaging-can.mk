reformat_package_can_v%:
	@ echo "Reformatting RML files for packaging $(PKG_PREFIX_CAN)_v1.$*, with $(OWLCLI_BIN)"
	for i in `find mappings/$(PKG_PREFIX_CAN)_v1.$*/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_can_minimal_v%:
	@ echo "Preparing minimal CAN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_minimal)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CAN)_v1.$* $(PKG_DIR)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10</t>|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10 (minimal data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_can_minimal_v%:
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX_CAN)_v1.$*_minimal.zip $(PKG_PREFIX_CAN)_v1.$*_minimal
	@ echo "Minimal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CAN)_v1.$*_minimal.zip"

package_can_examples_v%:
	@ echo "Preparing SDK examples CAN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_examples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CAN)_v1.$* $(PKG_DIR)
	@ echo "Including CAN SDK v1.$* example data"
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CAN SDK v1.$* example data, INVALIDs"
	@ cp -rv $(SDK_DATA_DIR_CAN)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)_invalid
endif
ifeq ($(REPLACE_CM_METADATA_ID_EXAMPLES), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10</t>|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10_examples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10 (SDK example data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_can_examples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_examples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "SDK examples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CAN)_v1.$*_examples.zip"

package_can_samples_v%:
	@ echo "Preparing samples CAN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_samples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CAN)_v1.$* $(PKG_DIR)
	@ echo "Including EF29 manual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CAN)
	@ test -d $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CAN) \; || echo "No manual samples for v1.$*"
	@ echo "Removing any SDK examples"
	@ rm -rfv $(PKG_DIR)/$(SDK_DATA_DIR_CAN)*
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10</t>|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10_samples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10 (sample data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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
# @ [ -z `ls -A $(PKG_DIR)/$(SAMPLES_DIR_CAN)` ] && rm -rfv $(PKG_DIR)

export_can_samples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_samples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Samples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CAN)_v1.$*_examples.zip"

package_can_maximal_v%:
	@ echo "Preparing maximal CAN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CAN)_v1.$* $(PKG_DIR)
	@ echo "Including CAN SDK v1.$* example data"
	@ cp -rv $(SDK_DATA_DIR_CAN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 1)
	@ echo "Including CAN SDK v1.$* example data, INVALIDs"
	@ cp -rv $(SDK_DATA_DIR_CAN)_invalid/eforms-sdk-1.$* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_CAN)_invalid
endif
	@ echo "Including EF29 manual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_CAN)
	@ test -d $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_CAN) \; || echo "No manual samples for v1.$*"
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10</t>|<t>$(CM_ID_PREFIX_CAN)_v1.3-1.10_maximal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CAN), SDK v1.3-1.10 (all data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_can_maximal_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_allData)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Maximal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CAN)_v1.$*_examples.zip"

package_can_lang_v%:
	@ echo "Preparing multilingual CAN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_multilang)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_CAN)_v1.$* $(PKG_DIR)
# NOTE: CANs don't have multilingual examples
	@ echo "Including CAN multilingual sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN)
	@ test -d $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_CAN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_CAN) \; || echo "No multilingual samples for CAN v1.$*"
	@ echo "Including attributes CM"
	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_CAN)_10-24+29</t>|<t>$(CM_ID_PREFIX_CAN)_29_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_CAN)29, SDK v1.3-1.10</t>|<t>$(CM_TITLE_PREFIX_CAN)29, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
endif
	@ echo "Removing outdated metadata"
	@ rm -fv $(PKG_DIR)/metadata.json
ifeq ($(EXCLUDE_INEFFICIENT_VALIDATIONS), 1)
	@ echo "Removing inefficient generic validations"
	@ rm -rfv $(PKG_DIR)/validation/sparql/generic* -v
endif

export_can_lang_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_CAN)_v1.$*_multilang)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Multilingual package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_CAN)_v1.$*_multilang.zip"

package_can_all_variants: package_can_minimal package_can_examples package_can_samples package_can_maximal

export_can_all_variants: export_can_minimal export_can_examples export_can_samples export_can_maximal
