from django.views.generic import TemplateView
from django.contrib.auth.mixins import UserPassesTestMixin


class DashboardView(UserPassesTestMixin, TemplateView):
    template_name = 'dashboard/dashboard.html'

    def test_func(self):
        user = self.request.user
        return user.is_authenticated and (user.is_staff or user.is_superuser)
