export = isNumber;
/**
 * @function isNumber
 * @alias isNum
 * @description Determine item is type of number or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.exclusiveMaximum=false] Exclusive maximum of the number.
 * @param {boolean} [option.exclusiveMinimum=false] Exclusive minimum of the number.
 * @param {boolean} [option.finite] A finite number.
 * @param {boolean} [option.float] A float number.
 * @param {boolean} [option.infinite] An infinite number.
 * @param {boolean} [option.integer] An integer number.
 * @param {number} [option.maximum=Infinity] Maximum of the number.
 * @param {number} [option.minimum=-Infinity] Minimum of the number.
 * @param {boolean} [option.negative] A negative number.
 * @param {boolean} [option.positive] A positive number.
 * @param {boolean} [option.prime] A prime number.
 * @param {boolean} [option.safe] An IEEE-754 number.
 * @param {boolean} [option.unsafe] Not an IEEE-754 number.
 * @returns {boolean} Determine result.
 */
declare function isNumber(item: any, option?: {
    exclusiveMaximum?: boolean;
    exclusiveMinimum?: boolean;
    finite?: boolean;
    float?: boolean;
    infinite?: boolean;
    integer?: boolean;
    maximum?: number;
    minimum?: number;
    negative?: boolean;
    positive?: boolean;
    prime?: boolean;
    safe?: boolean;
    unsafe?: boolean;
}): boolean;
//# sourceMappingURL=is-number.d.ts.map