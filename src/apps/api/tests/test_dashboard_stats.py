from rest_framework.test import APIClient
from django.test import TestCase

from factories import (
    UserFactory,
    CompetitionFactory,
    TagFactory,
)
from dashboard.models import DashboardStats
from dashboard.builder import build_dashboard_stats, build_all_dashboard_stats


class DashboardStatsTests(TestCase):
    def setUp(self):
        self.client = APIClient()

        self.user = UserFactory(username="normal_user")
        self.staff_user = UserFactory(username="staff_user", is_staff=True)
        self.superuser = UserFactory(username="super_user", is_superuser=True)

        self.organizer = UserFactory(username="organizer_1", display_name="Org One")

        # Public competition with tag
        self.public_comp = CompetitionFactory(
            title="Public NLP Challenge",
            published=True,
            created_by=self.organizer,
            reward="Prize $1000",
        )
        self.tag = TagFactory(name="NLP")
        self.public_comp.tags.add(self.tag)
        self.public_comp.participants_count = 15
        self.public_comp.submissions_count = 30
        self.public_comp.save()

        # Private competition
        self.private_comp = CompetitionFactory(
            title="Internal Secret Benchmark",
            published=False,
            created_by=self.organizer,
        )
        self.private_comp.participants_count = 2
        self.private_comp.submissions_count = 5
        self.private_comp.save()

    def test_build_dashboard_stats(self):
        stat_pub = build_dashboard_stats(visibility='public')
        self.assertIsNotNone(stat_pub)
        self.assertEqual(len(stat_pub.competitions), 1)
        self.assertEqual(stat_pub.competitions[0]['title'], "Public NLP Challenge")
        self.assertEqual(stat_pub.competitions[0]['participants_count'], 15)
        self.assertEqual(stat_pub.competitions[0]['submissions_count'], 30)

        stat_priv = build_dashboard_stats(visibility='private')
        self.assertIsNotNone(stat_priv)
        self.assertEqual(len(stat_priv.competitions), 1)
        self.assertEqual(stat_priv.competitions[0]['title'], "Internal Secret Benchmark")

    def test_dashboard_stats_api_public(self):
        response = self.client.get("/api/dashboard/?visibility=public")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['visibility'], 'public')
        self.assertIn('competitions', data)
        self.assertEqual(len(data['competitions']), 1)
        self.assertEqual(data['competitions'][0]['title'], "Public NLP Challenge")

    def test_dashboard_stats_api_permission_denied_for_regular_user(self):
        # Anonymous user requesting private/all
        response = self.client.get("/api/dashboard/?visibility=all")
        self.assertEqual(response.status_code, 403)

        response = self.client.get("/api/dashboard/?visibility=private")
        self.assertEqual(response.status_code, 403)

        # Authenticated regular user requesting private/all
        self.client.force_authenticate(user=self.user)
        response = self.client.get("/api/dashboard/?visibility=all")
        self.assertEqual(response.status_code, 403)

        response = self.client.get("/api/dashboard/?visibility=private")
        self.assertEqual(response.status_code, 403)

    def test_dashboard_stats_api_allowed_for_staff(self):
        self.client.force_authenticate(user=self.staff_user)

        # 'all' concatenates public and private
        response = self.client.get("/api/dashboard/?visibility=all")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['visibility'], 'all')
        self.assertIn('competitions', data)
        self.assertEqual(len(data['competitions']), 2)

        # 'private' returns only private
        response_priv = self.client.get("/api/dashboard/?visibility=private")
        self.assertEqual(response_priv.status_code, 200)
        data_priv = response_priv.json()
        self.assertEqual(data_priv['visibility'], 'private')
        self.assertEqual(len(data_priv['competitions']), 1)
        self.assertEqual(data_priv['competitions'][0]['title'], "Internal Secret Benchmark")
