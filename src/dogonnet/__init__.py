"""dogonnet - Datadog dashboard templating with Jsonnet."""

__version__ = "0.1.1"

from dogonnet.client import DatadogDashboardClient
from dogonnet.utils import compile_jsonnet, load_dashboard

__all__ = [
    "DatadogDashboardClient",
    "compile_jsonnet",
    "load_dashboard",
    "__version__",
]
