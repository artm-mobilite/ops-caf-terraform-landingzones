output "objects" {
  value = merge(
    tomap(
      {
        (var.landingzone.key) = {
          "vnets" = {
            for key, value in module.enterprise_scale.azurerm_virtual_network.connectivity : value.location => merge(value, { subnets = { for subnet in value.subnet : subnet.name => subnet } })
          }
          "virtual_subnets" = {
            for key, value in module.enterprise_scale.azurerm_subnet.connectivity : value.name => value
          }
          "azurerm_firewalls" = {
            for key, value in module.enterprise_scale.azurerm_firewall.connectivity : value.location => value
          }
          "azurerm_firewall_policies" = {
            for key, value in module.enterprise_scale.azurerm_firewall_policy.connectivity : value.location => value
          }
          # fix: terraform-azurerm-caf supermodule reads remote_objects.private_dns not private_dns_zones. Keep private_dns_zones for backward compatibility
          "private_dns_zones" = {
            for key, value in module.enterprise_scale.azurerm_private_dns_zone.connectivity : value.name => value
          }
          "private_dns" = {
            for key, value in module.enterprise_scale.azurerm_private_dns_zone.connectivity : value.name => value
          }
          #
          "resource_groups" = {
            for key, value in flatten([for zone_key, zone_value in module.enterprise_scale.azurerm_resource_group : [for rg_key, rg_value in zone_value : rg_value] if zone_value != {}]) : value.name => value
          }
          "virtual_network_gateways" = {
            for key, value in module.enterprise_scale.azurerm_virtual_network_gateway.connectivity : value.name => value
          }
        }
      }
    ),
    module.enterprise_scale
  )
  sensitive = true
}

output "custom_landing_zones" {
  value = local.custom_landing_zones
}