import { isPlainObject as adIsPlainObject, isString as adIsString } from "@hugoalh/advanced-determine";
import undefinish from "@hugoalh/undefinish";
const characterAlphanumeric = `[\\dA-Za-z]`;
const characterHex = `[\\dA-Fa-f]`;
const numberDecimalFloat0_1 = `(?:1(?:\\.0+)?|0(?:\\.\\d+)?)`;
const numberDecimalIntegerNoZeroLead = `(?:0|[1-9]\\d*)`;
const numberDecimalIntegerNoZeroLead0_99 = `(?:[1-9]\\d|\\d)`;
const numberDecimalIntegerNoZeroLead0_255 = `(?:2(?:5[0-5]|[0-4]\\d)|1\\d{2}|${numberDecimalIntegerNoZeroLead0_99})`;
const numberDecimalIntegerNoZeroLead0_360 = `(?:3(?:60|[0-5]\\d)|[1-2]\\d{2}|${numberDecimalIntegerNoZeroLead0_99})`;
const numberPercentageFloat = `(?:100(?:\\.0+)?|${numberDecimalIntegerNoZeroLead0_99}(?:\\.\\d+)?)%`;
const partHexAdectet = `${characterHex}{1,4}`;
const partIPV4 = `${numberDecimalIntegerNoZeroLead0_255}(?:\\.${numberDecimalIntegerNoZeroLead0_255}){3}`;
const partIPV6 = `(?:(?:(?:${partHexAdectet}:){7}(?:${partHexAdectet}|:)|(?:${partHexAdectet}:){6}(?:${partIPV4}|:${partHexAdectet}|:)|(?:${partHexAdectet}:){5}(?::${partIPV4}|(?::${partHexAdectet}){1,2}|:)|(?:${partHexAdectet}:){4}(?:(?::${partHexAdectet}){0,1}:${partIPV4}|(?::${partHexAdectet}){1,3}|:)|(?:${partHexAdectet}:){3}(?:(?::${partHexAdectet}){0,2}:${partIPV4}|(?::${partHexAdectet}){1,4}|:)|(?:${partHexAdectet}:){2}(?:(?::${partHexAdectet}){0,3}:${partIPV4}|(?::${partHexAdectet}){1,5}|:)|(?:${partHexAdectet}:){1}(?:(?::${partHexAdectet}){0,4}:${partIPV4}|(?::${partHexAdectet}){1,6}|:)|(?::(?:(?::${partHexAdectet}){0,5}:${partIPV4}|(?::${partHexAdectet}){1,7}|:)))(?:%[0-9a-zA-Z]{1,})?)`;
/**
 * @private
 * @function $checkCommonOption
 * @param {object} option
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {object}
 */
function $checkCommonOption(option) {
	if (!adIsPlainObject(option, { super: true })) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	option.boundary = undefinish(option.boundary, false);
	if (typeof option.boundary !== "boolean") {
		throw new TypeError(`Argument \`option.boundary\` must be type of boolean!`);
	};
	option.caseInsensitive = undefinish(option.caseInsensitive, false);
	if (typeof option.caseInsensitive !== "boolean") {
		throw new TypeError(`Argument \`option.caseInsensitive\` must be type of boolean!`);
	};
	option.exactly = undefinish(option.exactly, false);
	if (typeof option.exactly !== "boolean") {
		throw new TypeError(`Argument \`option.exactly\` must be type of boolean!`);
	};
	option.global = undefinish(option.global, false);
	if (typeof option.global !== "boolean") {
		throw new TypeError(`Argument \`option.global\` must be type of boolean!`);
	};
	if (option.boundary && option.exactly) {
		throw new ReferenceError(`Flag "boundary" and "exactly" cannot use together!`);
	};
	return option;
};
/**
 * @private
 * @function $flagCommonService
 * @param {string} pattern
 * @param {object} [option={}]
 * @param {boolean} option.boundary
 * @param {boolean} option.caseInsensitive
 * @param {boolean} option.exactly
 * @param {boolean} option.global
 * @returns {RegExp}
 */
function $flagCommonService(pattern, option = {}) {
	let resultFlag = "u";
	let resultPattern = pattern;
	if (option.boundary && !option.exactly) {
		resultPattern = `\\b${pattern}\\b`;
	};
	if (option.caseInsensitive) {
		resultFlag += "i";
	};
	if (option.exactly && !option.boundary) {
		resultPattern = `^${pattern}$`;
	};
	if (option.global) {
		resultFlag += "g";
	};
	return new RegExp(resultPattern, resultFlag);
};
/**
 * @function base64
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {boolean} [option.padding]
 * @returns {RegExp}
 */
