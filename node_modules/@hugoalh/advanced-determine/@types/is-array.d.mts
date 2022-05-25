export default isArray;
/**
 * @function isArray
 * @alias isArr
 * @alias isList
 * @description Determine item is type of array or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.empty] An empty array.
 * @param {number} [option.maximumLength=Infinity] Maximum length of the array.
 * @param {number} [option.minimumLength=0] Minimum length of the array.
 * @param {boolean} [option.super=false] Ensure no custom defined properties in the array.
 * @param {boolean} [option.unique=false] Elements must be unique in the array.
 * @returns {boolean} Determine result.
 */
declare function isArray(item: any, option?: {
    empty?: boolean;
    maximumLength?: number;
    minimumLength?: number;
    super?: boolean;
    unique?: boolean;
}): boolean;
//# sourceMappingURL=is-array.d.mts.map