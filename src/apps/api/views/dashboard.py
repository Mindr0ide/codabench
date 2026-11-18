import logging
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.exceptions import PermissionDenied

from dashboard.models import DashboardStats
from dashboard.builder import build_dashboard_stats

logger = logging.getLogger(__name__)


class DashboardStatsView(APIView):
    """
    Returns precomputed dashboard statistics and lightweight competition records.
    Partitions public and private competitions in the database to prevent duplication.
    """
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        visibility = request.query_params.get('visibility', 'public').lower()
        if visibility not in ('public', 'private', 'all'):
            visibility = 'public'

        # Security check: only staff or superusers can view private or all competitions
        if visibility in ('private', 'all'):
            if not (request.user.is_authenticated and (request.user.is_staff or request.user.is_superuser)):
                raise PermissionDenied("You do not have permission to view private dashboard statistics.")

        if visibility == 'public':
            stat = DashboardStats.objects.filter(visibility='public').first()
            if not stat:
                logger.info("Public dashboard stats not found, generating on-the-fly...")
                stat = build_dashboard_stats(visibility='public')
            return Response({
                'visibility': 'public',
                'last_updated': stat.last_updated.isoformat() if stat.last_updated else None,
                'competitions': stat.competitions,
            })

        if visibility == 'private':
            stat = DashboardStats.objects.filter(visibility='private').first()
            if not stat:
                logger.info("Private dashboard stats not found, generating on-the-fly...")
                stat = build_dashboard_stats(visibility='private')
            return Response({
                'visibility': 'private',
                'last_updated': stat.last_updated.isoformat() if stat.last_updated else None,
                'competitions': stat.competitions,
            })

        # visibility == 'all': concatenate public and private partitions in memory
        stat_pub = DashboardStats.objects.filter(visibility='public').first()
        if not stat_pub:
            stat_pub = build_dashboard_stats(visibility='public')

        stat_priv = DashboardStats.objects.filter(visibility='private').first()
        if not stat_priv:
            stat_priv = build_dashboard_stats(visibility='private')

        dates = [d for d in (stat_pub.last_updated, stat_priv.last_updated) if d]
        last_updated = max(dates).isoformat() if dates else None

        return Response({
            'visibility': 'all',
            'last_updated': last_updated,
            'competitions': (stat_pub.competitions or []) + (stat_priv.competitions or []),
        })
