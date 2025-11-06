"""doggonet CLI - Datadog dashboard management with Jsonnet."""

import json
import sys
from pathlib import Path

import click
from rich.console import Console
from rich.table import Table

from doggonet.client import DatadogDashboardClient
from doggonet.utils.jsonnet import compile_jsonnet, is_jsonnet_file, load_dashboard

console = Console()


@click.group()
@click.version_option(version="0.1.0")
def main():
    """doggonet - Datadog dashboard templating with Jsonnet.

    Create, manage, and deploy Datadog dashboards using Jsonnet templates.
    """
    pass


@main.command()
@click.argument("source", type=click.Path(exists=True, path_type=Path))
@click.option("--dry-run", is_flag=True, help="Validate without pushing")
@click.option("--api-key", envvar="DD_API_KEY", help="Datadog API key")
@click.option("--app-key", envvar="DD_APP_KEY", help="Datadog application key")
@click.option("--site", envvar="DD_SITE", default="datadoghq.com", help="Datadog site")
def push(source: Path, dry_run: bool, api_key: str | None, app_key: str | None, site: str):
    """Push a dashboard to Datadog.

    SOURCE can be a .jsonnet or .json file.
    """
    try:
        # Load dashboard
        with console.status(f"Loading {source.name}..."):
            dashboard_json = load_dashboard(source)

        title = dashboard_json.get("title", "Unknown")
        dashboard_id = dashboard_json.get("id")

        # Create client
        client = DatadogDashboardClient(api_key=api_key, app_key=app_key, site=site)

        if dry_run:
            if dashboard_id and client.dashboard_exists(dashboard_id):
                console.print(f"[yellow][DRY RUN] Would UPDATE: {title} (ID: {dashboard_id})[/yellow]")
            else:
                console.print(f"[yellow][DRY RUN] Would CREATE: {title}[/yellow]")
            return

        # Push dashboard
        with console.status(f"Pushing {title}..."):
            if dashboard_id and client.dashboard_exists(dashboard_id):
                result = client.update_dashboard(dashboard_id, dashboard_json)
                console.print(f"[green]✓ Updated: {title} (ID: {dashboard_id})[/green]")
            else:
                result = client.create_dashboard(dashboard_json)
                new_id = result.get("id", "unknown")
                console.print(f"[green]✓ Created: {title} (ID: {new_id})[/green]")

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


@main.command()
@click.argument("dashboard_id")
@click.option("--output", "-o", type=click.Path(path_type=Path), help="Output file (default: stdout)")
@click.option("--api-key", envvar="DD_API_KEY", help="Datadog API key")
@click.option("--app-key", envvar="DD_APP_KEY", help="Datadog application key")
@click.option("--site", envvar="DD_SITE", default="datadoghq.com", help="Datadog site")
def fetch(dashboard_id: str, output: Path | None, api_key: str | None, app_key: str | None, site: str):
    """Fetch a dashboard from Datadog.

    DASHBOARD_ID is the Datadog dashboard ID.
    """
    try:
        client = DatadogDashboardClient(api_key=api_key, app_key=app_key, site=site)

        with console.status(f"Fetching dashboard {dashboard_id}..."):
            dashboard_json = client.get_dashboard(dashboard_id)

        # Output
        json_str = json.dumps(dashboard_json, indent=2)

        if output:
            output.write_text(json_str)
            console.print(f"[green]✓ Saved to {output}[/green]")
        else:
            console.print(json_str)

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


