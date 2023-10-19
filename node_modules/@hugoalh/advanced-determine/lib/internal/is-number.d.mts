export default $isNumber;
/**
 * @private
 * @function $isNumber
 * @param {any} item
 * @param {object} [param1={}]
 * @param {boolean} [param1.even]
 * @param {boolean} [param1.exclusiveMaximum=false]
 * @param {boolean} [param1.exclusiveMinimum=false]
 * @param {boolean} [param1.finite]
 * @param {boolean} [param1.float]
 * @param {boolean} [param1.infinite]
 * @param {boolean} [param1.integer]
 * @param {number} [param1.maximum=Infinity]
 * @param {number} [param1.minimum=-Infinity]
 * @param {boolean} [param1.negative]
 * @param {boolean} [param1.odd]
 * @param {boolean} [param1.positive]
 * @param {boolean} [param1.prime]
 * @param {boolean} [param1.safe]
 * @param {boolean} [param1.unsafe]
 * @returns {boolean}
 */
declare function $isNumber(item: any, { even, exclusiveMaximum, exclusiveMinimum, finite, float, infinite, integer, maximum, minimum, negative, odd, positive, prime, safe, unsafe }?: {
    even?: boolean;
    exclusiveMaximum?: boolean;
    exclusiveMinimum?: boolean;
    finite?: boolean;
    float?: boolean;
    infinite?: boolean;
    integer?: boolean;
    maximum?: number;
    minimum?: number;
    negative?: boolean;
    odd?: boolean;
    positive?: boolean;
    prime?: boolean;
    safe?: boolean;
    unsafe?: boolean;
}): boolean;
//# sourceMappingURL=is-number.d.mts.map