resource "azurerm_private_endpoint" "postgre_pep" {
  count = var.delegated_subnet_id == null ? 1 : 0

  name                = provider::dx::resource_name(merge(local.naming_config, { resource_type = "postgre_private_endpoint" }))
  location            = var.environment.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_pep_id

  private_service_connection {
    name                           = provider::dx::resource_name(merge(local.naming_config, { resource_type = "postgre_private_endpoint" }))
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.postgre_dns_zone.id]
  }

  tags = local.tags
}

# For backward compatibility, we keep the old output structure.
# Remove this in the next major version.
moved {
  from = azurerm_private_endpoint.postgre_pep
  to   = azurerm_private_endpoint.postgre_pep[0]
}

#--------------------------#
# Replica Private Endpoint #
#--------------------------#

resource "azurerm_private_endpoint" "replica_postgre_pep" {
  count = var.tier == "l" && var.delegated_subnet_id == null ? 1 : 0

  name                = provider::dx::resource_name(merge(local.naming_config, { resource_type = "postgre_replica_private_endpoint" }))
  location            = var.environment.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_pep_id

  private_service_connection {
    name                           = provider::dx::resource_name(merge(local.naming_config, { resource_type = "postgre_replica_private_endpoint" }))
    private_connection_resource_id = azurerm_postgresql_flexible_server.replica[0].id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.postgre_dns_zone.id]
  }

  tags = local.tags
}
