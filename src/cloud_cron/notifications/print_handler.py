from typing import Any, Mapping

from cloud_cron.notifications.base import NotificationHandler


class PrintNotificationHandler(NotificationHandler):
    """
    Notification handler that logs rendered templates for testing.

    Parameters
    ----------
    template_provider : TemplateProvider
        Provider that returns the template string for rendering.
    expected_queue_arn : str, optional
        Queue ARN to validate incoming SQS records.
    logger : logging.Logger, optional
        Logger used for structured logging.
    """

    def notify(
        self,
        *,
        result: Mapping[str, Any],
        rendered: str,
        record: Mapping[str, Any],
    ) -> None:
        """
        Log the rendered notification payload.

        Parameters
        ----------
        result : Mapping[str, Any]
            Parsed result payload from the SNS-to-SQS pipeline.
        rendered : str
            Rendered template output.
        record : Mapping[str, Any]
            Original SQS record for additional metadata.
        """
        print(rendered)
