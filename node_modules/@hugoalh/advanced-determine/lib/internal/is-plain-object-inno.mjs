import $isPlainObject from "./is-plain-object.mjs";
/**
 * @private
 * @function isPlainObjectInno
 * @param {any} item
 * @returns {boolean}
 */
function isPlainObjectInno(item) {
	return $isPlainObject(item, { configurableEntries: true, enumerableEntries: true, getterEntries: false, maximumEntries: Infinity, minimumEntries: 0, setterEntries: false, symbolKeys: false, writableEntries: true });
};
export default isPlainObjectInno;
