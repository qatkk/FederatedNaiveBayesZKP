export = isJSON;
/**
 * @function isJSON
 * @description Determine item is type of JSON or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.arrayRoot] Type of array as the root of the JSON.
 * @param {boolean} [param1.empty] An empty JSON.
 * @param {RegExp} [param1.keysPattern] Ensure pattern in the JSON keys.
 * @param {number} [param1.maximumEntries=Infinity] Maximum entries of the JSON.
 * @param {number} [param1.minimumEntries=0] Minimum entries of the JSON.
 * @param {boolean} [param1.strict=false] Ensure type of array is not as the root of the JSON, and no illegal namespace characters in the JSON keys.
 * @param {boolean} [param1.strictKeys=false] Ensure no illegal namespace characters in the JSON keys.
 * @returns {boolean} Determine result.
 */
declare function isJSON(item: any, { arrayRoot, empty, keysPattern, maximumEntries, minimumEntries, strict, strictKeys, ...aliases }?: {
    arrayRoot?: boolean;
    empty?: boolean;
    keysPattern?: RegExp;
    maximumEntries?: number;
    minimumEntries?: number;
    strict?: boolean;
    strictKeys?: boolean;
}): boolean;
//# sourceMappingURL=is-json.d.ts.map