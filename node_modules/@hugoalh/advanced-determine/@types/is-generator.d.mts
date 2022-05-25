export default isGenerator;
/**
 * @function isGenerator
 * @description Determine item is type of generator or not.
 * @param {any} item Item that need to determine.
 * @param {object} [option={}] Option.
 * @param {boolean} [option.asynchronous] An asynchronous generator.
 * @returns {boolean} Determine result.
 */
declare function isGenerator(item: any, option?: {
    asynchronous?: boolean;
}): boolean;
//# sourceMappingURL=is-generator.d.mts.map