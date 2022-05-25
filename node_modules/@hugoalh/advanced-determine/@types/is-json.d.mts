export default isJSON;
/**
 * @function isJSON
 * @description Determine item is type of JSON or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.arrayRoot] Type of array as the root of the JSON.
 * @param {boolean} [option.empty] An empty JSON.
 * @param {RegExp} [option.keysPattern] Ensure pattern in the JSON keys.
 * @param {number} [option.maximumEntries=Infinity] Maximum entries of the JSON.
 * @param {number} [option.minimumEntries=0] Minimum entries of the JSON.
 * @param {boolean} [option.strict=false] Ensure type of array is not as the root of the JSON, and no illegal namespace characters in the JSON keys.
 * @param {boolean} [option.strictKeys=false] Ensure no illegal namespace characters in the JSON keys.
 * @returns {boolean} Determine result.
 */
declare function isJSON(item: any, option?: {
    arrayRoot?: boolean;
    empty?: boolean;
    keysPattern?: RegExp;
    maximumEntries?: number;
    minimumEntries?: number;
    strict?: boolean;
    strictKeys?: boolean;
}): boolean;
//# sourceMappingURL=is-json.d.mts.map