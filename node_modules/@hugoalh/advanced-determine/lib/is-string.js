const $isNumber = require("./internal/is-number.js");
const undefinish = require("@hugoalh/undefinish");
/**
 * @function isString
 * @alias isStr
 * @description Determine item is type of string or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.ascii=false] Allow only ASCII characters in the string.
 * @param {boolean} [param1.empty] An empty string.
 * @param {boolean} [param1.lowerCase] A lower case string.
 * @param {number} [param1.maximumLength=Infinity] Maximum length of the string.
 * @param {number} [param1.minimumLength=0] Minimum length of the string.
 * @param {boolean} [param1.multipleLine] A multiple line string.
 * @param {RegExp} [param1.pattern] Pattern.
 * @param {boolean} [param1.preTrim=false] Trim string before determine.
 * @param {boolean} [param1.singleLine] A single line string.
 * @param {boolean} [param1.upperCase] An upper case string.
 * @returns {boolean} Determine result.
 */
function isString(item, {
	ascii = false,
	empty,
	lowerCase,
	maximumLength,
	minimumLength,
	multipleLine,
	pattern,
	preTrim = false,
	singleLine,
	upperCase,
	...aliases
} = {}) {
	if (typeof ascii !== "boolean") {
		throw new TypeError(`Argument \`ascii\` must be type of boolean!`);
	}
	if (typeof empty !== "boolean" && typeof empty !== "undefined") {
		throw new TypeError(`Argument \`empty\` must be type of boolean or undefined!`);
	}
	if (typeof lowerCase !== "boolean" && typeof lowerCase !== "undefined") {
		throw new TypeError(`Argument \`lowerCase\` must be type of boolean or undefined!`);
	}
	maximumLength = undefinish(maximumLength, aliases.maxLength, aliases.maximumCharacters, aliases.maxCharacters, Infinity);
	if (maximumLength !== Infinity && !$isNumber(maximumLength, {
		integer: true,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`maximumLength\` must be \`Infinity\` or type of number (integer, positive, and safe)!`);
	}
	minimumLength = undefinish(minimumLength, aliases.minLength, aliases.minimumCharacters, aliases.minCharacters, 0);
	if (!$isNumber(minimumLength, {
		integer: true,
		maximum: maximumLength,
		positive: true,
		safe: true
	})) {
		throw new TypeError(`Argument \`minimumLength\` must be type of number (integer, positive, and safe) and <= ${maximumLength}!`);
	}
	multipleLine = undefinish(multipleLine, aliases.multiLine, aliases.multiline);
	if (typeof multipleLine !== "boolean" && typeof multipleLine !== "undefined") {
		throw new TypeError(`Argument \`multipleLine\` must be type of boolean or undefined!`);
	}
	if (!(pattern instanceof RegExp) && typeof pattern !== "undefined") {
		throw new TypeError(`Argument \`pattern\` must be type of regular expression or undefined!`);
	}
	if (typeof preTrim !== "boolean") {
		throw new TypeError(`Argument \`preTrim\` must be type of boolean!`);
	}
	if (typeof singleLine !== "boolean" && typeof singleLine !== "undefined") {
		throw new TypeError(`Argument \`singleLine\` must be type of boolean or undefined!`);
	}
	if (typeof upperCase !== "boolean" && typeof upperCase !== "undefined") {
		throw new TypeError(`Argument \`upperCase\` must be type of boolean or undefined!`);
	}
	if (empty === false) {
		maximumLength = Infinity;
		minimumLength = 1;
	} else if (empty === true) {
		maximumLength = 0;
		minimumLength = 0;
	}
	if (typeof item !== "string") {
		return false;
	}
	let itemRaw = preTrim ? item.trim() : item;
	if (ascii) {
		for (let character of itemRaw) {
			if (character.charCodeAt(0) > 127) {
				return false;
			}
		}
	}
	if (
		maximumLength < itemRaw.length ||
		itemRaw.length < minimumLength ||
		(pattern instanceof RegExp && itemRaw.search(pattern) === -1) ||
		((
			lowerCase === true ||
			upperCase === false
		) && itemRaw !== itemRaw.toLowerCase()) ||
		((
			upperCase === true ||
			lowerCase === false
		) && itemRaw !== itemRaw.toUpperCase()) ||
		((
			multipleLine === true ||
			singleLine === false
		) && itemRaw.search(/[\n\r]/gu) === -1) ||
		((
			singleLine === true ||
			multipleLine === false
		) && itemRaw.search(/[\n\r]/gu) !== -1)
	) {
		return false;
	}
	return true;
}
module.exports = isString;
