const isObject = require("./is-object.js");
const undefinish = require("@hugoalh/undefinish");
const utility = require("util");
/**
 * @function isGenerator
 * @description Determine item is type of generator or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.asynchronous] An asynchronous generator.
 * @returns {boolean} Determine result.
 */
function isGenerator(item, {
	asynchronous,
	...aliases
} = {}) {
	asynchronous = undefinish(asynchronous, aliases.async);
	if (typeof asynchronous !== "boolean" && typeof asynchronous !== "undefined") {
		throw new TypeError(`Argument \`asynchronous\` must be type of boolean or undefined!`);
	}
	if (
		!isObject(item) ||
		!utility.types.isGeneratorObject(item) ||
		Object.prototype.toString.call(item).search(new RegExp(`^\\[object ${(asynchronous === false) ? "" : "(?:Async)"}${(typeof asynchronous === "undefined") ? "?" : ""}Generator\\]$`, "gu")) !== 0 ||
		typeof item.next !== "function" ||
		typeof item.return !== "function" ||
		typeof item.throw !== "function"
	) {
		return false;
	}
	return true;
}
module.exports = isGenerator;
