/**
 * @function isObject
 * @alias isObj
 * @description Determine item is type of object or not.
 * @param {any} item Item that need to determine.
 * @returns {boolean} Determine result.
 */
function isObject(item) {
	return (typeof item === "object" && !Array.isArray(item) && item !== null && !(item instanceof RegExp));
};
export default isObject;
