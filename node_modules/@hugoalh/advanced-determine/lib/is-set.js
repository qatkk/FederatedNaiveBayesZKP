const $isNumber = require("./internal/is-number.js");
const undefinish = require("@hugoalh/undefinish");
/**
 * @function isSet
 * @description Determine item is type of set or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty set.
 * @param {number} [param1.maximumSize=Infinity] Maximum size of the set.
 * @param {number} [param1.minimumSize=0] Minimum size of the set.
 * @returns {boolean} Determine result.
 */
function isSet(item, {
	empty,
	maximumSize,
	minimumSize,
	...aliases
} = {}) {
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	maximumSize = undefinish(maximumSize, aliases.maxSize, Infinity);
	if (maximumSize !== Infinity && !$isNumber(maximumSize, {
		integer: true,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`maximumSize\` must be \`Infinity\` or type of number (integer, positive, and safe)!`);
	}
	minimumSize = undefinish(minimumSize, aliases.minSize, 0);
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
		!(item instanceof Set) ||
		maximumSize < item.size ||
		item.size < minimumSize
	) {
		return false;
	}
	return true;
}
module.exports = isSet;
