"""Stream type classes for tap-adventureworks."""

from __future__ import annotations

from importlib import resources

from tap_adventureworks.client import AdventureWorksStream

# TODO: Delete this is if not using json files for schema definition
SCHEMAS_DIR = resources.files(__package__) / "schemas"
# TODO: - Override `UsersStream` and `GroupsStream` with your own stream def.
#       - Copy-paste as many times as needed to create multiple stream types.


class PurchaseOrderHeaderStream(AdventureWorksStream):
    name = "purchaseorderheader"
    path = "/PurchaseOrderHeader"
    schema_filepath = SCHEMAS_DIR / "purchaseorderheader.json"


class PurchaseOrderDetailStream(AdventureWorksStream):
    name = "purchaseorderdetail"
    path = "/PurchaseOrderDetail"
    schema_filepath = SCHEMAS_DIR / "purchaseorderdetail.json"


class SalesOrderHeaderStream(AdventureWorksStream):
    name = "salesorderheader"
    path = "/SalesOrderHeader"
    schema_filepath = SCHEMAS_DIR / "salesorderheader.json"


class SalesOrderDetailStream(AdventureWorksStream):
    name = "salesorderdetail"
    path = "/SalesOrderDetail"
    schema_filepath = SCHEMAS_DIR / "salesorderdetail.json"