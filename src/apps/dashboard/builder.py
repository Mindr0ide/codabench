import logging
from competitions.models import Competition
from .models import DashboardStats

logger = logging.getLogger(__name__)


def build_dashboard_stats(visibility='public'):
    """
    Serializes lightweight competition objects for the dashboard.
    Persists the results into the DashboardStats model.
    """
    logger.info("Computing dashboard stats for visibility='%s'...", visibility)

    qs = Competition.objects.all().select_related('created_by').prefetch_related('tags__category')
    if visibility == 'public':
        qs = qs.filter(published=True)
    elif visibility == 'private':
        qs = qs.filter(published=False)

    competitions = []

    for comp in qs:
        if comp.created_by:
            org_name = comp.created_by.display_name or comp.created_by.username or "Unknown"
        else:
            org_name = "Unknown"

        tags_by_category = {}
        for tag in comp.tags.all():
            cat_name = tag.category.name if tag.category else "Other"
            if cat_name not in tags_by_category:
                tags_by_category[cat_name] = []
            tags_by_category[cat_name].append(tag.name)

        created_str = comp.created_when.isoformat() if comp.created_when else None
        has_reward = bool(comp.reward and str(comp.reward).strip())

        competitions.append({
            'id': comp.id,
            'title': comp.title or '',
            'organizer': org_name,
            'url': f'/competitions/{comp.id}/',
            'published': comp.published,
            'competition_type': comp.competition_type or 'competition',
            'participants_count': comp.participants_count or 0,
            'submissions_count': comp.submissions_count or 0,
            'created_when': created_str,
            'reward': comp.reward or '',
            'has_reward': has_reward,
            'tagsByCategory': tags_by_category,
        })

    stat, _ = DashboardStats.objects.update_or_create(
        visibility=visibility,
        defaults={
            'competitions': competitions,
        },
    )

    logger.info(
        "Dashboard stats for '%s' saved successfully (%d competitions).",
        visibility,
        len(competitions),
    )
    return stat


def build_all_dashboard_stats():
    """Builds and caches dashboard stats for both public and private visibility scopes."""
    build_dashboard_stats(visibility='public')
    build_dashboard_stats(visibility='private')
