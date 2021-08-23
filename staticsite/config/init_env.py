from dotenv import load_dotenv
from os.path import join, dirname

import os

dotenv_path = join(dirname(__file__), '.env')

def _load_env():
    secret_filenames = os.environ['APP_ENVFILE']
    for filename in secret_filenames.split(':'):
        load_dotenv(dotenv_path=filename, override=False)

_load_env()