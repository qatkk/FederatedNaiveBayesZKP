# Undefinish (NodeJS)

[`Undefinish.NodeJS`](https://github.com/hugoalh-studio/undefinish-nodejs)
[![GitHub Contributors](https://img.shields.io/github/contributors/hugoalh-studio/undefinish-nodejs?label=Contributors&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/graphs/contributors)
[![GitHub Issues](https://img.shields.io/github/issues-raw/hugoalh-studio/undefinish-nodejs?label=Issues&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/hugoalh-studio/undefinish-nodejs?label=Pull%20Requests&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/hugoalh-studio/undefinish-nodejs?label=Discussions&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/discussions)
[![GitHub Stars](https://img.shields.io/github/stars/hugoalh-studio/undefinish-nodejs?label=Stars&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hugoalh-studio/undefinish-nodejs?label=Forks&logo=github&logoColor=ffffff&style=flat-square)](https://github.com/hugoalh-studio/undefinish-nodejs/network/members)
![GitHub Languages](https://img.shields.io/github/languages/count/hugoalh-studio/undefinish-nodejs?label=Languages&logo=github&logoColor=ffffff&style=flat-square)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/hugoalh-studio/undefinish-nodejs?label=Grade&logo=codefactor&logoColor=ffffff&style=flat-square)](https://www.codefactor.io/repository/github/hugoalh-studio/undefinish-nodejs)
[![LGTM Alerts](https://img.shields.io/lgtm/alerts/g/hugoalh-studio/undefinish-nodejs?label=Alerts&logo=lgtm&logoColor=ffffff&style=flat-square)
![LGTM Grade](https://img.shields.io/lgtm/grade/javascript/g/hugoalh-studio/undefinish-nodejs?label=Grade&logo=lgtm&logoColor=ffffff&style=flat-square)](https://lgtm.com/projects/g/hugoalh-studio/undefinish-nodejs)
[![License](https://img.shields.io/static/v1?label=License&message=MIT&color=brightgreen&style=flat-square)](./LICENSE.md)

| **Release** | **Latest** (![GitHub Latest Release Date](https://img.shields.io/github/release-date/hugoalh-studio/undefinish-nodejs?label=%20&style=flat-square)) | **Pre** (![GitHub Latest Pre-Release Date](https://img.shields.io/github/release-date-pre/hugoalh-studio/undefinish-nodejs?label=%20&style=flat-square)) |
|:-:|:-:|:-:|
| [**GitHub**](https://github.com/hugoalh-studio/undefinish-nodejs/releases) ![GitHub Total Downloads](https://img.shields.io/github/downloads/hugoalh-studio/undefinish-nodejs/total?label=%20&style=flat-square) | ![GitHub Latest Release Version](https://img.shields.io/github/release/hugoalh-studio/undefinish-nodejs?sort=semver&label=%20&style=flat-square) | ![GitHub Latest Pre-Release Version](https://img.shields.io/github/release/hugoalh-studio/undefinish-nodejs?include_prereleases&sort=semver&label=%20&style=flat-square) |
| [**NPM**](https://www.npmjs.com/package/@hugoalh/undefinish) ![NPM Total Downloads](https://img.shields.io/npm/dt/@hugoalh/undefinish?label=%20&style=flat-square) | ![NPM Latest Release Version](https://img.shields.io/npm/v/@hugoalh/undefinish/latest?label=%20&style=flat-square) | ![NPM Latest Pre-Release Version](https://img.shields.io/npm/v/@hugoalh/undefinish/pre?label=%20&style=flat-square) |

## 📝 Description

A NodeJS module to provide a better and easier coalescing, similar to the [function default parameter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters).

Although the [nullish coalescing operator (`??`)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing_operator) is an improved operator from the [OR operator (`||`)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Logical_OR), it is still not good enough due to it considers `null` is an undefined value, even though this is defined and/or as expected.

The [conditional (ternary) operator (`?:`)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Conditional_Operator) maybe good:

```js
(typeof a === "undefined") ? 1 : a;
```

But it is not that good when need to have many:

```js
(typeof a === "undefined") ? (
  (typeof b === "undefined") ? (
    (typeof c === "undefined") ? (
      (typeof d === "undefined") ? (
        (typeof e === "undefined") ? 1 : e
      ) : d
    ) : c
  ) : b
) : a;
```

Much cleaner with Undefinish:

```js
undefinish(a, b, c, d, e, 1);
```

## 📚 Documentation

### Getting Started

#### Install

NodeJS (>= v6.9.0) + NPM (>= v3.10.8):

```sh
npm install @hugoalh/undefinish
```

#### Use In CommonJS

```js
const undefinish = require("@hugoalh/undefinish");
```

#### Use In ModuleJS

```js
import undefinish from "@hugoalh/undefinish";
```

### API

```ts
undefinish(
  ...inputs: any[]
): any
```

### Example

```js
let input = {
  displayName: null,
  age: 8
};

input.username ?? input.name ?? input.displayName ?? "owl";
//=> "owl"

undefinish(input.username, input.name, input.displayName, "owl");
//=> null
```
