from config import config as app_config

broker_url = app_config.settings.celery_broker_url
result_backend = app_config.settings.celery_broker_url

task_serializer = 'json'
result_serializer = 'json'
accept_content = ['json']
timezone = 'UTC'
enable_utc = True
