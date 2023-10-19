export = isMap;
/**
 * @function isMap
 * @description Determine item is type of map or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.empty] An empty map.
 * @param {number} [param1.maximumSize=Infinity] Maximum size of the map.
 * @param {number} [param1.minimumSize=0] Minimum size of the map.
 * @returns {boolean} Determine result.
 */
declare function isMap(item: any, { empty, maximumSize, minimumSize, ...aliases }?: {
    empty?: boolean;
    maximumSize?: number;
    minimumSize?: number;
}): boolean;
//# sourceMappingURL=is-map.d.ts.map