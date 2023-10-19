/**
 * @function base64
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {boolean} [option.padding]
 * @returns {RegExp}
 */
export function base64(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    padding?: boolean;
}): RegExp;
/**
 * @function base64
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function base64URL(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function bigInteger
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function bigInteger(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash384
 * @alias blake2b384
 * @alias blake384
 * @alias sha384
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash384(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash512
 * @alias blake2b512
 * @alias blake512
 * @alias sha512
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash512(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash224
 * @alias blake2s224
 * @alias blake224
 * @alias sha224
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash224(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash256
 * @alias blake2s256
 * @alias blake256
 * @alias sha256
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash256(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function colourCMYK
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlack="black"]
 * @param {string} [option.groupCyan="cyan"]
 * @param {string} [option.groupMagenta="magenta"]
 * @param {string} [option.groupYellow="yellow"]
 * @returns {RegExp}
 */
export function colourCMYK(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupBlack?: string;
    groupCyan?: string;
    groupMagenta?: string;
    groupYellow?: string;
}): RegExp;
/**
 * @function colourHex
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function colourHex(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function colourHexAlpha
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function colourHexAlpha(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function colourHSL
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupLightness="lightness"]
 * @param {string} [option.groupSaturation="saturation"]
 * @returns {RegExp}
 */
export function colourHSL(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupHue?: string;
    groupLightness?: string;
    groupSaturation?: string;
}): RegExp;
/**
 * @function colourHSLA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupLightness="lightness"]
 * @param {string} [option.groupSaturation="saturation"]
 * @returns {RegExp}
 */
export function colourHSLA(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupAlpha?: string;
    groupHue?: string;
    groupLightness?: string;
    groupSaturation?: string;
}): RegExp;
/**
 * @function colourHWB
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
export function colourHWB(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupBlackness?: string;
    groupHue?: string;
    groupWhiteness?: string;
}): RegExp;
/**
 * @function colourHWBA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
export function colourHWBA(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupAlpha?: string;
    groupBlackness?: string;
    groupHue?: string;
    groupWhiteness?: string;
}): RegExp;
/**
 * @function colourNCol
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlackness="blackness"]
 * @param {string} [option.groupHue="hue"]
 * @param {string} [option.groupWhiteness="whiteness"]
 * @returns {RegExp}
 */
export function colourNCol(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupBlackness?: string;
    groupHue?: string;
    groupWhiteness?: string;
}): RegExp;
/**
 * @function colourRGB
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBlue="blue"]
 * @param {string} [option.groupGreen="green"]
 * @param {string} [option.groupRed="red"]
 * @returns {RegExp}
 */
export function colourRGB(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupBlue?: string;
    groupGreen?: string;
    groupRed?: string;
}): RegExp;
/**
 * @function colourRGBA
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupAlpha="alpha"]
 * @param {string} [option.groupBlue="blue"]
 * @param {string} [option.groupGreen="green"]
 * @param {string} [option.groupRed="red"]
 * @returns {RegExp}
 */
export function colourRGBA(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupAlpha?: string;
    groupBlue?: string;
    groupGreen?: string;
    groupRed?: string;
}): RegExp;
/**
 * @function email
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {string} [option.domain]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupDomain="domain"]
 * @param {string} [option.groupLocal="local"]
 * @param {boolean} [option.ipv4=false]
 * @param {boolean} [option.ipv6=false]
 * @returns {RegExp}
 */
export function email(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    domain?: string;
    exactly?: boolean;
    global?: boolean;
    groupDomain?: string;
    groupLocal?: string;
    ipv4?: boolean;
    ipv6?: boolean;
}): RegExp;
/**
 * @function githubRepository
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function githubRepository(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash128
 * @alias md2
 * @alias md4
 * @alias md5
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash128(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function hash160
 * @alias sha1
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function hash160(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function ip
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function ip(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function ipv4
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function ipv4(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function ipv6
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function ipv6(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function macAddress
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function macAddress(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function md6
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function md6(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function number
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function number(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function regularExpression
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupFlag="flag"]
 * @param {string} [option.groupSource="source"]
 * @returns {RegExp}
 */
export function regularExpression(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupFlag?: string;
    groupSource?: string;
}): RegExp;
/**
 * @function semanticVersioning
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @param {string} [option.groupBuild="build"]
 * @param {string} [option.groupMajor="major"]
 * @param {string} [option.groupMinor="minor"]
 * @param {string} [option.groupPatch="patch"]
 * @param {string} [option.groupPreRelease="prerelease"]
 * @returns {RegExp}
 */
export function semanticVersioning(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
    groupBuild?: string;
    groupMajor?: string;
    groupMinor?: string;
    groupPatch?: string;
    groupPreRelease?: string;
}): RegExp;
/**
 * @function shebang
 * @param {object} [option={}]
 * @param {string} [option.groupCommand="command"]
 * @returns {RegExp}
 */
export function shebang(option?: {
    groupCommand?: string;
}): RegExp;
/**
 * @function url
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 * @note From https://gist.github.com/dperini/729294.
 */
export function url(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
/**
 * @function uuid
 * @param {object} [option={}]
 * @param {boolean} [option.boundary=false]
 * @param {boolean} [option.caseInsensitive=false]
 * @param {boolean} [option.exactly=false]
 * @param {boolean} [option.global=false]
 * @returns {RegExp}
 */
export function uuid(option?: {
    boundary?: boolean;
    caseInsensitive?: boolean;
    exactly?: boolean;
    global?: boolean;
}): RegExp;
export { hash384 as blake2b384, hash512 as blake2b512, hash224 as blake2s224, hash256 as blake2s256, hash224 as blake224, hash256 as blake256, hash384 as blake384, hash512 as blake512, hash128 as md2, hash128 as md4, hash128 as md5, hash160 as sha1, hash224 as sha224, hash256 as sha256, hash384 as sha384, hash512 as sha512 };
//# sourceMappingURL=main.d.ts.map