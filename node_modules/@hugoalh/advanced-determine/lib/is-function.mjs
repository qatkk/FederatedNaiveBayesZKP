import { types as utilityTypes } from "util";
import isPlainObjectInno from "./internal/is-plain-object-inno.mjs";
import undefinish from "@hugoalh/undefinish";
/**
 * @function isFunction
 * @alias isFn
 * @description Determine item is type of function or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.asynchronous] An asynchronous function.
 * @param {boolean} [option.generator] A generator function.
 * @returns {boolean} Determine result.
 */
function isFunction(item, option = {}) {
	if (!isPlainObjectInno(option)) {
		throw new TypeError(`Argument \`option\` must be type of plain object!`);
	};
	option.asynchronous = undefinish(option.asynchronous, option.async);
	if (typeof option.asynchronous !== "boolean" && typeof option.asynchronous !== "undefined") {
		throw new TypeError(`Argument \`option.asynchronous\` must be type of boolean or undefined!`);
	};
	if (typeof option.generator !== "boolean" && typeof option.generator !== "undefined") {
		throw new TypeError(`Argument \`option.generator\` must be type of boolean or undefined!`);
	};
	let reConstructorName = `${(option.asynchronous === false) ? "" : "(?:Async)"}${(typeof option.asynchronous === "undefined") ? "?" : ""}${(option.generator === false) ? "" : "(?:Generator)"}${(typeof option.generator === "undefined") ? "?" : ""}Function`;
	if (
		typeof item !== "function" ||
		(option.asynchronous === false && utilityTypes.isAsyncFunction(item)) ||
		(option.asynchronous === true && !utilityTypes.isAsyncFunction(item)) ||
		(option.generator === false && utilityTypes.isGeneratorFunction(item)) ||
		(option.generator === true && !utilityTypes.isGeneratorFunction(item)) ||
		item.constructor.name.search(new RegExp(`^${reConstructorName}$`, "gu")) !== 0 ||
		Object.prototype.toString.call(item).search(new RegExp(`^\\[object ${reConstructorName}\\]$`, "gu")) !== 0
	) {
		return false;
	};
	return true;
};
export default isFunction;
