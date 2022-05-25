export default isString;
/**
 * @function isString
 * @alias isStr
 * @description Determine item is type of string or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.ascii=false] Allow only ASCII characters in the string.
 * @param {boolean} [option.empty] An empty string.
 * @param {boolean} [option.lowerCase] A lower case string.
 * @param {number} [option.maximumLength=Infinity] Maximum length of the string.
 * @param {number} [option.minimumLength=0] Minimum length of the string.
 * @param {boolean} [option.multipleLine] A multiple line string.
 * @param {RegExp} [option.pattern] Pattern.
 * @param {boolean} [option.preTrim=false] Trim string before determine.
 * @param {boolean} [option.singleLine] A single line string.
 * @param {boolean} [option.upperCase] An upper case string.
 * @returns {boolean} Determine result.
 */
declare function isString(item: any, option?: {
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
//# sourceMappingURL=is-string.d.mts.map