import $isNumber from "./internal/is-number.mjs";
import undefinish from "@hugoalh/undefinish";
/**
 * @function isArray
 * @alias isArr
 * @alias isList
 * @description Determine item is type of array or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty array.
 * @param {number} [param1.maximumLength=Infinity] Maximum length of the array.
 * @param {number} [param1.minimumLength=0] Minimum length of the array.
 * @param {boolean} [param1.strict=false] Ensure no custom defined properties in the array.
 * @param {boolean} [param1.unique=false] Elements must be unique in the array.
 * @returns {boolean} Determine result.
 */
function isArray(item, {
	empty,
	maximumLength,
	minimumLength,
	strict,
	unique = false,
	...aliases
} = {}) {
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	maximumLength = undefinish(maximumLength, aliases.maxLength, aliases.maximumElements, aliases.maxElements, Infinity);
	if (maximumLength !== Infinity && !$isNumber(maximumLength, {
		integer: true,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`maximumLength\` must be \`Infinity\` or type of number (integer, positive, and safe)!`);
	}
	minimumLength = undefinish(minimumLength, aliases.minLength, aliases.minimumElements, aliases.minElements, 0);
	if (!$isNumber(minimumLength, {
		integer: true,
		maximum: maximumLength,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`minimumLength\` must be type of number (integer, positive, and safe) and <= ${maximumLength}!`);
	}
	strict = undefinish(strict, aliases.super, false);
	if (typeof strict !== "boolean") {
		throw new TypeError(`Argument \`strict\` must be type of boolean!`);
	}
	if (typeof unique !== "boolean") {
		throw new TypeError(`Argument \`unique\` must be type of boolean!`);
	}
	if (empty === false) {
		maximumLength = Infinity;
		minimumLength = 1;
	} else if (empty === true) {
		maximumLength = 0;
		minimumLength = 0;
	}
	if (
		!Array.isArray(item) ||
		!(item instanceof Array) ||
		item.constructor.name !== "Array" ||
		Object.prototype.toString.call(item) !== "[object Array]"
	) {
		return false;
	}
	if (Object.entries(item).length !== item.length) {
		return false;
	}
	if (strict) {
		let itemPrototype = Object.getPrototypeOf(item);
		if (itemPrototype !== null && itemPrototype !== Array.prototype) {
			return false;
		}
		if (Object.getOwnPropertySymbols(item).length > 0) {
			return false;
		}
		let itemDescriptors = Object.getOwnPropertyDescriptors(item);
		for (let itemPropertyKey in itemDescriptors) {
			if (Object.prototype.hasOwnProperty.call(itemDescriptors, itemPropertyKey)) {
				if (itemPropertyKey.search(/^(?:0|[1-9]\d*)$/gu) === 0 && Number(itemPropertyKey) < 4294967296) {
					let itemPropertyDescriptor = itemDescriptors[itemPropertyKey];
					if (
						!itemPropertyDescriptor.configurable ||
						!itemPropertyDescriptor.enumerable ||
						typeof itemPropertyDescriptor.get !== "undefined" ||
						typeof itemPropertyDescriptor.set !== "undefined" ||
						!itemPropertyDescriptor.writable
					) {
						return false;
					}
				} else if (itemPropertyKey === "length") {
					let itemPropertyDescriptor = itemDescriptors[itemPropertyKey];
					if (
						itemPropertyDescriptor.configurable ||
						itemPropertyDescriptor.enumerable ||
						typeof itemPropertyDescriptor.get !== "undefined" ||
						typeof itemPropertyDescriptor.set !== "undefined" ||
						!itemPropertyDescriptor.writable
					) {
						return false;
					}
				} else {
					return false;
				}
			}
		}
	}
	if (
		maximumLength < item.length ||
		item.length < minimumLength ||
		(unique && Array.from(new Set(item).values()).length < item.length)
	) {
		return false;
	}
	return true;
}
export default isArray;
