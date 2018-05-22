# Changelog

## [TODO]
### Fixed
- Fix problem with splitting an item and swapping not allowing item to be swapped again

## [0.1.0] - 2018/5/22
### Added
- Add is_target method to item
- Add public methods first_item, last_item, get_item, is_empty, has_item, remove_item, and find_item to inventory
### Fixed
- Fix problem when removing an item from inventory not properly removed from reference array inventory.items
- Fix problem when stacking items not propery removing the dropped item from reference array inventory.items