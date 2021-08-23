from pathlib import Path
import os
import re

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.2/howto/static-files/

# STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static')]

app_root_dir = Path(os.environ["APP_SRC"])

# STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_ROOT = app_root_dir / "static"

# STATIC_URL = 'https://%s/%s/' % (AWS_S3_CUSTOM_DOMAIN, AWS_LOCATION)
STATIC_URL = '/static/'

STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# whitenoise
WHITENOISE_ROOT = app_root_dir / "static"
WHITENOISE_AUTHREFRESH = True
WHITENOISE_MAX_AGE = 0

webroot_file_cache_control = "max-age=3600, public, stale-while-revalidate=86400"

immutable_filename_regex = re.compile(r"^chunk-[0-9a-f]{8}([-_.].*)?\.(js|css)$")
immutable_file_cache_control = "public, max-age=315360000, immutable"  # WhiteNoiseと同じ


def has_immutable_cache_control_directive(headers):
    return "immutable" in headers.get("Cache-Control", "")


def seems_immutable_file(path):
    return immutable_filename_regex.match(path.name)


def whitenoise_override_headers(headers, path, url):
    """一部の静的ファイルのCache-Controlを調整します
    DEBUG=False時にはDjango起動時にまとめて判定されます（リクエスト時にではない）
    """

    is_immutable = has_immutable_cache_control_directive(headers)
    if is_immutable:
        return

    path = Path(path)

    # is_webroot_file = path.is_relative_to(WHITENOISE_ROOT)
    # if is_webroot_file:
    #     headers["Cache-Control"] = webroot_file_cache_control
    #     return

    if seems_immutable_file(path):
        headers["Cache-Control"] = immutable_file_cache_control
        return

    return