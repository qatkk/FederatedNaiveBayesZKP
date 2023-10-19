import isPrimeNumber from "./is-prime-number.mjs";
/**
 * @private
 * @function $isNumber
 * @param {any} item
 * @param {object} [param1={}]
 * @param {boolean} [param1.even]
 * @param {boolean} [param1.exclusiveMaximum=false]
 * @param {boolean} [param1.exclusiveMinimum=false]
 * @param {boolean} [param1.finite]
 * @param {boolean} [param1.float]
 * @param {boolean} [param1.infinite]
 * @param {boolean} [param1.integer]
 * @param {number} [param1.maximum=Infinity]
 * @param {number} [param1.minimum=-Infinity]
 * @param {boolean} [param1.negative]
 * @param {boolean} [param1.odd]
 * @param {boolean} [param1.positive]
 * @param {boolean} [param1.prime]
 * @param {boolean} [param1.safe]
 * @param {boolean} [param1.unsafe]
 * @returns {boolean}
 */
function $isNumber(item, {
	even,
	exclusiveMaximum = false,
	exclusiveMinimum = false,
	finite,
	float,
	infinite,
	integer,
	maximum = Infinity,
	minimum = -Infinity,
	negative,
	odd,
	positive,
	prime,
	safe,
	unsafe
} = {}) {
	let itemIsFinite = Number.isFinite(item);
	let itemIsInteger = Number.isInteger(item);
	let itemIsSafeInteger = Number.isSafeInteger(item);
	if (
		typeof item !== "number" ||
		Number.isNaN(item) ||
		(even === false && itemIsSafeInteger && item % 2 === 0) ||
		(even === true && (
			!itemIsSafeInteger ||
			item % 2 !== 0
		)) ||
		(exclusiveMaximum && maximum <= item) ||
		(!exclusiveMaximum && maximum < item) ||
		(exclusiveMinimum && item <= minimum) ||
		(!exclusiveMinimum && item < minimum) ||
		((
			finite === true ||
			infinite === false
		) && !itemIsFinite) ||
		((
			infinite === true ||
			finite === false
		) && itemIsFinite) ||
		((
			float === true ||
			integer === false
		) && itemIsInteger) ||
		((
			integer === true ||
			float === false
		) && !itemIsInteger) ||
		((
			negative === true ||
			positive === false
		) && item >= 0) ||
		((
			positive === true ||
			negative === false
		) && item < 0) ||
		(odd === false && itemIsSafeInteger && item % 2 !== 0) ||
		(odd === true && (
			!itemIsSafeInteger ||
			item % 2 === 0
		)) ||
		(prime === false && itemIsSafeInteger && isPrimeNumber(item)) ||
		(prime === true && (
			!itemIsSafeInteger ||
			!isPrimeNumber(item)
		)) ||
		((
			safe === true ||
			unsafe === false
		) && (
			item < Number.MIN_SAFE_INTEGER ||
			item > Number.MAX_SAFE_INTEGER
		)) ||
		((
			unsafe === true ||
			safe === false
		) && item >= Number.MIN_SAFE_INTEGER && item <= Number.MAX_SAFE_INTEGER)
	) {
		return false;
	}
	return true;
}
export default $isNumber;
