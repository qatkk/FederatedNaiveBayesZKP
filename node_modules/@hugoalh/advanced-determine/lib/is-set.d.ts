export = isSet;
/**
 * @function isSet
 * @description Determine item is type of set or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty set.
 * @param {number} [param1.maximumSize=Infinity] Maximum size of the set.
 * @param {number} [param1.minimumSize=0] Minimum size of the set.
 * @returns {boolean} Determine result.
 */
declare function isSet(item: any, { empty, maximumSize, minimumSize, ...aliases }?: {
    empty?: boolean;
    maximumSize?: number;
    minimumSize?: number;
}): boolean;
//# sourceMappingURL=is-set.d.ts.map