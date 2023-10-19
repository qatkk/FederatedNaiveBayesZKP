export = isPlainObject;
/**
 * @function isPlainObject
 * @alias isDict
 * @alias isDictionary
 * @alias isObjectPlain
 * @alias isObjPlain
 * @alias isPlainObj
 * @description Determine item is type of plain object or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.configurableEntries] Configurable entries in the plain object.
 * @param {boolean} [param1.empty] An empty plain object.
 * @param {boolean} [param1.enumerableEntries] Enumerable entries in the plain object.
 * @param {boolean} [param1.getterEntries] Getter entries in the plain object.
 * @param {number} [param1.maximumEntries=Infinity] Maximum entries of the plain object.
 * @param {number} [param1.minimumEntries=0] Minimum entries of the plain object.
 * @param {boolean} [param1.setterEntries] Setter entries in the plain object.
 * @param {boolean} [param1.strict=false] Ensure no custom defined properties (i.e.: getters, setters, non-configurable, non-enumerable, and non-writable) in the plain object, and no symbols in the plain object keys.
 * @param {boolean} [param1.symbolKeys] Symbols in the plain object keys.
 * @param {boolean} [param1.writableEntries] Writable entries in the plain object.
 * @returns {boolean} Determine result.
 */
declare function isPlainObject(item: any, { configurableEntries, empty, enumerableEntries, getterEntries, maximumEntries, minimumEntries, setterEntries, strict, symbolKeys, writableEntries, ...aliases }?: {
    configurableEntries?: boolean;
    empty?: boolean;
    enumerableEntries?: boolean;
    getterEntries?: boolean;
    maximumEntries?: number;
    minimumEntries?: number;
    setterEntries?: boolean;
    strict?: boolean;
    symbolKeys?: boolean;
    writableEntries?: boolean;
}): boolean;
//# sourceMappingURL=is-plain-object.d.ts.map