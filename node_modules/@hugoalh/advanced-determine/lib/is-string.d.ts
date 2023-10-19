export = isString;
/**
 * @function isString
 * @alias isStr
 * @description Determine item is type of string or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.ascii=false] Allow only ASCII characters in the string.
 * @param {boolean} [param1.empty] An empty string.
 * @param {boolean} [param1.lowerCase] A lower case string.
 * @param {number} [param1.maximumLength=Infinity] Maximum length of the string.
 * @param {number} [param1.minimumLength=0] Minimum length of the string.
 * @param {boolean} [param1.multipleLine] A multiple line string.
 * @param {RegExp} [param1.pattern] Pattern.
 * @param {boolean} [param1.preTrim=false] Trim string before determine.
 * @param {boolean} [param1.singleLine] A single line string.
 * @param {boolean} [param1.upperCase] An upper case string.
 * @returns {boolean} Determine result.
 */
declare function isString(item: any, { ascii, empty, lowerCase, maximumLength, minimumLength, multipleLine, pattern, preTrim, singleLine, upperCase, ...aliases }?: {
    ascii?: boolean;
    empty?: boolean;
    lowerCase?: boolean;
    maximumLength?: number;
    minimumLength?: number;
    multipleLine?: boolean;
    pattern?: RegExp;
    preTrim?: boolean;
    singleLine?: boolean;
    upperCase?: boolean;
}): boolean;
//# sourceMappingURL=is-string.d.ts.map