function base64(option = {}) {
	option = $checkCommonOption(option);
	const characterBase64 = `(?:${characterAlphanumeric}|[+/])`;
	if (typeof option.padding !== "boolean" && typeof option.padding !== "undefined") {
		throw new TypeError(`Argument \`option.padding\` must be type of boolean or undefined!`);
	};
	let partPadding = [];
	if (option.padding === true) {
		partPadding = ["==", "="];
	} else if (option.padding === false) {
		partPadding = ["", ""];
	} else {
		partPadding = ["(?:==)?", "=?"];
	};
	return $flagCommonService(
		`(?:${characterBase64}{4})*(?:${characterBase64}{2}${partPadding[0]}|${characterBase64}{3}${partPadding[1]}|${characterBase64}{4})`,
		option
	);
};
/**
 * @function base64
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function base64URL(option = {}) {
	const characterBase64URL = `(?:${characterAlphanumeric}|[-_])`;
	return $flagCommonService(
		`(?:${characterBase64URL}{4})*(?:${characterBase64URL}{2}(?:==)?|${characterBase64URL}{3}=?|${characterBase64URL}{4})`,
		$checkCommonOption(option)
	);
};
/**
 * @function bigInteger
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function bigInteger(option = {}) {
	return $flagCommonService(
		`-?${numberDecimalIntegerNoZeroLead}n`,
		$checkCommonOption(option)
	);
};
/**
 * @function colourCMYK
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlack="black"]
 * @param {string} [option.groupCyan="cyan"]
 * @param {string} [option.groupMagenta="magenta"]
 * @param {string} [option.groupYellow="yellow"]
 * @returns {RegExp}
 */
