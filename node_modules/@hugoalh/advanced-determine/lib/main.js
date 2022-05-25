const areEqual = require("./are-equal.js");
const isArray = require("./is-array.js");
const isBigInteger = require("./is-big-integer.js");
const isFunction = require("./is-function.js");
const isGenerator = require("./is-generator.js");
const isJSON = require("./is-json.js");
const isMap = require("./is-map.js");
const isNumber = require("./is-number.js");
const isObject = require("./is-object.js");
const isPlainObject = require("./is-plain-object.js");
const isRegularExpression = require("./is-regular-expression.js");
const isSet = require("./is-set.js");
const isString = require("./is-string.js");
const isStringifyJSON = require("./is-stringify-json.js");
const typeOf = require("./type-of.js");
const $isNaN = Number.isNaN;
const version = 6;
module.exports = {
	areEqual,
	isArr: isArray,
	isArray,
	isBigInt: isBigInteger,
	isBigInteger,
	isDict: isPlainObject,
	isDictionary: isPlainObject,
	isFn: isFunction,
	isFunction,
	isGenerator,
	isJSON,
	isJSONStr: isStringifyJSON,
	isJSONStringified: isStringifyJSON,
	isJSONStringify: isStringifyJSON,
	isList: isArray,
	isMap,
	isNaN: $isNaN,
	isNotANumber: $isNaN,
	isNum: isNumber,
	isNumber,
	isObj: isObject,
	isObject,
	isObjectPlain: isPlainObject,
	isObjPlain: isPlainObject,
	isPlainObj: isPlainObject,
	isPlainObject,
	isRegEx: isRegularExpression,
	isRegExp: isRegularExpression,
	isRegularExpression,
	isSet,
	isStr: isString,
	isString,
	isStringifiedJSON: isStringifyJSON,
	isStringifyJSON,
	isStrJSON: isStringifyJSON,
	typeOf,
	v: version,
	ver: version,
	version
};
