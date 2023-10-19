const undefinish = require("@hugoalh/undefinish");
/**
 * @function isRegularExpression
 * @alias isRegEx
 * @alias isRegExp
 * @description Determine item is type of regular expression or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.caseInsensitive] A case insensitive regular expression.
 * @param {boolean} [param1.dotAll] A dot-all regular expression.
 * @param {boolean} [param1.exactly] An exactly regular expression.
 * @param {boolean} [param1.global] A global regular expression.
 * @param {boolean} [param1.multipleLine] A multiple line regular expression.
 * @param {boolean} [param1.sticky] A sticky regular expression.
 * @param {boolean} [param1.unicode] An unicode regular expression.
 * @returns {boolean} Determine result.
 */
function isRegularExpression(item, {
	caseInsensitive,
	dotAll,
	exactly,
	global,
	multipleLine,
	sticky,
	unicode,
	...aliases
} = {}) {
	caseInsensitive = undefinish(caseInsensitive, aliases.ignoreCase);
	if (typeof caseInsensitive !== "boolean" && typeof caseInsensitive !== "undefined") {
		throw new TypeError(`Argument \`caseInsensitive\` must be type of boolean or undefined!`);
	}
	if (typeof dotAll !== "boolean" && typeof dotAll !== "undefined") {
		throw new TypeError(`Argument \`dotAll\` must be type of boolean or undefined!`);
	}
	exactly = undefinish(exactly, aliases.exact);
	if (typeof exactly !== "boolean" && typeof exactly !== "undefined") {
		throw new TypeError(`Argument \`exactly\` must be type of boolean or undefined!`);
	}
	if (typeof global !== "boolean" && typeof global !== "undefined") {
		throw new TypeError(`Argument \`global\` must be type of boolean or undefined!`);
	}
	multipleLine = undefinish(multipleLine, aliases.multiLine, aliases.multiline);
	if (typeof multipleLine !== "boolean" && typeof multipleLine !== "undefined") {
		throw new TypeError(`Argument \`multipleLine\` must be type of boolean or undefined!`);
	}
	if (typeof sticky !== "boolean" && typeof sticky !== "undefined") {
		throw new TypeError(`Argument \`sticky\` must be type of boolean or undefined!`);
	}
	if (typeof unicode !== "boolean" && typeof unicode !== "undefined") {
		throw new TypeError(`Argument \`unicode\` must be type of boolean or undefined!`);
	}
	if (
		!(item instanceof RegExp) ||
		(caseInsensitive === false && item.ignoreCase) ||
		(caseInsensitive === true && !item.ignoreCase) ||
		(dotAll === false && item.dotAll) ||
		(dotAll === true && !item.dotAll) ||
		(exactly === false && item.source.startsWith("^") && item.source.endsWith("$")) ||
		(exactly === true && (
			!item.source.startsWith("^") ||
			!item.source.endsWith("$")
		)) ||
		(global === false && item.global) ||
		(global === true && !item.global) ||
		(multipleLine === false && item.multiline) ||
		(multipleLine === true && !item.multiline) ||
		(sticky === false && item.sticky) ||
		(sticky === true && !item.sticky) ||
		(unicode === false && item.unicode) ||
		(unicode === true && !item.unicode)
	) {
		return false;
	}
	return true;
}
module.exports = isRegularExpression;
