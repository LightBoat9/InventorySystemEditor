# Changelog

## [TODO]
### Add

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