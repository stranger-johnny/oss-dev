# oss

A small, well-tested OSS utility library.

> This repository is a **public mirror**. Development happens in a separate
> private repository and only reviewed code is published here. See
> [CONTRIBUTING.md](./CONTRIBUTING.md).

## Install

```bash
npm install oss
```

## Usage

```js
import { greet, sum } from "oss";

greet();          // "Hello, world!"
greet("Kenta");   // "Hello, Kenta!"
sum([1, 2, 3]);   // 6
```

## Development

```bash
npm test
```

## License

[MIT](./LICENSE)
