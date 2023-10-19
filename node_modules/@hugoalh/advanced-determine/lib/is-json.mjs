import $isNumber from "./internal/is-number.mjs";
import $isPlainObject from "./internal/is-plain-object.mjs";
import isArray from "./is-array.mjs";
import undefinish from "@hugoalh/undefinish";
/**
 * @private
 * @function $isValidJSONValue
 * @param {any} item
 * @param {object} [param1={}]
 * @param {RegExp} [param1.keysPattern]
 * @returns {boolean}
 */
function $isValidJSONValue(item, { keysPattern } = {}) {
	if (
		typeof item === "boolean" ||
		$isJSON(item, { keysPattern }) ||
		item === null ||
		$isNumber(item) ||
		typeof item === "string"
	) {
		return true;
	}
	return false;
}
/**
 * @private
 * @function $isJSON
 * @param {any} item
 * @param {object} [param1={}]
 * @param {RegExp} [param1.keysPattern]
 * @returns {boolean}
 */
function $isJSON(item, { keysPattern } = {}) {
	if (isArray(item, { strict: true })) {
		for (let itemElement of item) {
			if (!$isValidJSONValue(itemElement, { keysPattern })) {
				return false;
			}
		}
		return true;
	}
	if ($isPlainObject(item, {
		configurableEntries: true,
		enumerableEntries: true,
		getterEntries: false,
		setterEntries: false,
		symbolKeys: false,
		writableEntries: true
	})) {
		try {
			JSON.stringify(item);
		} catch {
			return false;
		}
		for (let itemKey of Object.keys(item)) {
			if (
				(keysPattern instanceof RegExp && itemKey.search(keysPattern) === -1) ||
				!$isValidJSONValue(item[itemKey], keysPattern)
			) {
				return false;
			}
		}
		return true;
	}
	return false;
}
/**
 * @function isJSON
 * @description Determine item is type of JSON or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.arrayRoot] Type of array as the root of the JSON.
 * @param {boolean} [param1.empty] An empty JSON.
 * @param {RegExp} [param1.keysPattern] Ensure pattern in the JSON keys.
 * @param {number} [param1.maximumEntries=Infinity] Maximum entries of the JSON.
 * @param {number} [param1.minimumEntries=0] Minimum entries of the JSON.
 * @param {boolean} [param1.strict=false] Ensure type of array is not as the root of the JSON, and no illegal namespace characters in the JSON keys.
 * @param {boolean} [param1.strictKeys=false] Ensure no illegal namespace characters in the JSON keys.
 * @returns {boolean} Determine result.
 */
function isJSON(item, {
	arrayRoot,
	empty,
	keysPattern,
	maximumEntries,
	minimumEntries,
	strict = false,
	strictKeys = false,
	...aliases
} = {}) {
	if (typeof arrayRoot !== "boolean" && typeof arrayRoot !== "undefined") {
		throw new TypeError(`Argument \`arrayRoot\` must be type of boolean or undefined!`);
	}
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	if (!(keysPattern instanceof RegExp) && typeof keysPattern !== "undefined") {
		throw new TypeError(`Argument \`keysPattern\` must be type of regular expression or undefined!`);
	}
	maximumEntries = undefinish(maximumEntries, aliases.maxEntries, Infinity);
	if (maximumEntries !== Infinity && !$isNumber(maximumEntries, {
		integer: true,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`maximumEntries\` must be \`Infinity\` or type of number (integer, positive, and safe)!`);
	}
	minimumEntries = undefinish(minimumEntries, aliases.minEntries, 0);
	if (!$isNumber(minimumEntries, {
		integer: true,
		maximum: maximumEntries,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`minimumEntries\` must be type of number (integer, positive, and safe) and <= ${maximumEntries}!`);
	}
	if (typeof strict !== "boolean") {
		throw new TypeError(`Argument \`strict\` must be type of boolean!`);
	}
	if (typeof strictKeys !== "boolean") {
		throw new TypeError(`Argument \`strictKeys\` must be type of boolean!`);
	}
	if (empty === false) {
		maximumEntries = Infinity;
		minimumEntries = 1;
	} else if (empty === true) {
		maximumEntries = 0;
		minimumEntries = 0;
	}
	if (strict) {
		arrayRoot = false;
		strictKeys = true;
	}
	if (strictKeys) {
		keysPattern = /^[$_a-z][$\d_a-z]*$/giu;
	}
	let itemEntriesLength = Object.entries(item).length;
	let itemIsArray = Array.isArray(item);
	if (
		!$isJSON(item, { keysPattern }) ||
		(arrayRoot === false && itemIsArray) ||
		(arrayRoot === true && !itemIsArray) ||
		maximumEntries < itemEntriesLength ||
		itemEntriesLength < minimumEntries
	) {
		return false;
	}
	return true;
}
export default isJSON;
