import $isNumber from "./internal/is-number.mjs";
import undefinish from "@hugoalh/undefinish";
/**
 * @function isMap
 * @description Determine item is type of map or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty map.
 * @param {number} [param1.maximumSize=Infinity] Maximum size of the map.
 * @param {number} [param1.minimumSize=0] Minimum size of the map.
 * @returns {boolean} Determine result.
 */
function isMap(item, {
	empty,
	maximumSize,
	minimumSize,
	...aliases
} = {}) {
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	maximumSize = undefinish(maximumSize, aliases.maxSize, aliases.maximumEntries, aliases.maxEntries, Infinity);
	if (maximumSize !== Infinity && !$isNumber(maximumSize, {
		integer: true,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`maximumSize\` must be \`Infinity\` or type of number (integer, positive, and safe)!`);
	}
	minimumSize = undefinish(minimumSize, aliases.minSize, aliases.minimumEntries, aliases.minEntries, 0);
	if (!$isNumber(minimumSize, {
		integer: true,
		maximum: maximumSize,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`minimumSize\` must be type of number (integer, positive, and safe) and <= ${maximumSize}!`);
	}
	if (empty === false) {
		maximumSize = Infinity;
		minimumSize = 1;
	} else if (empty === true) {
		maximumSize = 0;
		minimumSize = 0;
	}
	if (
		!(item instanceof Map) ||
		maximumSize < item.size ||
		item.size < minimumSize
	) {
		return false;
	}
	return true;
}
export default isMap;