@main.command()
@click.argument("dashboard_id")
@click.option("--yes", "-y", is_flag=True, help="Skip confirmation")
@click.option("--api-key", envvar="DD_API_KEY", help="Datadog API key")
@click.option("--app-key", envvar="DD_APP_KEY", help="Datadog application key")
@click.option("--site", envvar="DD_SITE", default="datadoghq.com", help="Datadog site")
def delete(dashboard_id: str, yes: bool, api_key: str | None, app_key: str | None, site: str):
    """Delete a dashboard from Datadog.

    DASHBOARD_ID is the Datadog dashboard ID.
    """
    try:
        client = DatadogDashboardClient(api_key=api_key, app_key=app_key, site=site)

        # Get dashboard title for confirmation
        dashboard_json = client.get_dashboard(dashboard_id)
        title = dashboard_json.get("title", "Unknown")

        if not yes:
            if not click.confirm(f"Delete dashboard '{title}' (ID: {dashboard_id})?"):
                console.print("[yellow]Cancelled[/yellow]")
                return

        with console.status(f"Deleting {title}..."):
            client.delete_dashboard(dashboard_id)

        console.print(f"[green]✓ Deleted: {title}[/green]")

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


@main.command()
@click.option("--api-key", envvar="DD_API_KEY", help="Datadog API key")
@click.option("--app-key", envvar="DD_APP_KEY", help="Datadog application key")
@click.option("--site", envvar="DD_SITE", default="datadoghq.com", help="Datadog site")
def list(api_key: str | None, app_key: str | None, site: str):
    """List all dashboards in Datadog."""
    try:
        client = DatadogDashboardClient(api_key=api_key, app_key=app_key, site=site)

        with console.status("Fetching dashboards..."):
            dashboards = client.list_dashboards()

        # Create table
        table = Table(title="Datadog Dashboards")
        table.add_column("ID", style="cyan")
        table.add_column("Title", style="green")
        table.add_column("URL", style="blue")

        for dashboard in dashboards:
            table.add_row(dashboard.get("id", ""), dashboard.get("title", ""), dashboard.get("url", ""))

        console.print(table)
        console.print(f"\n[green]Total: {len(dashboards)} dashboards[/green]")

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


@main.command()
@click.argument("source", type=click.Path(exists=True, path_type=Path))
@click.option("--output", "-o", type=click.Path(path_type=Path), help="Output file (default: stdout)")
def compile(source: Path, output: Path | None):
    """Compile a Jsonnet file to JSON.

    SOURCE must be a .jsonnet file.
    """
    try:
        if not is_jsonnet_file(source):
            console.print(f"[red]✗ Error: {source} is not a Jsonnet file[/red]")
            sys.exit(1)

        with console.status(f"Compiling {source.name}..."):
            dashboard_json = compile_jsonnet(source)

        json_str = json.dumps(dashboard_json, indent=2)

        if output:
            output.write_text(json_str)
            console.print(f"[green]✓ Compiled to {output}[/green]")
        else:
            console.print(json_str)

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


@main.command()
@click.argument("source", type=click.Path(exists=True, path_type=Path))
def view(source: Path):
    """View a dashboard locally (compile and display).

    SOURCE can be a .jsonnet or .json file.
    """
    try:
        with console.status(f"Loading {source.name}..."):
            dashboard_json = load_dashboard(source)

        # Display dashboard info
        console.print("\n[bold]Dashboard Preview[/bold]")
        console.print(f"[cyan]Title:[/cyan] {dashboard_json.get('title', 'Unknown')}")
        console.print(f"[cyan]Description:[/cyan] {dashboard_json.get('description', 'N/A')}")

        layout = dashboard_json.get("layout_type", "Unknown")
        console.print(f"[cyan]Layout:[/cyan] {layout}")

        widgets = dashboard_json.get("widgets", [])
        console.print(f"[cyan]Widgets:[/cyan] {len(widgets)}")

        # Display widget summary
        if widgets:
            console.print("\n[bold]Widget Summary:[/bold]")
            for i, widget in enumerate(widgets, 1):
                definition = widget.get("definition", {})
                widget_type = definition.get("type", "unknown")
                widget_title = definition.get("title", "Untitled")
                console.print(f"  {i}. [{widget_type}] {widget_title}")

    except Exception as e:
        console.print(f"[red]✗ Error: {e}[/red]")
        sys.exit(1)


if __name__ == "__main__":
    main()
