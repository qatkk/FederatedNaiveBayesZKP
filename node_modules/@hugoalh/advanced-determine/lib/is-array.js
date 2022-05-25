const isNumber = require("./is-number.js");
const isPlainObjectInno = require("./internal/is-plain-object-inno.js");
const undefinish = require("@hugoalh/undefinish");
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
function isArray(item, option = {}) {
	if (!isPlainObjectInno(option)) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	if (typeof option.empty !== "boolean" && typeof option.empty !== "undefined") {
		throw new TypeError(`Argument \`option.empty\` must be type of boolean or undefined!`);
	};
	option.maximumLength = undefinish(option.maximumLength, option.maxLength, option.maximumElements, option.maxElements, Infinity);
	if (option.maximumLength !== Infinity && !isNumber(option.maximumLength, { finite: true, integer: true, positive: true, safe: true })) {
		throw new TypeError(`Argument \`option.maximumLength\` must be \`Infinity\` or type of number (finite, integer, positive, and safe)!`);
	};
	option.minimumLength = undefinish(option.minimumLength, option.minLength, option.minimumElements, option.minElements, 0);
	if (!isNumber(option.minimumLength, { finite: true, integer: true, maximum: option.maximumLength, positive: true, safe: true })) {
		throw new TypeError(`Argument \`option.minimumLength\` must be type of number (finite, integer, positive, and safe) and less than or equal to argument \`option.maximumLength\`'s value!`);
	};
	option.super = undefinish(option.super, false);
	if (typeof option.super !== "boolean") {
		throw new TypeError(`Argument \`option.super\` must be type of boolean!`);
	};
	option.unique = undefinish(option.unique, false);
	if (typeof option.unique !== "boolean") {
		throw new TypeError(`Argument \`option.unique\` must be type of boolean!`);
	};
	if (option.empty === false) {
		option.maximumLength = Infinity;
		option.minimumLength = 1;
	} else if (option.empty === true) {
		option.maximumLength = 0;
		option.minimumLength = 0;
	};
	if (
		!Array.isArray(item) ||
		!(item instanceof Array) ||
		item.constructor.name !== "Array" ||
		Object.prototype.toString.call(item) !== "[object Array]"
	) {
		return false;
	};
	let itemLength = item.length;
	if (Object.entries(item).length !== itemLength) {
		return false;
	};
	if (option.super) {
		let itemPrototype = Object.getPrototypeOf(item);
		if (itemPrototype !== null && itemPrototype !== Array.prototype) {
			return false;
		};
		if (Object.getOwnPropertySymbols(item).length > 0) {
			return false;
		};
		let itemDescriptors = Object.getOwnPropertyDescriptors(item);
		for (let itemPropertyKey in itemDescriptors) {
			if (Object.prototype.hasOwnProperty.call(itemDescriptors, itemPropertyKey)) {
				if (itemPropertyKey.search(/^(?:0|[1-9]\d*)$/gu) === 0 && Number(itemPropertyKey) < 4294967296) {
					let itemPropertyDescriptor = itemDescriptors[itemPropertyKey];
					if (
						!itemPropertyDescriptor.configurable ||
						!itemPropertyDescriptor.enumerable ||
						typeof itemPropertyDescriptor.get !== "undefined" ||
						typeof itemPropertyDescriptor.set !== "undefined" ||
						!itemPropertyDescriptor.writable
					) {
						return false;
					};
				} else if (itemPropertyKey === "length") {
					let itemPropertyDescriptor = itemDescriptors[itemPropertyKey];
					if (
						itemPropertyDescriptor.configurable ||
						itemPropertyDescriptor.enumerable ||
						typeof itemPropertyDescriptor.get !== "undefined" ||
						typeof itemPropertyDescriptor.set !== "undefined" ||
						!itemPropertyDescriptor.writable
					) {
						return false;
					};
				} else {
					return false;
				};
			};
		};
	};
	if (
		option.maximumLength < itemLength ||
		itemLength < option.minimumLength ||
		(option.unique && Array.from(new Set(item).values()).length < itemLength)
	) {
		return false;
	};
	return true;
};
module.exports = isArray;
