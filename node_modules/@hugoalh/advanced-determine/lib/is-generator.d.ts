export = isGenerator;
/**
 * @function isGenerator
 * @description Determine item is type of generator or not.
 * @param {any} item Item that need to determine.
 * @param {object} [param1={}] Options.
 * @param {boolean} [param1.asynchronous] An asynchronous generator.
 * @returns {boolean} Determine result.
 */
declare function isGenerator(item: any, { asynchronous, ...aliases }?: {
    asynchronous?: boolean;
}): boolean;
//# sourceMappingURL=is-generator.d.ts.map