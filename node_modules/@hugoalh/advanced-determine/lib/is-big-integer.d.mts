export default isBigInteger;
/**
 * @function isBigInteger
 * @alias isBigInt
 * @description Determine item is type of big integer or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.even] An even big integer.
 * @param {boolean} [param1.exclusiveMaximum=false] Exclusive maximum of the big integer.
 * @param {boolean} [param1.exclusiveMinimum=false] Exclusive minimum of the big integer.
 * @param {bigint} [param1.maximum=Infinity] Maximum of the big integer.
 * @param {bigint} [param1.minimum=-Infinity] Minimum of the big integer.
 * @param {boolean} [param1.negative] A negative big integer.
 * @param {boolean} [param1.odd] An odd big integer.
 * @param {boolean} [param1.positive] A positive big integer.
 * @param {boolean} [param1.prime] A prime big integer.
 * @param {boolean} [param1.safe] An IEEE-754 big integer.
 * @param {string} [param1.type] Type of the big integer.
 * @param {boolean} [param1.unsafe] Not an IEEE-754 big integer.
 * @returns {boolean} Determine result.
 */
declare function isBigInteger(item: any, { even, exclusiveMaximum, exclusiveMinimum, maximum, minimum, negative, odd, positive, prime, safe, type, unsafe, ...aliases }?: {
    even?: boolean;
    exclusiveMaximum?: boolean;
    exclusiveMinimum?: boolean;
    maximum?: bigint;
    minimum?: bigint;
    negative?: boolean;
    odd?: boolean;
    positive?: boolean;
    prime?: boolean;
    safe?: boolean;
    type?: string;
    unsafe?: boolean;
}): boolean;
//# sourceMappingURL=is-big-integer.d.mts.map