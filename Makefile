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

	if [ `pyenv versions | grep -c '3.8.2'` = "0" ]; then \
		pyenv install 3.8.2; \
	fi

	pyenv local 3.8.2
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

