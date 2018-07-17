# Changelog

## [TODO]
### Add
- Add parameter "priorities" to inventory.sort_items_by_id
- Add feature to slot allowing better control of item position
- Export item properties when next godot supports dictionary exports
- Start save systems
- Add property to slot only allowing certain items by id or category
### On Next Godot Release
- Use add_autoload_singleton and remove_autoload_singleton with InventoryController
- Add variables to InventoryController to optomize gui inputs such as items with mouse_over

# [Pre-Release]

### Add
- Add left_click_drag to item
- Add mouse_down_drop in favor of hold_to_drag for setting the items to drop when mouse is released or mouse_down
- Add "Offset" mode to item.drag_mode where it drags at an offset to the mouse
- Add sort_items_by_id to inventory
### Remove
- Remove draggable in favor of left_click_drag
### Change
- Change "Position" mode in item.drag_mode to a set position on the screen
### Fix
- Fix bug where item is moved to the same slot in slot.move_item and slot.swap_items causes error in slot.set_item

## [0.3.0] - 2018/6/14
### Added
- Add amount parameter to inventory.remove_item and slot.remove_item for removing only a certain amount of the item
- Add export item.lock_inventory and inventory.items_locked to prevent item from swapping inventories
- Add right_click_drop_single to inventory.item for dropping one item while dragging
- Add property "disabled" to inventory nodes preventing item from recieving input
- Add overide methods for hide and show to also hide the inventory items
- Add reversed optional parameter to inventory.find_item() to search backwards
- Add optional id parameter to inventory.remove_all_items() to remove all items of a certain id
### Changed
- Change item.id to only allow positive integers
- Change inventory.add_items to add_items_array to set apart from inventory.add_item
- Change inventory.add_item "stack_first" parameter to default false
### Fixed
- Fix items not moving when the inventory or slot is moved
- Fix slot.visible and item.visible not changed when inventory.visible is changed
- Fix item with null item.slot swapped with an item with a slot stopping the item from dragging

## [0.2.1] - 2018/5/27
### Added
- Add _update_rect method to inventory for prevent the rect from being smaller than its child slots
### Changed
- Change offset, separation, and columns variables in inventory to start with slots_ for consistency and update their set methods
### Fixed
- Fix slots_columns allowed to be negative or 0
- Fix error when dragging item out of slot onto an inventory rect that is not overlapping a slot rect

## [0.2.0] - 2018/5/24
### Added
- Add __sort_children method to inventory that sorts the child slots of the inventory
- Add columns variable for sorting the slots into columns
- Add separation variable for spacing the slots out
- Add offset variable for offseting the slots from the rect_position
- Add drop_ignore_rect to inventory for ignoring the inventory rect when dropping items from inventory
- Add method to set debug mode of all inventory nodes to inventory_controller
### Changed
- Change inventory to inherit Container instead of GridContainer due to lack of customization such as slots offset
### Fixed
- Fix find_item edge case not handled correctly
- Fix moving slot in inventory sends removed_item signal
- Fix setting CustomSlot to an incorrect type

## [0.1.1] - 2018/5/22
### Fixed
- Fix problem when hold_to_drag is used and item is split that prevents further input until RMB is pressed
- Fix problem with dead_zone_radius not applied to right_click_split
- Fix problem with item able to be stacked with item outside of slot while allow_outside_slot is false
- Fix problem with split item returning to stack even if allow_outside_slot is true
- Fix problem with splitting an item and swapping not allowing item to be swapped again
- Fix problem with adding item to stack of item outside of inventory not removing item from reference array inventory.items

## [0.1.0] - 2018/5/22
### Added
- Add is_target method to item
- Add public methods first_item, last_item, get_item, is_empty, has_item, remove_item, and find_item to inventory
### Fixed
- Fix problem when removing an item from inventory not properly removed from reference array inventory.items
- Fix problem when stacking items not propery removing the dropped item from reference array inventory.items