reformat_package_pin_v%:
	@ echo "Reformatting RML files for packaging $(PKG_PREFIX_PIN)_v1.$*, with $(OWLCLI_BIN)"
	for i in `find mappings/$(PKG_PREFIX_PIN)_v1.$*/$(TX_DIR)/mappings -type f`; do mv $$i $$i.bak && $(OWLCLI_CMD) $$i.bak $$i && rm -v $$i.bak; done

package_pin_minimal_v%:
	@ echo "Preparing minimal PIN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_minimal)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
	@ echo "Removing all PIN SDK v1.$* example data except any pin*_24_maximal"
	@ find $(PKG_DIR)/$(TEST_DATA_DIR) -type f -not -path "*pin*_24_maximal*" -exec rm -fv {} \;
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)</t>|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)_minimal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN)</t>|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN) (minimal data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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

export_pin_minimal_v%:
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_PREFIX_PIN)_v1.$*_minimal.zip $(PKG_PREFIX_PIN)_v1.$*_minimal
	@ echo "Minimal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_minimal.zip"

package_pin_examples_v%:
	@ echo "Preparing SDK examples PIN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_examples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
	@ echo "Including PIN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID PIN SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(REPLACE_CM_METADATA_ID_EXAMPLES), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)</t>|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)_examples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN), SDK v1.$*</t>|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN) (SDK example data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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

export_pin_examples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_examples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "SDK examples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_examples.zip"

package_pin_samples_v%:
	@ echo "Preparing samples PIN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_samples)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
ifeq ($(INCLUDE_OLD_SAMPLES), 1)
	@ echo "Including (old) EF29 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_PIN)-1.$*
	@ test -d $(SAMPLES_DIR_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_PIN)-1.$* \; || echo "No old samples for v1.$*"
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) PIN sample data"
	mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
	@ echo "Removing any SDK examples"
	@ rm -rv $(PKG_DIR)/$(SDK_DATA_DIR_PIN)*
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)</t>|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)_samples</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN)</t>|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN) (sample data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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

export_pin_samples_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_samples)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Samples package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_examples.zip"

package_pin_maximal_v%:
	@ echo "Preparing maximal PIN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_allData)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
	@ echo "Including PIN SDK v1.$* example data"
	@ mkdir -p $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*
	@ cp -rv $(SDK_DATA_DIR_PIN)/eforms-sdk-1.$*/* $(PKG_DIR)/test_data/$(SDK_DATA_NAME_PIN)-1.$*/
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID PIN SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(INCLUDE_OLD_SAMPLES), 1)
	@ echo "Including (old) EF29 sample data"
	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_PIN)-1.$*
	@ test -d $(SAMPLES_DIR_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_PIN)-1.$* \; || echo "No old samples for v1.$*"
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) PIN sample data"
	mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)</t>|<t>$(CM_ID_PREFIX_PIN)_$(CM_VER_STRING_PIN)_maximal</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN)</t>|<t>$(CM_TITLE_PREFIX_PIN), SDK $(CM_VER_STRING_PIN) (all data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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

export_pin_maximal_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_allData)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Maximal package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_examples.zip"

# TODO PIN multilingual samples
# package_pin_lang_v%:
# 	@ echo "Preparing multilingual PIN package, v1.$*"
# 	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_multilang)
# 	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
# 	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
# 	@ mkdir -p $(OUTPUT_DIR)
# 	@ rm -rfv $(PKG_DIR)
# 	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
# # NOTE: PINs don't have multilingual examples
# 	@ echo "Including PIN multilingual sample data"
# 	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_PIN)-1.$*
# 	@ test -d $(SAMPLES_DIR_LANG_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_PIN)-1.$* \; || echo "No multilingual samples for PIN v1.$*"
# 	@ echo "Including attributes CM"
# 	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
# ifeq ($(REPLACE_CM_METADATA_ID), 1)
# 	@ echo "Modifying Identifier in the CM and replacing XLSX"
# 	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
# 	@ rm -v $(PKG_DIR)/$(CM_FILE)
# 	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_10-24+29</t>|<t>$(CM_ID_PREFIX_PIN)_29_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
# 	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN)29, SDK $(CM_VER_STRING_PIN)</t>|<t>$(CM_TITLE_PREFIX_PIN)29, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
# 	@ cd $(PKG_TMP) && zip -r tmp.xlsx * && mv -v tmp.xlsx ../../$(PKG_DIR)/$(CM_FILE) && cd ../.. && rm -r $(PKG_TMP)
# endif
# 	@ echo "Removing outdated metadata"
# 	@ rm -fv $(PKG_DIR)/metadata.json
# ifeq ($(EXCLUDE_SPARQL_VALIDATIONS), 1)
# 	@ echo "Removing SPARQL validations"
# 	@ rm -rfv $(PKG_DIR)/validation/sparql/* -v
# endif
# 	@ echo "Removing any empty test_data subfolders"
# 	@ for i in $$(find $(PKG_DIR) -type d -empty -path "*/test_data/*"); do rm -rfv $$i; done

