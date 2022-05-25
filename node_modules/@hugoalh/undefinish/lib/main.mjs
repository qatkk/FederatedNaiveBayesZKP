/**
 * @function undefinish
 * @description Undefinish coalescing.
 * @param {...any} inputs
 * @returns {any}
 */
function undefinish(...inputs) {
	for (let input of inputs) {
		if (typeof input !== "undefined") {
			return input;
		};
	};
	return undefined;
};
export default undefinish;