function colourCMYK(option = {}) {
	option = $checkCommonOption(option);
	option.groupBlack = undefinish(option.groupBlack, "black");
	if (!adIsString(option.groupBlack, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlack\` must be type of string (non-empty)!`);
	};
	option.groupCyan = undefinish(option.groupCyan, "cyan");
	if (!adIsString(option.groupCyan, { empty: false })) {
		throw new TypeError(`Argument \`option.groupCyan\` must be type of string (non-empty)!`);
	};
	option.groupMagenta = undefinish(option.groupMagenta, "magenta");
	if (!adIsString(option.groupMagenta, { empty: false })) {
		throw new TypeError(`Argument \`option.groupMagenta\` must be type of string (non-empty)!`);
	};
	option.groupYellow = undefinish(option.groupYellow, "yellow");
	if (!adIsString(option.groupYellow, { empty: false })) {
		throw new TypeError(`Argument \`option.groupYellow\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`cmyk\\( ?(?<${option.groupCyan}>${numberPercentageFloat}) ?, ?(?<${option.groupMagenta}>${numberPercentageFloat}) ?, ?(?<${option.groupYellow}>${numberPercentageFloat}) ?, ?(?<${option.groupBlack}>${numberPercentageFloat}) ?\\)`,
		option
	);
};
/**
 * @function colourHex
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function colourHex(option = {}) {
	return $flagCommonService(
		`#(?:${characterHex}{6}|${characterHex}{3})`,
		$checkCommonOption(option)
	);
};
/**
 * @function colourHexAlpha
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function colourHexAlpha(option = {}) {
	return $flagCommonService(
		`#(?:${characterHex}{8}|${characterHex}{4})`,
		$checkCommonOption(option)
	);
};
/**
 * @function colourHSL
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupLightness="lightness"]
 * @param {string} [option.groupSaturation="saturation"]
 * @returns {RegExp}
 */
function colourHSL(option = {}) {
	option = $checkCommonOption(option);
	option.groupHue = undefinish(option.groupHue, "hue");
	if (!adIsString(option.groupHue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupHue\` must be type of string (non-empty)!`);
	};
	option.groupLightness = undefinish(option.groupLightness, "lightness");
	if (!adIsString(option.groupLightness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupLightness\` must be type of string (non-empty)!`);
	};
	option.groupSaturation = undefinish(option.groupSaturation, "saturation");
	if (!adIsString(option.groupSaturation, { empty: false })) {
		throw new TypeError(`Argument \`option.groupSaturation\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`hsl\\( ?(?<${option.groupHue}>${numberDecimalIntegerNoZeroLead0_360}) ?, ?(?<${option.groupSaturation}>${numberPercentageFloat}) ?, ?(?<${option.groupLightness}>${numberPercentageFloat}) ?\\)`,
		option
	);
};
/**
 * @function colourHSLA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupLightness="lightness"]
 * @param {string} [option.groupSaturation="saturation"]
 * @returns {RegExp}
 */
function colourHSLA(option = {}) {
	option = $checkCommonOption(option);
	option.groupAlpha = undefinish(option.groupAlpha, "alpha");
	if (!adIsString(option.groupAlpha, { empty: false })) {
		throw new TypeError(`Argument \`option.groupAlpha\` must be type of string (non-empty)!`);
	};
	option.groupHue = undefinish(option.groupHue, "hue");
	if (!adIsString(option.groupHue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupHue\` must be type of string (non-empty)!`);
	};
	option.groupLightness = undefinish(option.groupLightness, "lightness");
	if (!adIsString(option.groupLightness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupLightness\` must be type of string (non-empty)!`);
	};
	option.groupSaturation = undefinish(option.groupSaturation, "saturation");
	if (!adIsString(option.groupSaturation, { empty: false })) {
		throw new TypeError(`Argument \`option.groupSaturation\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`hsla\\( ?(?<${option.groupHue}>${numberDecimalIntegerNoZeroLead0_360}) ?, ?(?<${option.groupSaturation}>${numberPercentageFloat}) ?, ?(?<${option.groupLightness}>${numberPercentageFloat}) ?, ?(?<${option.groupAlpha}>${numberDecimalFloat0_1}) ?\\)`,
		option
	);
};
/**
 * @function colourHWB
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
function colourHWB(option = {}) {
	option = $checkCommonOption(option);
	option.groupBlackness = undefinish(option.groupBlackness, "blackness");
	if (!adIsString(option.groupBlackness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlackness\` must be type of string (non-empty)!`);
	};
	option.groupHue = undefinish(option.groupHue, "hue");
	if (!adIsString(option.groupHue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupHue\` must be type of string (non-empty)!`);
	};
	option.groupWhiteness = undefinish(option.groupWhiteness, "whiteness");
	if (!adIsString(option.groupWhiteness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupWhiteness\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`hwb\\( ?(?<${option.groupHue}>${numberDecimalIntegerNoZeroLead0_360}) ?, ?(?<${option.groupWhiteness}>${numberPercentageFloat}) ?, ?(?<${option.groupBlackness}>${numberPercentageFloat}) ?\\)`,
		option
	);
};
/**
 * @function colourHWBA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
function colourHWBA(option = {}) {
	option = $checkCommonOption(option);
	option.groupAlpha = undefinish(option.groupAlpha, "alpha");
	if (!adIsString(option.groupAlpha, { empty: false })) {
		throw new TypeError(`Argument \`option.groupAlpha\` must be type of string (non-empty)!`);
	};
	option.groupBlackness = undefinish(option.groupBlackness, "blackness");
	if (!adIsString(option.groupBlackness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlackness\` must be type of string (non-empty)!`);
	};
	option.groupHue = undefinish(option.groupHue, "hue");
	if (!adIsString(option.groupHue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupHue\` must be type of string (non-empty)!`);
	};
	option.groupWhiteness = undefinish(option.groupWhiteness, "whiteness");
	if (!adIsString(option.groupWhiteness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupWhiteness\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`hwba\\( ?(?<${option.groupHue}>${numberDecimalIntegerNoZeroLead0_360}) ?, ?(?<${option.groupWhiteness}>${numberPercentageFloat}) ?, ?(?<${option.groupBlackness}>${numberPercentageFloat}) ?, ?(?<${option.groupAlpha}>${numberDecimalFloat0_1}) ?\\)`,
		option
	);
};
/**
 * @function colourNCol
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
function colourNCol(option = {}) {
	option = $checkCommonOption(option);
	option.groupBlackness = undefinish(option.groupBlackness, "blackness");
	if (!adIsString(option.groupBlackness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlackness\` must be type of string (non-empty)!`);
	};
	option.groupHue = undefinish(option.groupHue, "hue");
	if (!adIsString(option.groupHue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupHue\` must be type of string (non-empty)!`);
	};
	option.groupWhiteness = undefinish(option.groupWhiteness, "whiteness");
	if (!adIsString(option.groupWhiteness, { empty: false })) {
		throw new TypeError(`Argument \`option.groupWhiteness\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`ncol\\( ?(?<${option.groupHue}>[BCGMRY](?:\\d{2})?) ?, ?(?<${option.groupWhiteness}>${numberPercentageFloat}) ?, ?(?<${option.groupBlackness}>${numberPercentageFloat}) ?\\)`,
		option
	);
};
/**
 * @function colourRGB
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlue="blue"]
 * @param {string} [option.groupGreen="green"]
 * @param {string} [option.groupRed="red"]
 * @returns {RegExp}
 */
function colourRGB(option = {}) {
	option = $checkCommonOption(option);
	option.groupBlue = undefinish(option.groupBlue, "blue");
	if (!adIsString(option.groupBlue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlue\` must be type of string (non-empty)!`);
	};
	option.groupGreen = undefinish(option.groupGreen, "green");
	if (!adIsString(option.groupGreen, { empty: false })) {
		throw new TypeError(`Argument \`option.groupGreen\` must be type of string (non-empty)!`);
	};
	option.groupRed = undefinish(option.groupRed, "red");
	if (!adIsString(option.groupRed, { empty: false })) {
		throw new TypeError(`Argument \`option.groupRed\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`rgb\\( ?(?<${option.groupRed}>${numberDecimalIntegerNoZeroLead0_255}) ?, ?(?<${option.groupGreen}>${numberDecimalIntegerNoZeroLead0_255}) ?, ?(?<${option.groupBlue}>${numberDecimalIntegerNoZeroLead0_255}) ?\\)`,
		option
	);
};
/**
 * @function colourRGBA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupBlue="blue"]
 * @param {string} [option.groupGreen="green"]
 * @param {string} [option.groupRed="red"]
 * @returns {RegExp}
 */
function colourRGBA(option = {}) {
	option = $checkCommonOption(option);
	option.groupAlpha = undefinish(option.groupAlpha, "alpha");
	if (!adIsString(option.groupAlpha, { empty: false })) {
		throw new TypeError(`Argument \`option.groupAlpha\` must be type of string (non-empty)!`);
	};
	option.groupBlue = undefinish(option.groupBlue, "blue");
	if (!adIsString(option.groupBlue, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBlue\` must be type of string (non-empty)!`);
	};
	option.groupGreen = undefinish(option.groupGreen, "green");
	if (!adIsString(option.groupGreen, { empty: false })) {
		throw new TypeError(`Argument \`option.groupGreen\` must be type of string (non-empty)!`);
	};
	option.groupRed = undefinish(option.groupRed, "red");
	if (!adIsString(option.groupRed, { empty: false })) {
		throw new TypeError(`Argument \`option.groupRed\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`rgba\\( ?(?<${option.groupRed}>${numberDecimalIntegerNoZeroLead0_255}) ?, ?(?<${option.groupGreen}>${numberDecimalIntegerNoZeroLead0_255}) ?, ?(?<${option.groupBlue}>${numberDecimalIntegerNoZeroLead0_255}) ?, ?(?<${option.groupAlpha}>${numberDecimalFloat0_1}) ?\\)`,
		$checkCommonOption(option)
	);
};
/**
 * @function email
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {string} [option.domain]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupDomain="domain"]
 * @param {string} [option.groupLocal="local"]
 * @param {boolean} [option.ipv4=false]
 * @param {boolean} [option.ipv6=false]
 * @returns {RegExp}
 */
function email(option = {}) {
	option = $checkCommonOption(option);
	const characterSymbolEmail = `[!#$%&'*+/=?^_\`{|}~-]`;
	const partDomain = `${characterAlphanumeric}(?:[.-]?${characterAlphanumeric}){0,254}`;
	if (!adIsString(option.domain, { pattern: new RegExp(`^${partDomain}$`, "gu") }) && typeof option.domain !== "undefined") {
		throw new TypeError(`Argument \`option.domain\` must be type of string (domain) or undefined!`);
	};
	option.groupDomain = undefinish(option.groupDomain, "domain");
	if (!adIsString(option.groupDomain, { empty: false })) {
		throw new TypeError(`Argument \`option.groupDomain\` must be type of string (non-empty)!`);
	};
	option.groupLocal = undefinish(option.groupLocal, "local");
	if (!adIsString(option.groupLocal, { empty: false })) {
		throw new TypeError(`Argument \`option.groupLocal\` must be type of string (non-empty)!`);
	};
	option.ipv4 = undefinish(option.ipv4, false);
	if (typeof option.ipv4 !== "boolean") {
		throw new TypeError(`Argument \`option.ipv4\` must be type of boolean!`);
	};
	option.ipv6 = undefinish(option.ipv6, false);
	if (typeof option.ipv6 !== "boolean") {
		throw new TypeError(`Argument \`option.ipv6\` must be type of boolean!`);
	};
	return $flagCommonService(
		`(?<${option.groupLocal}>(?:${characterAlphanumeric}|${characterSymbolEmail})(?:\\.?(?:${characterAlphanumeric}|${characterSymbolEmail})){0,63})@(?<${option.groupDomain}>${(typeof option.domain === "string") ? option.domain.replace(/\./gu, "\\.") : partDomain}${(option.ipv4) ? `|\\[${partIPV4}\\]` : ""}${(option.ipv6) ? `|\\[IPv6:${partIPV6}\\]` : ""})`,
		option
	);
};
/**
 * @function githubRepository
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function githubRepository(option = {}) {
	return $flagCommonService(
		`(?:${characterAlphanumeric}|[-_]){1,32}\\/(?:${characterAlphanumeric}|[-_.]){1,100}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash128
 * @alias md2
 * @alias md4
 * @alias md5
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash128(option = {}) {
	return $flagCommonService(
		`${characterHex}{32}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash160
 * @alias sha1
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash160(option = {}) {
	return $flagCommonService(
		`${characterHex}{40}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash224
 * @alias blake2s224
 * @alias blake224
 * @alias sha224
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash224(option = {}) {
	return $flagCommonService(
		`${characterHex}{56}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash256
 * @alias blake2s256
 * @alias blake256
 * @alias sha256
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash256(option = {}) {
	return $flagCommonService(
		`${characterHex}{64}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash384
 * @alias blake2b384
 * @alias blake384
 * @alias sha384
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash384(option = {}) {
	return $flagCommonService(
		`${characterHex}{96}`,
		$checkCommonOption(option)
	);
};
/**
 * @function hash512
 * @alias blake2b512
 * @alias blake512
 * @alias sha512
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function hash512(option = {}) {
	return $flagCommonService(
		`${characterHex}{128}`,
		$checkCommonOption(option)
	);
};
/**
 * @function ip
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function ip(option = {}) {
	return $flagCommonService(
		`(?:${partIPV4}|${partIPV6})`,
		$checkCommonOption(option)
	);
};
/**
 * @function ipv4
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function ipv4(option = {}) {
	return $flagCommonService(
		`${partIPV4}`,
		$checkCommonOption(option)
	);
};
/**
 * @function ipv6
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function ipv6(option = {}) {
	return $flagCommonService(
		`${partIPV6}`,
		$checkCommonOption(option)
	);
};
/**
 * @function macAddress
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function macAddress(option = {}) {
	const partMACCode = `${characterHex}{2}`;
	return $flagCommonService(
		`${partMACCode}([:-])${partMACCode}(?:\\1${partMACCode}){4}`,
		$checkCommonOption(option)
	);
};
/**
 * @function md6
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function md6(option = {}) {
	return $flagCommonService(
		`${characterHex}{1,128}`,
		$checkCommonOption(option)
	);
};
/**
 * @function number
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function number(option = {}) {
	return $flagCommonService(
		`-?${numberDecimalIntegerNoZeroLead}(?:\\.\\d+)?(?:e-?[1-9]\\d*)?`,
		$checkCommonOption(option)
	);
};
/**
 * @function regularExpression
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupFlag="flag"]
 * @param {string} [option.groupSource="source"]
 * @returns {RegExp}
 */
function regularExpression(option = {}) {
	option = $checkCommonOption(option);
	option.groupFlag = undefinish(option.groupFlag, "flag");
	if (!adIsString(option.groupFlag, { empty: false })) {
		throw new TypeError(`Argument \`option.groupFlag\` must be type of string (non-empty)!`);
	};
	option.groupSource = undefinish(option.groupSource, "source");
	if (!adIsString(option.groupSource, { empty: false })) {
		throw new TypeError(`Argument \`option.groupSource\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`\\/(?<${option.groupSource}>.+)\\/(?<${option.groupFlag}>[dgimsuy]*)`,
		option
	);
};
/**
 * @function semanticVersioning
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBuild="build"]
 * @param {string} [option.groupMajor="major"]
 * @param {string} [option.groupMinor="minor"]
 * @param {string} [option.groupPatch="patch"]
 * @param {string} [option.groupPreRelease="prerelease"]
 * @returns {RegExp}
 */
function semanticVersioning(option = {}) {
	option = $checkCommonOption(option);
	option.groupBuild = undefinish(option.groupBuild, "build");
	if (!adIsString(option.groupBuild, { empty: false })) {
		throw new TypeError(`Argument \`option.groupBuild\` must be type of string (non-empty)!`);
	};
	option.groupMajor = undefinish(option.groupMajor, "major");
	if (!adIsString(option.groupMajor, { empty: false })) {
		throw new TypeError(`Argument \`option.groupMajor\` must be type of string (non-empty)!`);
	};
	option.groupMinor = undefinish(option.groupMinor, "minor");
	if (!adIsString(option.groupMinor, { empty: false })) {
		throw new TypeError(`Argument \`option.groupMinor\` must be type of string (non-empty)!`);
	};
	option.groupPatch = undefinish(option.groupPatch, "patch");
	if (!adIsString(option.groupPatch, { empty: false })) {
		throw new TypeError(`Argument \`option.groupPatch\` must be type of string (non-empty)!`);
	};
	option.groupPreRelease = undefinish(option.groupPreRelease, "prerelease");
	if (!adIsString(option.groupPreRelease, { empty: false })) {
		throw new TypeError(`Argument \`option.groupPreRelease\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(
		`v?(?<${option.groupMajor}>${numberDecimalIntegerNoZeroLead})\\.(?<${option.groupMinor}>${numberDecimalIntegerNoZeroLead})\\.(?<${option.groupPatch}>${numberDecimalIntegerNoZeroLead})(?:-(?<${option.groupPreRelease}>${characterAlphanumeric}(?:${characterAlphanumeric}|-)*${characterAlphanumeric}?(?:\\.${characterAlphanumeric}(?:${characterAlphanumeric}|-)*${characterAlphanumeric}?)*))?(?:\\+(?<${option.groupBuild}>${characterAlphanumeric}(?:${characterAlphanumeric}|-)*${characterAlphanumeric}?(?:\\.${characterAlphanumeric}(?:${characterAlphanumeric}|-)*${characterAlphanumeric}?)*))?`,
		option
	);
};
/**
 * @function shebang
 * @param {object} [option={}]
 * @param {string} [option.groupCommand="command"]
 * @returns {RegExp}
 */
function shebang(option = {}) {
	if (!adIsPlainObject(option, { super: true })) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	option.groupCommand = undefinish(option.groupCommand, "command");
	if (!adIsString(option.groupCommand, { empty: false })) {
		throw new TypeError(`Argument \`option.groupCommand\` must be type of string (non-empty)!`);
	};
	return $flagCommonService(`^#! *(?<${option.groupCommand}>.*)(?:\\r?\\n)?`);
};
/**
 * @function url
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 * @note From https://gist.github.com/dperini/729294.
 */
function url(option = {}) {
	const partU = "[a-z\\d\\u{00a1}-\\u{ffff}]";
	return $flagCommonService(
		`(?:ftp|https?):\\/\\/(?:\\S+(?::\\S*)?@)?(?:(?!(?:10|127)(?:\\.\\d{1,3}){3})(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:${partU}+-)*${partU}+)(?:\\.(?:${partU}+-)*${partU}+)*(?:\\.(?:[a-z\\u{00a1}-\\u{ffff}]{2,})))(?::\\d{2,5})?(?:\\/[^\\s]*)?`,
		$checkCommonOption(option)
	);
};
/**
 * @function uuid
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
function uuid(option = {}) {
	return $flagCommonService(
		`${characterHex}{8}(?:-${characterHex}{4}){3}-${characterHex}{12}`,
		$checkCommonOption(option)
	);
};
export {
	base64,
	base64URL,
	bigInteger,
	hash384 as blake2b384,
	hash512 as blake2b512,
	hash224 as blake2s224,
	hash256 as blake2s256,
	hash224 as blake224,
	hash256 as blake256,
	hash384 as blake384,
	hash512 as blake512,
	colourCMYK,
	colourHex,
	colourHexAlpha,
	colourHSL,
	colourHSLA,
	colourHWB,
	colourHWBA,
	colourNCol,
	colourRGB,
	colourRGBA,
	email,
	githubRepository,
	hash128,
	hash160,
	hash224,
	hash256,
	hash384,
	hash512,
	ip,
	ipv4,
	ipv6,
	macAddress,
	hash128 as md2,
	hash128 as md4,
	hash128 as md5,
	md6,
	number,
	regularExpression,
	semanticVersioning,
	hash160 as sha1,
	hash224 as sha224,
	hash256 as sha256,
	hash384 as sha384,
	hash512 as sha512,
	shebang,
	url,
	uuid
};
