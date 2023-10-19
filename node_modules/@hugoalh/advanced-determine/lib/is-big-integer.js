const $isBigInteger = require("./internal/is-big-integer.js");
const integerTypes = require("./internal/integer-types.js");
const undefinish = require("@hugoalh/undefinish");
/**
 * @function isBigInteger
 * @alias isBigInt
 * @description Determine item is type of big integer or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.even] An even big integer.
 * @param {boolean} [param1.exclusiveMaximum=false] Exclusive maximum of the big integer.
 * @param {boolean} [param1.exclusiveMinimum=false] Exclusive minimum of the big integer.
 * @param {bigint} [param1.maximum=Infinity] Maximum of the big integer.
 * @param {bigint} [param1.minimum=-Infinity] Minimum of the big integer.
 * @param {boolean} [param1.negative] A negative big integer.
 * @param {boolean} [param1.odd] An odd big integer.
 * @param {boolean} [param1.positive] A positive big integer.
 * @param {boolean} [param1.prime] A prime big integer.
 * @param {boolean} [param1.safe] An IEEE-754 big integer.
 * @param {string} [param1.type] Type of the big integer.
 * @param {boolean} [param1.unsafe] Not an IEEE-754 big integer.
 * @returns {boolean} Determine result.
 */
function isBigInteger(item, {
	even,
	exclusiveMaximum,
	exclusiveMinimum,
	maximum,
	minimum,
	negative,
	odd,
	positive,
	prime,
	safe,
	type,
	unsafe,
	...aliases
} = {}) {
	if (typeof even !== "boolean" && typeof even !== "undefined") {
		throw new TypeError(`Argument \`even\` must be type of boolean or undefined!`);
	}
	exclusiveMaximum = undefinish(exclusiveMaximum, aliases.exclusiveMax, false);
	if (typeof exclusiveMaximum !== "boolean") {
		throw new TypeError(`Argument \`exclusiveMaximum\` must be type of boolean!`);
	}
	exclusiveMinimum = undefinish(exclusiveMinimum, aliases.exclusiveMin, false);
	if (typeof exclusiveMinimum !== "boolean") {
		throw new TypeError(`Argument \`exclusiveMinimum\` must be type of boolean!`);
	}
	maximum = undefinish(maximum, aliases.max, Infinity);
	if (maximum !== Infinity && typeof maximum !== "bigint") {
		throw new TypeError(`Argument \`maximum\` must be \`Infinity\` or type of big integer!`);
	}
	minimum = undefinish(minimum, aliases.min, -Infinity);
	if (minimum !== -Infinity && !isBigInteger(minimum, { maximum })) {
		throw new TypeError(`Argument \`minimum\` must be \`-Infinity\`, or type of big integer and <= ${maximum}!`);
	}
	negative = undefinish(negative, aliases.ngt, aliases.nega);
	if (typeof negative !== "boolean" && typeof negative !== "undefined") {
		throw new TypeError(`Argument \`negative\` must be type of boolean or undefined!`);
	}
	if (typeof odd !== "boolean" && typeof odd !== "undefined") {
		throw new TypeError(`Argument \`odd\` must be type of boolean or undefined!`);
	}
	positive = undefinish(positive, aliases.pst, aliases.posi);
	if (typeof positive !== "boolean" && typeof positive !== "undefined") {
		throw new TypeError(`Argument \`positive\` must be type of boolean or undefined!`);
	}
	if (typeof prime !== "boolean" && typeof prime !== "undefined") {
		throw new TypeError(`Argument \`prime\` must be type of boolean or undefined!`);
	}
	if (typeof safe !== "boolean" && typeof safe !== "undefined") {
		throw new TypeError(`Argument \`safe\` must be type of boolean or undefined!`);
	}
	if (typeof unsafe !== "boolean" && typeof unsafe !== "undefined") {
		throw new TypeError(`Argument \`unsafe\` must be type of boolean or undefined!`);
	}
	if (typeof type === "string") {
		[minimum, maximum] = integerTypes(type);
		exclusiveMaximum = false;
		exclusiveMinimum = false;
	} else if (typeof type !== "undefined") {
		throw new TypeError(`Argument \`type\` must be type of string or undefined!`);
	}
	return $isBigInteger(item, {
		even,
		exclusiveMaximum,
		exclusiveMinimum,
		maximum,
		minimum,
		negative,
		odd,
		positive,
		prime,
		safe,
		unsafe
	});
}
module.exports = isBigInteger;
