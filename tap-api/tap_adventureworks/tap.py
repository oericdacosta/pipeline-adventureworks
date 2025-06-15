"""AdventureWorks tap class."""

from __future__ import annotations

from singer_sdk import Tap
from singer_sdk import typing as th  # JSON schema typing helpers

# TODO: Import your custom stream types here:
from tap_adventureworks import streams


class TapAdventureWorks(Tap):
    """AdventureWorks tap class."""

    name = "tap-adventureworks"

    # TODO: Update this section with the actual config values you expect:
    config_jsonschema = th.PropertiesList().to_dict()

    def discover_streams(self) -> list[streams.AdventureWorksStream]:
        """Return a list of discovered streams.

        Returns:
            A list of discovered streams.
        """
        return [
            # streams.SalesOrderDetailStream(self),
            streams.SalesOrderHeaderStream(self),
            # streams.PurchaseOrderHeaderStream(self),
            streams.PurchaseOrderDetailStream(self),
        ]


if __name__ == "__main__":
    TapAdventureWorks.cli()
