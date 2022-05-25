const isPlainObjectInno = require("./internal/is-plain-object-inno.js");
const isPrimeNumber = require("./internal/is-prime-number.js");
const undefinish = require("@hugoalh/undefinish");
const maximumSafeInteger = BigInt(Number.MAX_SAFE_INTEGER);
const minimumSafeInteger = BigInt(Number.MIN_SAFE_INTEGER);
/**
 * @function isBigInteger
 * @alias isBigInt
 * @description Determine item is type of big integer number or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.exclusiveMaximum=false] Exclusive maximum of the big integer number.
 * @param {boolean} [option.exclusiveMinimum=false] Exclusive minimum of the big integer number.
 * @param {bigint} [option.maximum=Infinity] Maximum of the big integer number.
 * @param {bigint} [option.minimum=-Infinity] Minimum of the big integer number.
 * @param {boolean} [option.negative] A negative big integer number.
 * @param {boolean} [option.positive] A positive big integer number.
 * @param {boolean} [option.prime] A prime number.
 * @param {boolean} [option.safe] An IEEE-754 big integer number.
 * @param {boolean} [option.unsafe] Not an IEEE-754 big integer number.
 * @returns {boolean} Determine result.
 */
function isBigInteger(item, option = {}) {
	if (!isPlainObjectInno(option)) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	option.exclusiveMaximum = undefinish(option.exclusiveMaximum, option.exclusiveMax, false);
	if (typeof option.exclusiveMaximum !== "boolean") {
		throw new TypeError(`Argument \`option.exclusiveMaximum\` must be type of boolean!`);
	};
	option.exclusiveMinimum = undefinish(option.exclusiveMinimum, option.exclusiveMin, false);
	if (typeof option.exclusiveMinimum !== "boolean") {
		throw new TypeError(`Argument \`option.exclusiveMinimum\` must be type of boolean!`);
	};
	option.maximum = undefinish(option.maximum, option.max, Infinity);
	if (option.maximum !== Infinity && typeof option.maximum !== "bigint") {
		throw new TypeError(`Argument \`option.maximum\` must be \`Infinity\` or type of big integer number!`);
	};
	option.minimum = undefinish(option.minimum, option.min, -Infinity);
	if (option.minimum !== -Infinity && isBigInteger(option.minimum, { maximum: option.maximum })) {
		throw new TypeError(`Argument \`option.minimum\` must be \`-Infinity\`, or type of big integer number and less than or equal to argument \`option.maximum\`'s value!`);
	};
	option.negative = undefinish(option.negative, option.ngt, option.nega);
	if (typeof option.negative !== "boolean" && typeof option.negative !== "undefined") {
		throw new TypeError(`Argument \`option.negative\` must be type of boolean or undefined!`);
	};
	option.positive = undefinish(option.positive, option.pst, option.posi);
	if (typeof option.positive !== "boolean" && typeof option.positive !== "undefined") {
		throw new TypeError(`Argument \`option.positive\` must be type of boolean or undefined!`);
	};
	if (typeof option.prime !== "boolean" && typeof option.prime !== "undefined") {
		throw new TypeError(`Argument \`option.prime\` must be type of boolean or undefined!`);
	};
	if (typeof option.safe !== "boolean" && typeof option.safe !== "undefined") {
		throw new TypeError(`Argument \`option.safe\` must be type of boolean or undefined!`);
	};
	if (typeof option.unsafe !== "boolean" && typeof option.unsafe !== "undefined") {
		throw new TypeError(`Argument \`option.unsafe\` must be type of boolean or undefined!`);
	};
	if (
		typeof item !== "bigint" ||
		(option.exclusiveMaximum && option.maximum <= item) ||
		(!option.exclusiveMaximum && option.maximum < item) ||
		(option.exclusiveMinimum && item <= option.minimum) ||
		(!option.exclusiveMinimum && item < option.minimum) ||
		((
			option.negative === true ||
			option.positive === false
		) && item >= 0n) ||
		((
			option.positive === true ||
			option.negative === false
		) && item < 0n) ||
		(option.prime === false && isPrimeNumber(item)) ||
		(option.prime === true && !isPrimeNumber(item)) ||
		((
			option.safe === true ||
			option.unsafe === false
		) && (
			maximumSafeInteger < item ||
			item < minimumSafeInteger
		)) ||
		((
			option.unsafe === true ||
			option.safe === false
		) && minimumSafeInteger <= item && item <= maximumSafeInteger)
	) {
		return false;
	};
	return true;
};
module.exports = isBigInteger;
