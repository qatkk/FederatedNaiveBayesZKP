export = isRegularExpression;
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
declare function isRegularExpression(item: any, { caseInsensitive, dotAll, exactly, global, multipleLine, sticky, unicode, ...aliases }?: {
    caseInsensitive?: boolean;
    dotAll?: boolean;
    exactly?: boolean;
    global?: boolean;
    multipleLine?: boolean;
    sticky?: boolean;
    unicode?: boolean;
}): boolean;
//# sourceMappingURL=is-regular-expression.d.ts.map