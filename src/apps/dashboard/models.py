from django.db import models


class DashboardStats(models.Model):
    """
    Stores pre-serialized lightweight competition records for the Dashboard.
    Avoids expensive database joins and DRF serialization on every page load.
    """
    VISIBILITY_CHOICES = (
        ('public', 'Public Competitions'),
        ('private', 'Private Competitions'),
    )

    visibility = models.CharField(
        max_length=32,
        choices=VISIBILITY_CHOICES,
        unique=True,
        default='public',
        db_index=True,
    )
    last_updated = models.DateTimeField(auto_now=True)
    competitions = models.JSONField(default=list)

    class Meta:
        verbose_name = "Dashboard Statistics"
        verbose_name_plural = "Dashboard Statistics"

    def __str__(self):
        return f"DashboardStats ({self.visibility}) - {len(self.competitions)} competitions (updated {self.last_updated})"
