PYTHON_VERSION:=3.8.2
UID := $(shell id -u)
DKR_CMP := env UID=$(UID) docker-compose --project-directory=.

define dkr-cmp
	$(DKR_CMP) --env-file=docker/$1/compose.env $2
endef

.PHONY: help
help: ## Display this help screen
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## setup for development
	for pkg in pyenv direnv; do \
		if [ `brew list $$pkg | wc -l | tr -d ' '` == 0 ]; then \
			brew install $$pkg || true; \
		fi \
	done

	if [ `pyenv versions | grep -c '$(PYTHON_VERSION)'` = "0" ]; then \
		pyenv install $(PYTHON_VERSION); \
	fi

	pyenv local $(PYTHON_VERSION)
	pyenv exec python -m venv .venv
	pyenv exec python -m pip install --upgrade pip
	.venv/bin/python -m pip install -r ./requirements/dev/requirements.txt
	.venv/bin/python -m pip install -r ./requirements/deploy/requirements.txt

	if [ ! -e $(HOME)/.envrc ]; then \
		touch $(HOME)/.direnvrc; \
	fi

	if [ `grep "direnv hook zsh" ~/.zshrc | wc -l | tr -d ' '` = "0" ]; then \
		echo 'eval "$(direnv hook zsh)"'; >> ~/.zshrc \
		source ~/.zshrc; \
	fi
	direnv allow


#
# stage local Tasks
#
.PHONY: local
local: ## ローカル開発環境を起動します
	$(call dkr-cmp,local,up --remove-orphans)

.PHONY: local-stop
local-stop: ## ローカル開発環境を停止します
	$(call dkr-cmp,local,stop)

.PHONY: local-restart-app
local-restart-app: ## ローカル開発環境を再起動します
	$(call dkr-cmp,local,restart app)

#
# dev Tasks
#
