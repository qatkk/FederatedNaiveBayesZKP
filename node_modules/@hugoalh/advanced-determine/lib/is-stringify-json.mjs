import isJSON from "./is-json.mjs";
import isPlainObjectInno from "./internal/is-plain-object-inno.mjs";
/**
 * @function isStringifyJSON
 * @alias isJSONStr
 * @alias isJSONStringified
 * @alias isJSONStringify
 * @alias isStringifiedJSON
 * @alias isStrJSON
 * @description Determine item is type of stringify JSON or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.arrayRoot] Type of array as the root of the stringify JSON.
 * @param {boolean} [option.empty] An empty stringify JSON.
 * @param {RegExp} [option.keysPattern] Ensure pattern in the stringify JSON keys.
 * @param {number} [option.maximumEntries=Infinity] Maximum entries of the stringify JSON.
 * @param {number} [option.minimumEntries=0] Minimum entries of the stringify JSON.
 * @param {boolean} [option.strict=false] Ensure type of array is not as the root of the stringify JSON, and no illegal namespace characters in the stringify JSON keys.
 * @param {boolean} [option.strictKeys=false] Ensure no illegal namespace characters in the stringify JSON keys.
 * @returns {boolean} Determine result.
 */
function isStringifyJSON(item, option = {}) {
	if (!isPlainObjectInno(option)) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	if (typeof item !== "string") {
		return false;
	};
	let itemParse;
	try {
		itemParse = JSON.parse(item);
	} catch {
		return false;
	};
	return isJSON(itemParse, option);
};
export default isStringifyJSON;
