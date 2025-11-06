"""doggonet - Datadog dashboard templating with Jsonnet."""

__version__ = "0.1.0"

from doggonet.client import DatadogDashboardClient
from doggonet.utils import compile_jsonnet, load_dashboard

__all__ = [
    "DatadogDashboardClient",
    "compile_jsonnet",
    "load_dashboard",
    "__version__",
]
