const int8Maximum = 127n;
const int8Minimum = -128n;
const int16Maximum = 32767n;
const int16Minimum = -32768n;
const int32Maximum = 2147483647n;
const int32Minimum = -2147483648n;
const int64Maximum = 9223372036854775807n;
const int64Minimum = -9223372036854775808n;
const uint8Maximum = 255n;
const uint16Maximum = 65535n;
const uint32Maximum = 4294967295n;
const uint64Maximum = 18446744073709551615n;
const uintMinimum = 0n;
/**
 * @private
 * @function integerTypesOutputConvert
 * @param {[bigint,bigint]} output
 * @param {boolean} [asNumber=false]
 * @returns {[bigint,bigint]|[number,number]}
 */
function integerTypesOutputConvert(output, asNumber = false) {
	if (asNumber) {
		return output.map((value) => {
			return Number(value);
		});
	}
	return output;
}
/**
 * @private
 * @function integerTypes
 * @param {string} name
 * @param {boolean} [asNumber=false]
 * @returns {[bigint,bigint]|[number,number]}
 */
function integerTypes(name, asNumber = false) {
	switch (name) {
		case "char":
		case "Char":
		case "int8":
		case "Int8":
			return integerTypesOutputConvert([int8Minimum, int8Maximum], asNumber);
		case "int16":
		case "Int16":
		case "short":
		case "Short":
			return integerTypesOutputConvert([int16Minimum, int16Maximum], asNumber);
		case "int32":
		case "Int32":
		case "rune":
		case "Rune":
			return integerTypesOutputConvert([int32Minimum, int32Maximum], asNumber);
		case "int64":
		case "Int64":
		case "long":
		case "Long":
			return integerTypesOutputConvert([int64Minimum, int64Maximum], asNumber);
		case "byte":
		case "Byte":
		case "uchar":
		case "Uchar":
		case "UChar":
		case "uint8":
		case "Uint8":
		case "UInt8":
			return integerTypesOutputConvert([uintMinimum, uint8Maximum], asNumber);
		case "uint16":
		case "Uint16":
		case "UInt16":
		case "ushort":
		case "Ushort":
		case "UShort":
			return integerTypesOutputConvert([uintMinimum, uint16Maximum], asNumber);
		case "uint32":
		case "Uint32":
		case "UInt32":
			return integerTypesOutputConvert([uintMinimum, uint32Maximum], asNumber);
		case "uint64":
		case "Uint64":
		case "UInt64":
		case "ulong":
		case "Ulong":
		case "ULong":
			return integerTypesOutputConvert([uintMinimum, uint64Maximum], asNumber);
		default:
			throw new Error(`\`${name}\` is not a valid interger type!`);
	}
}
module.exports = integerTypes;
