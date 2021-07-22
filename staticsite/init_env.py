import os

import dotenv

def _loadenv():
	secret_filenames = os.environ["APP_ENVFILE"]
	for filename in secret_filenames.split(":"):
		dotenv

_loadenv()