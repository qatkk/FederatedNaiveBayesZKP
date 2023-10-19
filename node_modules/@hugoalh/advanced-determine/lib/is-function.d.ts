export = isFunction;
/**
 * @function isFunction
 * @alias isFn
 * @description Determine item is type of function or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.asynchronous] An asynchronous function.
 * @param {boolean} [param1.generator] A generator function.
 * @returns {boolean} Determine result.
 */
declare function isFunction(item: any, { asynchronous, generator, ...aliases }?: {
    asynchronous?: boolean;
    generator?: boolean;
}): boolean;
//# sourceMappingURL=is-function.d.ts.map