import json
from cloud_cron.notifications.base import EnvVarTemplateProvider
from cloud_cron.notifications.print_handler import PrintNotificationHandler


def test_print_handler_prints_rendered_template(monkeypatch, capsys):
    monkeypatch.setenv("TEMPLATE", "Hello {{ name }}")
    handler = PrintNotificationHandler(template_provider=EnvVarTemplateProvider())
    event = {
        "Records": [{"body": json.dumps({"name": "Ada"}), "eventSource": "aws:sqs"}]
    }

    handler.lambda_handler(event, context=None)

    captured = capsys.readouterr()
    assert captured.out.strip() == "Hello Ada"
