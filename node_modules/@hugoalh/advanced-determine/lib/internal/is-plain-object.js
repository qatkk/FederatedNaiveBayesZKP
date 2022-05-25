const isObject = require("../is-object.js");
/**
 * @private
 * @function $isPlainObject
 * @param {any} item
 * @returns {boolean}
 */
function $isPlainObject(item, { configurableEntries, enumerableEntries, getterEntries, maximumEntries, minimumEntries, setterEntries, symbolKeys, writableEntries }) {
	if (
		!isObject(item) ||
		!(item instanceof Object) ||
		item.constructor.name !== "Object" ||
		Object.prototype.toString.call(item) !== "[object Object]"
	) {
		return false;
	};
	let itemPrototype = Object.getPrototypeOf(item);
	if (itemPrototype !== null && itemPrototype !== Object.prototype) {
		return false;
	};
	let itemShadow = item;
	while (Object.getPrototypeOf(itemShadow) !== null) {
		itemShadow = Object.getPrototypeOf(itemShadow);
	};
	if (itemPrototype !== itemShadow) {
		return false;
	};
	let itemSymbolKeysLength = Object.getOwnPropertySymbols(item).length;
	if (
		(symbolKeys === false && itemSymbolKeysLength > 0) ||
		(symbolKeys === true && itemSymbolKeysLength === 0)
	) {
		return false;
	};
	let itemDescriptors = Object.getOwnPropertyDescriptors(item);
	let itemConfigurableEntriesLength = 0;
	let itemEnumerableEntriesLength = 0;
	let itemGetterEntriesLength = 0;
	let itemNonAccessorEntriesLength = 0;
	let itemNonConfigurableEntriesLength = 0;
	let itemNonEnumerableEntriesLength = 0;
	let itemNonWritableEntriesLength = 0;
	let itemSetterEntriesLength = 0;
	let itemWritableEntriesLength = 0;
	for (let itemPropertyKey in itemDescriptors) {
		if (Object.prototype.hasOwnProperty.call(itemDescriptors, itemPropertyKey)) {
			let itemPropertyDescriptor = itemDescriptors[itemPropertyKey];
			if (itemPropertyDescriptor.configurable) {
				itemConfigurableEntriesLength += 1;
			} else {
				itemNonConfigurableEntriesLength += 1;
			};
			if (itemPropertyDescriptor.enumerable) {
				itemEnumerableEntriesLength += 1;
			} else {
				itemNonEnumerableEntriesLength += 1;
			};
			if (typeof itemPropertyDescriptor.get !== "undefined") {
				itemGetterEntriesLength += 1;
			} else if (typeof itemPropertyDescriptor.set !== "undefined") {
				itemSetterEntriesLength += 1;
			} else {
				itemNonAccessorEntriesLength += 1;
			};
			if (itemPropertyDescriptor.writable) {
				itemWritableEntriesLength += 1;
			} else {
				itemNonWritableEntriesLength += 1;
			};
		};
	};
	if (
		Object.entries(item).length !== itemEnumerableEntriesLength ||
		itemConfigurableEntriesLength + itemNonConfigurableEntriesLength !== itemEnumerableEntriesLength + itemNonEnumerableEntriesLength ||
		itemEnumerableEntriesLength + itemNonEnumerableEntriesLength !== itemGetterEntriesLength + itemNonAccessorEntriesLength + itemSetterEntriesLength ||
		itemGetterEntriesLength + itemNonAccessorEntriesLength + itemSetterEntriesLength !== itemNonWritableEntriesLength + itemWritableEntriesLength ||
		itemConfigurableEntriesLength + itemNonConfigurableEntriesLength !== itemNonWritableEntriesLength + itemWritableEntriesLength ||
		maximumEntries < itemGetterEntriesLength + itemNonAccessorEntriesLength + itemSetterEntriesLength + itemSymbolKeysLength ||
		itemGetterEntriesLength + itemNonAccessorEntriesLength + itemSetterEntriesLength + itemSymbolKeysLength < minimumEntries ||
		(configurableEntries === false && itemConfigurableEntriesLength > 0) ||
		(configurableEntries === true && itemNonConfigurableEntriesLength > 0) ||
		(enumerableEntries === false && itemEnumerableEntriesLength > 0) ||
		(enumerableEntries === true && itemNonEnumerableEntriesLength > 0) ||
		(getterEntries === false && itemGetterEntriesLength > 0) ||
		(setterEntries === false && itemSetterEntriesLength > 0) ||
		((
			getterEntries === true ||
			setterEntries === true
		) && itemNonAccessorEntriesLength > 0) ||
		(writableEntries === false && itemWritableEntriesLength > 0) ||
		(writableEntries === true && itemNonWritableEntriesLength > 0)
	) {
		return false;
	};
	return true;
};
module.exports = $isPlainObject;
