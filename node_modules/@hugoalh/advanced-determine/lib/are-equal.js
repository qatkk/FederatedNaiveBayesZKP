const $isPlainObject = require("./internal/is-plain-object.js");
const assert = require("assert");
const typeOf = require("./type-of.js");
/**
 * @private
 * @function $compareObjectProperties
 * @param {object} item1
 * @param {object} item2
 * @returns {boolean}
 */
function $compareObjectProperties(item1, item2) {
	if (!$areEqual(Object.getPrototypeOf(item1), Object.getPrototypeOf(item2))) {
		return false;
	};
	let item1SymbolKeys = Object.getOwnPropertySymbols(item1);
	let item2SymbolKeys = Object.getOwnPropertySymbols(item2);
	if (item1SymbolKeys.length !== item2SymbolKeys.length) {
		return false;
	};
	for (let item1SymbolKey of item1SymbolKeys) {
		if (
			!item2SymbolKeys.includes(item1SymbolKey) ||
			!$areEqual(item1[item1SymbolKey], item2[item1SymbolKey])
		) {
			return false;
		};
	};
	let item1Descriptors = Object.getOwnPropertyDescriptors(item1);
	let item2Descriptors = Object.getOwnPropertyDescriptors(item2);
	if (Object.entries(item1Descriptors).length !== Object.entries(item2Descriptors).length) {
		return false;
	};
	let item1ConfigurableEntries = [];
	let item1EnumerableEntries = [];
	let item1GetterEntries = [];
	let item1NonAccessorEntries = [];
	let item1NonConfigurableEntries = [];
	let item1NonEnumerableEntries = [];
	let item1NonWritableEntries = [];
	let item1SetterEntries = [];
	let item1WritableEntries = [];
	let item2ConfigurableEntries = [];
	let item2EnumerableEntries = [];
	let item2GetterEntries = [];
	let item2NonAccessorEntries = [];
	let item2NonConfigurableEntries = [];
	let item2NonEnumerableEntries = [];
	let item2NonWritableEntries = [];
	let item2SetterEntries = [];
	let item2WritableEntries = [];
	for (let item1Property in item1Descriptors) {
		if (Object.prototype.hasOwnProperty.call(item1Descriptors, item1Property)) {
			let item1PropertyDescriptor = item1Descriptors[item1Property];
			if (item1PropertyDescriptor.configurable) {
				item1ConfigurableEntries.push(item1Property);
			} else {
				item1NonConfigurableEntries.push(item1Property);
			};
			if (item1PropertyDescriptor.enumerable) {
				item1EnumerableEntries.push(item1Property);
			} else {
				item1NonEnumerableEntries.push(item1Property);
			};
			if (typeof item1PropertyDescriptor.get !== "undefined") {
				item1GetterEntries.push(item1Property);
			} else if (typeof item1PropertyDescriptor.set !== "undefined") {
				item1SetterEntries.push(item1Property);
			} else {
				item1NonAccessorEntries.push(item1Property);
			};
			if (item1PropertyDescriptor.writable) {
				item1WritableEntries.push(item1Property);
			} else {
				item1NonWritableEntries.push(item1Property);
			};
		};
	};
	for (let item2Property in item2Descriptors) {
		if (Object.prototype.hasOwnProperty.call(item2Descriptors, item2Property)) {
			let item2PropertyDescriptor = item2Descriptors[item2Property];
			if (item2PropertyDescriptor.configurable) {
				item2ConfigurableEntries.push(item2Property);
			} else {
				item2NonConfigurableEntries.push(item2Property);
			};
			if (item2PropertyDescriptor.enumerable) {
				item2EnumerableEntries.push(item2Property);
			} else {
				item2NonEnumerableEntries.push(item2Property);
			};
			if (typeof item2PropertyDescriptor.get !== "undefined") {
				item2GetterEntries.push(item2Property);
			} else if (typeof item2PropertyDescriptor.set !== "undefined") {
				item2SetterEntries.push(item2Property);
			} else {
				item2NonAccessorEntries.push(item2Property);
			};
			if (item2PropertyDescriptor.writable) {
				item2WritableEntries.push(item2Property);
			} else {
				item2NonWritableEntries.push(item2Property);
			};
		};
	};
	if (
		item1ConfigurableEntries.length !== item2ConfigurableEntries.length ||
		item1EnumerableEntries.length !== item2EnumerableEntries.length ||
		item1GetterEntries.length !== item2GetterEntries.length ||
		item1NonAccessorEntries.length !== item2NonAccessorEntries.length ||
		item1NonConfigurableEntries.length !== item2NonConfigurableEntries.length ||
		item1NonEnumerableEntries.length !== item2NonEnumerableEntries.length ||
		item1NonWritableEntries.length !== item2NonWritableEntries.length ||
		item1SetterEntries.length !== item2SetterEntries.length ||
		item1WritableEntries.length !== item2WritableEntries.length
	) {
		return false;
	};
	for (let item1ConfigurableEntry of item1ConfigurableEntries) {
		if (!item2ConfigurableEntries.includes(item1ConfigurableEntry)) {
			return false;
		};
	};
	for (let item1EnumerableEntry of item1EnumerableEntries) {
		if (!item2EnumerableEntries.includes(item1EnumerableEntry)) {
			return false;
		};
	};
	for (let item1GetterEntry of item1GetterEntries) {
		if (
			!item2GetterEntries.includes(item1GetterEntry) ||
			!$areEqual(item1[item1GetterEntry], item2[item1GetterEntry])
		) {
			return false;
		};
	};
	for (let item1NonAccessorEntry of item1NonAccessorEntries) {
		if (
			!item2NonAccessorEntries.includes(item1NonAccessorEntry) ||
			!$areEqual(item1[item1NonAccessorEntry], item2[item1NonAccessorEntry])
		) {
			return false;
		};
	};
	for (let item1NonConfigurableEntry of item1NonConfigurableEntries) {
		if (!item2NonConfigurableEntries.includes(item1NonConfigurableEntry)) {
			return false;
		};
	};
	for (let item1NonEnumerableEntry of item1NonEnumerableEntries) {
		if (!item2NonEnumerableEntries.includes(item1NonEnumerableEntry)) {
			return false;
		};
	};
	for (let item1NonWritableEntry of item1NonWritableEntries) {
		if (!item2NonWritableEntries.includes(item1NonWritableEntry)) {
			return false;
		};
	};
	for (let item1SetterEntry of item1SetterEntries) {
		if (
			!item2SetterEntries.includes(item1SetterEntry) ||
			!$areEqual(item1[item1SetterEntry], item2[item1SetterEntry])
		) {
			return false;
		};
	};
	for (let item1WritableEntry of item1WritableEntries) {
		if (!item2WritableEntries.includes(item1WritableEntry)) {
			return false;
		};
	};
	return true;
};
/**
 * @private
 * @function $areEqual
 * @param {any} item1
 * @param {any} item2
 * @returns {boolean}
 */
