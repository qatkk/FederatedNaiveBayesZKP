import $isNumber from "./internal/is-number.mjs";
import $isPlainObject from "./internal/is-plain-object.mjs";
import undefinish from "@hugoalh/undefinish";
/**
 * @function isPlainObject
 * @alias isDict
 * @alias isDictionary
 * @alias isObjectPlain
 * @alias isObjPlain
 * @alias isPlainObj
 * @description Determine item is type of plain object or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.configurableEntries] Configurable entries in the plain object.
 * @param {boolean} [param1.empty] An empty plain object.
 * @param {boolean} [param1.enumerableEntries] Enumerable entries in the plain object.
 * @param {boolean} [param1.getterEntries] Getter entries in the plain object.
 * @param {number} [param1.maximumEntries=Infinity] Maximum entries of the plain object.
 * @param {number} [param1.minimumEntries=0] Minimum entries of the plain object.
 * @param {boolean} [param1.setterEntries] Setter entries in the plain object.
 * @param {boolean} [param1.strict=false] Ensure no custom defined properties (i.e.: getters, setters, non-configurable, non-enumerable, and non-writable) in the plain object, and no symbols in the plain object keys.
 * @param {boolean} [param1.symbolKeys] Symbols in the plain object keys.
 * @param {boolean} [param1.writableEntries] Writable entries in the plain object.
 * @returns {boolean} Determine result.
 */
function isPlainObject(item, {
	configurableEntries,
	empty,
	enumerableEntries,
	getterEntries,
	maximumEntries,
	minimumEntries,
	setterEntries,
	strict,
	symbolKeys,
	writableEntries,
	...aliases
} = {}) {
	if (typeof getterEntries !== "boolean" && typeof getterEntries !== "undefined") {
		throw new TypeError(`Argument \`getterEntries\` must be type of boolean or undefined!`);
	}
	if (typeof setterEntries !== "boolean" && typeof setterEntries !== "undefined") {
		throw new TypeError(`Argument \`setterEntries\` must be type of boolean or undefined!`);
	}
	if (typeof configurableEntries !== "boolean" && typeof configurableEntries !== "undefined") {
		throw new TypeError(`Argument \`configurableEntries\` must be type of boolean or undefined!`);
	}
	if (typeof enumerableEntries !== "boolean" && typeof enumerableEntries !== "undefined") {
		throw new TypeError(`Argument \`elementsEnumerable\` must be type of boolean or undefined!`);
	}
	if (typeof writableEntries !== "boolean" && typeof writableEntries !== "undefined") {
		throw new TypeError(`Argument \`elementsWritable\` must be type of boolean or undefined!`);
	}
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	if (typeof symbolKeys !== "boolean" && typeof symbolKeys !== "undefined") {
		throw new TypeError(`Argument \`keysSymbols\` must be type of boolean or undefined!`);
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
	strict = undefinish(strict, aliases.super, false);
	if (typeof strict !== "boolean") {
		throw new TypeError(`Argument \`strict\` must be type of boolean!`);
	}
	if (empty === false) {
		maximumEntries = Infinity;
		minimumEntries = 1;
	} else if (empty === true) {
		maximumEntries = 0;
		minimumEntries = 0;
	}
	if (strict) {
		configurableEntries = true;
		enumerableEntries = true;
		getterEntries = false;
		setterEntries = false;
		symbolKeys = false;
		writableEntries = true;
	}
	return $isPlainObject(item, {
		configurableEntries,
		enumerableEntries,
		getterEntries,
		maximumEntries,
		minimumEntries,
		setterEntries,
		symbolKeys,
		writableEntries
	});
}
export default isPlainObject;
