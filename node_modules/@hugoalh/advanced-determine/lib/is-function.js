const undefinish = require("@hugoalh/undefinish");
const utility = require("util");
/**
 * @function isFunction
 * @alias isFn
 * @description Determine item is type of function or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.asynchronous] An asynchronous function.
 * @param {boolean} [param1.generator] A generator function.
 * @returns {boolean} Determine result.
 */
function isFunction(item, {
	asynchronous,
	generator,
	...aliases
} = {}) {
	asynchronous = undefinish(asynchronous, aliases.async);
	if (typeof asynchronous !== "boolean" && typeof asynchronous !== "undefined") {
		throw new TypeError(`Argument \`asynchronous\` must be type of boolean or undefined!`);
	}
	if (typeof generator !== "boolean" && typeof generator !== "undefined") {
		throw new TypeError(`Argument \`generator\` must be type of boolean or undefined!`);
	}
	let reConstructorName = `${(asynchronous === false) ? "" : "(?:Async)"}${(typeof asynchronous === "undefined") ? "?" : ""}${(generator === false) ? "" : "(?:Generator)"}${(typeof generator === "undefined") ? "?" : ""}Function`;
	if (
		typeof item !== "function" ||
		(asynchronous === false && utility.types.isAsyncFunction(item)) ||
		(asynchronous === true && !utility.types.isAsyncFunction(item)) ||
		(generator === false && utility.types.isGeneratorFunction(item)) ||
		(generator === true && !utility.types.isGeneratorFunction(item)) ||
		item.constructor.name.search(new RegExp(`^${reConstructorName}$`, "gu")) !== 0 ||
		Object.prototype.toString.call(item).search(new RegExp(`^\\[object ${reConstructorName}\\]$`, "gu")) !== 0
	) {
		return false;
	}
	return true;
}
module.exports = isFunction;