# export_pin_lang_v%:
# 	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_multilang)
# 	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
# 	@ echo "Multilingual package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_multilang.zip"

package_pin_attribs_v%:
	@ echo "Preparing attributes PIN package, v1.$*"
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_attribs)
	@ $(eval PKG_DIR := $(OUTPUT_DIR)/$(PKG_NAME))
	@ $(eval PKG_TMP := tmp/$(PKG_NAME))
	@ mkdir -p $(OUTPUT_DIR)
	@ rm -rfv $(PKG_DIR)
	@ cp -rv mappings/$(PKG_PREFIX_PIN)_v1.$* $(PKG_DIR)
# NOTE: PINs don't have multilingual examples
ifeq ($(INCLUDE_INVALID_EXAMPLES), 0)
	@ echo "Removing any INVALID PIN SDK v1.$* example data"
	@ rm -rv $(PKG_DIR)/$(TEST_DATA_DIR)/$(SDK_DATA_NAME_PIN)_invalid-1.$*
endif
ifeq ($(INCLUDE_NEW_SAMPLES), 1)
	@ echo "Including all (new) PIN sample data"
	mkdir -p $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$*
	test -d $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_ALL_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_ALL_PIN)-1.$* \; || echo "No new samples for v1.$*"
endif
# 	@ echo "Including PIN multilingual sample data"
# 	@ mkdir -p $(PKG_DIR)/$(SAMPLES_DIR_LANG_PIN)-1.$*
# 	@ test -d $(SAMPLES_DIR_LANG_PIN)/$(SDK_NAME)-1.$* && find $(SAMPLES_DIR_LANG_PIN)/$(SDK_NAME)-1.$*/ -type f -exec cp -rv {} $(PKG_DIR)/$(SAMPLES_DIR_LANG_PIN)-1.$* \; || echo "No multilingual samples for PIN v1.$*"
# 	@ echo "Including attributes CM"
# 	@ cp -v src/transformation/$(CM_ATTR_FILENAME) $(PKG_DIR)/$(CM_FILE)
ifeq ($(REPLACE_CM_METADATA_ID), 1)
	@ echo "Modifying Identifier in the CM and replacing XLSX"
	@ mkdir -p $(PKG_TMP) && unzip $(PKG_DIR)/$(CM_FILE) -d $(PKG_TMP)
	@ rm -v $(PKG_DIR)/$(CM_FILE)
	@ sed -i "s|<t>$(CM_ID_PREFIX_PIN)_10-24+29</t>|<t>$(CM_ID_PREFIX_PIN)_29_v1.$*_multilang</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
	@ sed -i "s|<t>$(CM_TITLE_PREFIX_PIN)29, SDK $(CM_VER_STRING_PIN)</t>|<t>$(CM_TITLE_PREFIX_PIN)29, SDK v1.$* (multilingual data)</t>|" $(PKG_TMP)/$(XLSX_STRDATA)
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

export_pin_attribs_v%:
	@ $(eval PKG_NAME := $(PKG_PREFIX_PIN)_v1.$*_attribs)
	@ cd $(OUTPUT_DIR) && zip -r $(PKG_NAME).zip $(PKG_NAME)
	@ echo "Attributes package exported to $(OUTPUT_DIR)/$(PKG_PREFIX_PIN)_v1.$*_attribs.zip"

package_pin_all_variants: package_pin_minimal package_pin_examples package_pin_samples package_pin_maximal

export_pin_all_variants: export_pin_minimal export_pin_examples export_pin_samples export_pin_maximal
