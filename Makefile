BUILD_PRINT = \e[1;34mSTEP: \e[0m
MINIMAL_PACKAGE = package_cn_v1.9_minimal

package_minimal:
	@ cp -rv src/mappings mappings/$(MINIMAL_PACKAGE)/transformation/
	@ cp -rv src/transformation mappings/$(MINIMAL_PACKAGE)/
