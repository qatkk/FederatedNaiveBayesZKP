const isPrimeNumber = require("./is-prime-number.js");
const maximumSafeInteger = BigInt(Number.MAX_SAFE_INTEGER);
const minimumSafeInteger = BigInt(Number.MIN_SAFE_INTEGER);
/**
 * @function $isBigInteger
 * @param {any} item
 * @param {object} [param1={}]
 * @param {boolean} [param1.even]
 * @param {boolean} [param1.exclusiveMaximum=false]
 * @param {boolean} [param1.exclusiveMinimum=false]
 * @param {bigint} [param1.maximum=Infinity]
 * @param {bigint} [param1.minimum=-Infinity]
 * @param {boolean} [param1.negative]
 * @param {boolean} [param1.odd]
 * @param {boolean} [param1.positive]
 * @param {boolean} [param1.prime]
 * @param {boolean} [param1.safe]
 * @param {boolean} [param1.unsafe]
 * @returns {boolean}
 */
function $isBigInteger(item, {
	even,
	exclusiveMaximum = false,
	exclusiveMinimum = false,
	maximum = Infinity,
	minimum = -Infinity,
	negative,
	odd,
	positive,
	prime,
	safe,
	unsafe
} = {}) {
	if (
		typeof item !== "bigint" ||
		(even === false && item % 2n === 0n) ||
		(even === true && item % 2n !== 0n) ||
		(exclusiveMaximum && maximum <= item) ||
		(!exclusiveMaximum && maximum < item) ||
		(exclusiveMinimum && item <= minimum) ||
		(!exclusiveMinimum && item < minimum) ||
		((
			negative === true ||
			positive === false
		) && item >= 0n) ||
		((
			positive === true ||
			negative === false
		) && item < 0n) ||
		(odd === false && item % 2n !== 0n) ||
		(odd === true && item % 2n === 0n) ||
		(prime === false && isPrimeNumber(item)) ||
		(prime === true && !isPrimeNumber(item)) ||
		((
			safe === true ||
			unsafe === false
		) && (
			maximumSafeInteger < item ||
			item < minimumSafeInteger
		)) ||
		((
			unsafe === true ||
			safe === false
		) && minimumSafeInteger <= item && item <= maximumSafeInteger)
	) {
		return false;
	}
	return true;
}
module.exports = $isBigInteger;
