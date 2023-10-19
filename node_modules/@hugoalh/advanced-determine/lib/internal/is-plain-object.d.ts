export = $isPlainObject;
/**
 * @private
 * @function $isPlainObject
 * @param {any} item
 * @param {object} [param1={}]
 * @param {boolean} [param1.configurableEntries]
 * @param {boolean} [param1.enumerableEntries]
 * @param {boolean} [param1.getterEntries]
 * @param {number} [param1.maximumEntries=Infinity]
 * @param {number} [param1.minimumEntries=0]
 * @param {boolean} [param1.setterEntries]
 * @param {boolean} [param1.symbolKeys]
 * @param {boolean} [param1.writableEntries]
 * @returns {boolean}
 */
declare function $isPlainObject(item: any, { configurableEntries, enumerableEntries, getterEntries, maximumEntries, minimumEntries, setterEntries, symbolKeys, writableEntries }?: {
    configurableEntries?: boolean;
    enumerableEntries?: boolean;
    getterEntries?: boolean;
    maximumEntries?: number;
    minimumEntries?: number;
    setterEntries?: boolean;
    symbolKeys?: boolean;
    writableEntries?: boolean;
}): boolean;
//# sourceMappingURL=is-plain-object.d.ts.map