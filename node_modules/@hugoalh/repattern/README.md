# REPattern (NodeJS)

[`REPattern.NodeJS`](https://github.com/hugoalh-studio/repattern-nodejs)
[![GitHub Contributors](https://img.shields.io/github/contributors/hugoalh-studio/repattern-nodejs?label=Contributors&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues-raw/hugoalh-studio/repattern-nodejs?label=Issues&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/hugoalh-studio/repattern-nodejs?label=Pull%20Requests&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/hugoalh-studio/repattern-nodejs?label=Discussions&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/discussions)
[![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/repattern-nodejs?label=Stars&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hugoalh-studio/repattern-nodejs?label=Forks&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/repattern-nodejs/network/members)
![GitHub Languages](https://img.shields.io/github/languages/count/hugoalh-studio/repattern-nodejs?label=Languages&logo=github&logoColor=ffffff&style=flat-square)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/repattern-nodejs?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square)](https://www.codefactor.io/repository/github/hugoalh-studio/repattern-nodejs)
[![LGTM Alerts](https://img.shields.io/lgtm/alerts/g/hugoalh-studio/repattern-nodejs?label=Alerts&logo=lgtm&logoColor=ffffff&style=flat-square)
![LGTM Grade](https://img.shields.io/lgtm/grade/javascript/g/hugoalh-studio/repattern-nodejs?label=Grade&logo=lgtm&logoColor=ffffff&style=flat-square)](https://lgtm.com/projects/g/hugoalh-studio/repattern-nodejs)
[![License](https://img.shields.io/static/v1?label=License&message=MIT&color=brightgreen&style=flat-square)](./LICENSE.md)

| **Release** | **Latest** (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/repattern-nodejs?label=%20&style=flat-square)) | **Pre** (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/repattern-nodejs?label=%20&style=flat-square)) |
|:-:|:-:|:-:|
| [**GitHub**](https://github.com/hugoalh-studio/repattern-nodejs/releases) ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/repattern-nodejs/total?label=%20&style=flat-square) | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/repattern-nodejs?sort=semver&label=%20&style=flat-square) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/repattern-nodejs?include_prereleases&sort=semver&label=%20&style=flat-square) |
| [**NPM**](https://www.npmjs.com/package/@hugoalh/repattern) ![NPM Total Downloads](https://img.shields.io/npm/dt/@hugoalh/repattern?label=%20&style=flat-square) | ![NPM Latest Release Version](https://img.shields.io/npm/v/@hugoalh/repattern/latest?label=%20&style=flat-square) | ![NPM Latest Pre-Release Version](https://img.shields.io/npm/v/@hugoalh/repattern/pre?label=%20&style=flat-square) |

## 📝 Description

A NodeJS module to provide regular expression pattern.

### 🌟 Feature

- Customizable flags
- Include standard named capture groups (and configable)

### Pattern

| **Legend** | **Description** |
|:-:|:--|
| ♑ | Include standard named capture groups (and configable). |

- **`base64`:** Base 64. Additional flags:
  - **`padding?`:** `<boolean>` Base 64 padding.
    - **`false`:** Enforce no padding.
    - **`true`:** Enforce padding.
    - **`undefined`:** Optional padding.
- **`base64URL`:** Base 64 URL.
- **`bigInteger`:** Big integer number.
- **`blake2b384`:** BLAKE 2 384.
- **`blake2b512`:** BLAKE 2 512.
- **`blake2s224`:** BLAKE 2 224.
- **`blake2s256`:** BLAKE 2 256.
- **`blake224`:** BLAKE 224.
- **`blake256`:** BLAKE 256.
- **`blake384`:** BLAKE 384.
- **`blake512`:** BLAKE 512.
- **`colourCMYK` ♑:** CMYK colour.
- **`colourHex`:** Hex colour.
- **`colourHexAlpha`:** Hex-alpha colour.
- **`colourHSL` ♑:** HSL colour.
- **`colourHSLA` ♑:** HSLA colour.
- **`colourHWB` ♑:** HWB colour.
- **`colourHWBA` ♑:** HWBA colour.
- **`colourNCol` ♑:** NCol colour.
- **`colourRGB` ♑:** RGB colour.
- **`colourRGBA` ♑:** RGBA colour.
- **`email` ♑:** Electronic mail address. Additional flags:
  - **`domain?`:** `<string>` Electronic mail address domain.
  - **`ipv4?`:** `<boolean = false>` Allow IPV4 as the electronic mail address domain.
  - **`ipv6?`:** `<boolean = false>` Allow IPV6 as the electronic mail address domain.
- **`githubRepository`:** GitHub repository.
- **`hash128`:** Hash 128.
- **`hash160`:** Hash 160.
- **`hash224`:** Hash 224.
- **`hash256`:** Hash 256.
- **`hash384`:** Hash 384.
- **`hash512`:** Hash 512.
- **`ip`:** Internet Protocol address version 4 and 6.
- **`ipv4`:** Internet Protocol address version 4.
- **`ipv6`:** Internet Protocol address version 6.
- **`macAddress`:** MAC address.
- **`md2`:** Message Digest 2.
- **`md4`:** Message Digest 4.
- **`md5`:** Message Digest 5.
- **`md6`:** Message Digest 6.
- **`number`:** Number.
- **`regularExpression` ♑:** Regular expression.
- **`semanticVersioning` ♑:** Semantic Versioning version 2.
- **`sha1`:** Secure Hash Algorithm 1.
- **`sha224`:** Secure Hash Algorithm 2 224, Secure Hash Algorithm 3 224.
- **`sha256`:** Secure Hash Algorithm 2 256, Secure Hash Algorithm 3 256.
- **`sha384`:** Secure Hash Algorithm 2 384, Secure Hash Algorithm 3 384.
- **`sha512`:** Secure Hash Algorithm 2 512, Secure Hash Algorithm 3 512.
- **`shebang` ♑:** Shebang.
  > **⚠ Important:** Not support flags.
- **`url`:** Uniform Resource Locator.
- **`uuid`:** Universally Unique Identifier.

### Flag (Common)

- **`boundary?`:** `<boolean = false>` Boundary; Cannot use with flag `exactly`.
- **`caseInsensitive?`:** `<boolean = false>` Case insensitive.
- **`exactly?`:** `<boolean = false>` Exact(ly); Cannot use with flag `boundary`.
- **`global?`:** `<boolean = false>` Global.

## 📚 Documentation

### Getting Started

#### Install

NodeJS (>= v14.15.0) + NPM (>= v6.14.8):

```sh
npm install @hugoalh/repattern
```

#### Use In CommonJS

```js
const repattern = require("@hugoalh/repattern");
```

#### Use In ModuleJS

```js
import * as repattern from "@hugoalh/repattern";
```

### API

```ts
repattern.<patternName>(
  flag?: object = {}
): RegExp
```