function $areEqual(item1, item2) {
	if (item1 === item2) {
		return true;
	};
	let item1TypeOf = typeOf(item1);
	let item2TypeOf = typeOf(item2);
	if (
		item1TypeOf !== item2TypeOf ||
		item1TypeOf === "bigint" ||
		item1TypeOf === "boolean" ||
		item1TypeOf === "nan" ||
		item1TypeOf === "null" ||
		item1TypeOf === "number" ||
		item1TypeOf === "string" ||
		item1TypeOf === "symbol" ||
		item1TypeOf === "undefined"
	) {
		return false;
	};
	if (item1TypeOf === "array") {
		if (Object.entries(item1).length !== Object.entries(item2).length) {
			return false;
		};
		return $compareObjectProperties(item1, item2);
	};
	if (item1TypeOf === "object" && item1 instanceof Map && item2 instanceof Map) {
		if (item1.size !== item2.size) {
			return false;
		};
		let item1Entries = item1.entries();
		if ($areEqual(Array.from(item1Entries), Array.from(item2.entries()))) {
			return true;
		};
		let item2Keys = Array.from(item2.keys());
		let item2Values = Array.from(item2.values());
		for (let [item1Key, item1Value] of item1Entries) {
			let matchItem2KeysIndexes = [];
			item2Keys.forEach((item2Key, item2KeysIndex) => {
				if (
					(typeOf(item1Key) === "nan" && typeOf(item2Key) === "nan") ||
					$areEqual(item1Key, item2Key)
				) {
					matchItem2KeysIndexes.push(item2KeysIndex);
				};
			});
			if (matchItem2KeysIndexes.length === 0) {
				return false;
			};
			if (!matchItem2KeysIndexes.some((matchItem2KeysIndex) => {
				let matchItem2Value = item2Values[matchItem2KeysIndex];
				return (
					(typeOf(item1Value) === "nan" && typeOf(matchItem2Value) === "nan") ||
					$areEqual(item1Value, matchItem2Value)
				);
			})) {
				return false;
			};
		};
		return true;
	};
	if (item1TypeOf === "regexp") {
		if (
			item1.flags !== item2.flags ||
			item1.source !== item2.source
		) {
			return false;
		};
		return true;
	};
	if (item1TypeOf === "object" && item1 instanceof Set && item2 instanceof Set) {
		if (item1.size !== item2.size) {
			return false;
		};
		let item1Values = item1.values();
		let item2Values = item2.values();
		if ($areEqual(Array.from(item1Values), Array.from(item2Values))) {
			return true;
		};
		for (let item1Value of item1Values) {
			let matchItem2Values = [];
			for (let item2Value of item2Values) {
				if (
					(typeOf(item1Value) === "nan" && typeOf(item2Value) === "nan") ||
					$areEqual(item1Value, item2Value)
				) {
					matchItem2Values.push(item2Value);
				};
			};
			if (matchItem2Values.length === 0) {
				return false;
			};
		};
		return true;
	};
	let item1IsPlainObject = $isPlainObject(item1, { maximumEntries: Infinity, minimumEntries: 0 });
	let item2IsPlainObject = $isPlainObject(item2, { maximumEntries: Infinity, minimumEntries: 0 });
	if (item1IsPlainObject && item2IsPlainObject) {
		if (Object.entries(item1).length !== Object.entries(item2).length) {
			return false;
		};
		return $compareObjectProperties(item1, item2);
	};
	try {
		assert.notDeepStrictEqual(item1, item2);
	} catch {
		return true;
	};
	return false;
};
/**
 * @function areEqual
 * @description Determine items are equal or not.
 * @param {...any} items Items that need to determine.
 * @returns {boolean} Determine result.
 */
function areEqual(...items) {
	let itemLength = items.length;
	switch (itemLength) {
		case 0:
			throw new Error(`Argument \`items\` is not defined!`);
		case 1:
		case 2:
			return $areEqual(...items);
		default:
			for (let index = 0; index < itemLength - 1; index++) {
				if (!$areEqual(items[index], items[index + 1])) {
					return false;
				};
			};
			return true;
	};
};
module.exports = areEqual;
