export default isArray;
/**
 * @function isArray
 * @alias isArr
 * @alias isList
 * @description Determine item is type of array or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty array.
 * @param {number} [param1.maximumLength=Infinity] Maximum length of the array.
 * @param {number} [param1.minimumLength=0] Minimum length of the array.
 * @param {boolean} [param1.strict=false] Ensure no custom defined properties in the array.
 * @param {boolean} [param1.unique=false] Elements must be unique in the array.
 * @returns {boolean} Determine result.
 */
declare function isArray(item: any, { empty, maximumLength, minimumLength, strict, unique, ...aliases }?: {
    empty?: boolean;
    maximumLength?: number;
    minimumLength?: number;
    strict?: boolean;
    unique?: boolean;
}): boolean;
//# sourceMappingURL=is-array.d.mts.map