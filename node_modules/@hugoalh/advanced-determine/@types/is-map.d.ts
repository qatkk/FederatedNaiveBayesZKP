export = isMap;
/**
 * @function isMap
 * @description Determine item is type of map or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.empty] An empty map.
 * @param {number} [option.maximumSize=Infinity] Maximum size of the map.
 * @param {number} [option.minimumSize=0] Minimum size of the map.
 * @returns {boolean} Determine result.
 */
declare function isMap(item: any, option?: {
    empty?: boolean;
    maximumSize?: number;
    minimumSize?: number;
}): boolean;
//# sourceMappingURL=is-map.d.ts.map