class ManageIQ::Providers::Vmware::InfraManager::Inventory::Persister < ManagerRefresh::Inventory::Persister
  def initialize_inventory_collections
    add_inventory_collections(
      default_inventory_collections, inventory_collection_names, inventory_collection_options
    )

    relationship_collections = %i(ems_clusters ems_folders hosts resource_pools storages)
    dependency_attributes = relationship_collections.each_with_object({}) do |collection_key, obj|
      obj[collection_key] = [collections[collection_key]]
    end

    add_inventory_collection(
      default_inventory_collections.parent_blue_folders(:dependency_attributes => dependency_attributes)
    )

    add_inventory_collection(
      default_inventory_collections.vm_parent_blue_folders(
        :dependency_attributes => {:vms_and_templates => [collections[:vms_and_templates]]},
      )
    )

    add_inventory_collection(
      default_inventory_collections.vm_resource_pools(
        :dependency_attributes => {:vms_and_templates => [collections[:vms_and_templates]]},
      )
    )

    add_inventory_collection(
      default_inventory_collections.root_folder_relationship(
        :dependency_attributes => {:ems_folders => [collections[:ems_folders]]},
      )
    )

    add_inventory_collection(
      default_inventory_collections.snapshot_parent(
        :dependency_attributes => {:snapshots => [collections[:snapshots]]},
      )
    )
  end

  def default_inventory_collections
    ManageIQ::Providers::Vmware::InfraManager::Inventory::InventoryCollections
  end

  def inventory_collection_names
    %i(
      custom_attributes
      customization_specs
      disks
      ems_clusters
      ems_folders
      guest_devices
      hardwares
      hosts
      host_guest_devices
      host_hardwares
      host_networks
      host_storages
      host_switches
      host_system_services
      host_operating_systems
      lans
      miq_scsi_luns
      miq_scsi_targets
      networks
      operating_systems
      resource_pools
      snapshots
      storages
      storage_profiles
      switches
      vms_and_templates
    )
  end

  def complete
    true
  end

  def saver_strategy
    :default
  end

  def strategy
    nil
  end

  def targeted
    false
  end

  def inventory_collection_options
    {
      :complete       => complete,
      :saver_strategy => saver_strategy,
      :strategy       => strategy,
      :targeted       => targeted,
    }
  end

  def vim_class_to_collection(managed_object)
    case managed_object
    when RbVmomi::VIM::ComputeResource
      ems_clusters
    when RbVmomi::VIM::Datacenter
      ems_folders
    when RbVmomi::VIM::HostSystem
      hosts
    when RbVmomi::VIM::Folder
      ems_folders
    when RbVmomi::VIM::ResourcePool
      resource_pools
    end
  end
end
