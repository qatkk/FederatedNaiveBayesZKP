export = isRegularExpression;
/**
 * @function isRegularExpression
 * @alias isRegEx
 * @alias isRegExp
 * @description Determine item is type of regular expression or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.caseInsensitive] A case insensitive regular expression.
 * @param {boolean} [option.dotAll] A dot-all regular expression.
 * @param {boolean} [option.exactly] An exactly regular expression.
 * @param {boolean} [option.global] A global regular expression.
 * @param {boolean} [option.multipleLine] A multiple line regular expression.
 * @param {boolean} [option.sticky] A sticky regular expression.
 * @param {boolean} [option.unicode] An unicode regular expression.
 * @returns {boolean} Determine result.
 */
declare function isRegularExpression(item: any, option?: {
    caseInsensitive?: boolean;
    dotAll?: boolean;
    exactly?: boolean;
    global?: boolean;
    multipleLine?: boolean;
    sticky?: boolean;
    unicode?: boolean;
}): boolean;
//# sourceMappingURL=is-regular-expression.d.ts.map