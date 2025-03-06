install-node:
	@ echo -e "$(BUILD_PRINT)Installing the NodeJS$(END_BUILD_PRINT)"
	@ sudo apt install npm
	@ mkdir -p ~/.npm
	@ npm config set prefix ~/.npm
	@ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
	@ nvm list-remote
	@ nvm install lts/gallium
	@ source ~/.bashrc

install-antora:
	@ echo -e "$(BUILD_PRINT)Installing the Antora$(END_BUILD_PRINT)"
	@ npm install

build-site:
	@ echo -e "$(BUILD_PRINT)Build site$(END_BUILD_PRINT)"
	@ envsubst < antora-playbook.yml.template > antora-playbook.yml
	@ npx antora --fetch antora-playbook.yml.run
