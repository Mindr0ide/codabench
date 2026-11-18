import logging
from celery_config import app

logger = logging.getLogger(__name__)


@app.task(queue="site-worker", soft_time_limit=300)
def compute_dashboard_stats():
    """Celery task to periodically refresh precomputed dashboard statistics."""
    from .builder import build_all_dashboard_stats
    logger.info("Task compute_dashboard_stats started")
    build_all_dashboard_stats()
    logger.info("Task compute_dashboard_stats completed")
