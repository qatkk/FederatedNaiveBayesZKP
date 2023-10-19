export = isStringifyJSON;
/**
 * @function isStringifyJSON
 * @alias isJSONStr
 * @alias isJSONStringified
 * @alias isJSONStringify
 * @alias isStringifiedJSON
 * @alias isStrJSON
 * @description Determine item is type of stringify JSON or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.arrayRoot] Type of array as the root of the stringify JSON.
 * @param {boolean} [param1.empty] An empty stringify JSON.
 * @param {RegExp} [param1.keysPattern] Ensure pattern in the stringify JSON keys.
 * @param {number} [param1.maximumEntries=Infinity] Maximum entries of the stringify JSON.
 * @param {number} [param1.minimumEntries=0] Minimum entries of the stringify JSON.
 * @param {boolean} [param1.strict=false] Ensure type of array is not as the root of the stringify JSON, and no illegal namespace characters in the stringify JSON keys.
 * @param {boolean} [param1.strictKeys=false] Ensure no illegal namespace characters in the stringify JSON keys.
 * @returns {boolean} Determine result.
 */
declare function isStringifyJSON(item: any, { arrayRoot, empty, keysPattern, maximumEntries, minimumEntries, strict, strictKeys, ...aliases }?: {
    arrayRoot?: boolean;
    empty?: boolean;
    keysPattern?: RegExp;
    maximumEntries?: number;
    minimumEntries?: number;
    strict?: boolean;
    strictKeys?: boolean;
}): boolean;
//# sourceMappingURL=is-stringify-json.d.ts.map