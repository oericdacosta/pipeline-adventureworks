"""AdventureWorks entry point."""

from __future__ import annotations

from tap_adventureworks.tap import TapAdventureWorks

TapAdventureWorks.cli()
