extends Object

var items = []

## Add an item to the set. Return true if the item was added.
## Return false if the item was already in the set.
func add(item) -> bool:
	if contains(item):
		return false
	items.push_back(item)
	return true

## Remove an item from the set. Return the item if it was removed.
func remove(item) -> Object:
	if contains(item):
		return items.pop_at(items.find(item))
	return null

func contains(item) -> bool:
	return item in items

func to_list() -> Array:
	return self.items

