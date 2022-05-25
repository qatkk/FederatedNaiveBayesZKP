export default isFunction;
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
declare function isFunction(item: any, option?: {
    asynchronous?: boolean;
    generator?: boolean;
}): boolean;
//# sourceMappingURL=is-function.d.mts.map