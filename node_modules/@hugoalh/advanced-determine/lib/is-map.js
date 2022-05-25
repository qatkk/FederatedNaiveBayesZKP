const isNumber = require("./is-number.js");
const isPlainObjectInno = require("./internal/is-plain-object-inno.js");
const undefinish = require("@hugoalh/undefinish");
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
function isMap(item, option = {}) {
	if (!isPlainObjectInno(option)) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	if (typeof option.empty !== "boolean" && typeof option.empty !== "undefined") {
		throw new TypeError(`Argument \`option.empty\` must be type of boolean or undefined!`);
	};
	option.maximumSize = undefinish(option.maximumSize, option.maxSize, option.maximumEntries, option.maxEntries, Infinity);
	if (option.maximumSize !== Infinity && !isNumber(option.maximumSize, { finite: true, integer: true, positive: true, safe: true })) {
		throw new TypeError(`Argument \`option.maximumSize\` must be \`Infinity\` or type of number (finite, integer, positive, and safe)!`);
	};
	option.minimumSize = undefinish(option.minimumSize, option.minSize, option.minimumEntries, option.minEntries, 0);
	if (!isNumber(option.minimumSize, { finite: true, integer: true, maximum: option.maximumSize, positive: true, safe: true })) {
		throw new TypeError(`Argument \`option.minimumSize\` must be type of number (finite, integer, positive, and safe) and less than or equal to argument \`option.maximumSize\`'s value!`);
	};
	if (option.empty === false) {
		option.maximumSize = Infinity;
		option.minimumSize = 1;
	} else if (option.empty === true) {
		option.maximumSize = 0;
		option.minimumSize = 0;
	};
	if (!(item instanceof Map)) {
		return false;
	};
	let itemSize = item.size;
	if (
		option.maximumSize < itemSize ||
		itemSize < option.minimumSize
	) {
		return false;
	};
	return true;
};
module.exports = isMap;
