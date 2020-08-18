# aragonOS <img align="right" src="https://raw.githubusercontent.com/aragon/design/master/readme-logo.png" height="80px" /> [![Travis branch](https://img.shields.io/travis/aragon/aragonOS/master.svg?style=for-the-badge)](https://travis-ci.org/aragon/aragonOS) [![Coveralls branch](https://img.shields.io/coveralls/aragon/aragonOS/master.svg?style=for-the-badge)](https://coveralls.io/github/aragon/aragonOS?branch=master) [![npm](https://img.shields.io/npm/v/@aragon/os.svg?style=for-the-badge)](https://www.npmjs.com/package/@aragon/os)

This repo contains Aragon's reference implementation of [aragonOS](https://hack.aragon.org/docs/aragonos-intro.html).

#### 🚨 Security review status: bug bounty
aragonOS 4 has undergone two independent professional security reviews, and the issues raised have been resolved. However there is a [bug bounty program](https://wiki.aragon.org/dev/bug_bounty/) for rewarding hackers who find security vulnerabilities. There is a bounty pool of $250,000 USD, you can find more information [here](https://wiki.aragon.org/dev/bug_bounty/).

#### 👋 Get started contributing with a [good first issue](https://github.com/aragon/aragonOS/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22).
Don't be shy to contribute even the smallest tweak. Everyone will be especially nice and helpful to beginners to help you get started!

## Documentation

Visit the [Aragon Developer Portal](https://hack.aragon.org/docs/aragonos-intro.html) for in-depth documentation on the [architecture](https://hack.aragon.org/docs/aragonos-ref.html) and different parts of the system.

## Developing aragonOS locally

```sh
yarn install
yarn test

# Lint needs to pass as well
yarn lint
```

## Adding aragonOS as a dependency to your Aragon app

```
npm i --save-dev @aragon/os
```

Check the [Aragon Developer Portal](https://hack.aragon.org) for detailed documentation and tutorials on how to use aragonOS to build an Aragon app.

## Contributing

For more details about contributing to aragonOS, please check the [contributing guide](./CONTRIBUTING.md).
