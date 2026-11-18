from django.core.management.base import BaseCommand
from dashboard.builder import build_dashboard_stats, build_all_dashboard_stats


class Command(BaseCommand):
    help = "Precompute and cache dashboard statistics in the database."

    def add_arguments(self, parser):
        parser.add_argument(
            '--scope',
            choices=['public', 'private', 'all', 'both'],
            default='both',
            help="Specify which visibility scope to compute (default: 'both')",
        )

    def handle(self, *args, **options):
        scope = options.get('scope', 'both')
        self.stdout.write(f"Precomputing dashboard statistics (scope: {scope})...")

        if scope in ('both', 'all'):
            build_all_dashboard_stats()
        elif scope == 'public':
            build_dashboard_stats(visibility='public')
        elif scope == 'private':
            build_dashboard_stats(visibility='private')

        self.stdout.write(self.style.SUCCESS("Dashboard statistics successfully computed and saved to the database."))
