# Changelog

## [TODO]
### Add
- Start planning public methods and add more testing

## [Unreleased]

# [Pre-Release]

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