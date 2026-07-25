# oss

小さくテストしやすいOSSユーティリティライブラリです。

> このリポジトリは **公開用ミラー** です。
> 開発は別の非公開リポジトリで行われ、レビュー済みのコードだけが公開されます。
> 詳しくは [CONTRIBUTING.md](./CONTRIBUTING.md) を参照してください。

## インストール

```bash
npm install oss
```

## 使い方

```js
import { greet, sum } from "oss";

greet();          // "Hello, world!"
greet("Kenta");   // "Hello, Kenta!"
sum([1, 2, 3]);   // 6
```

## テスト

```bash
npm test
```

## ライセンス

[MIT](./LICENSE)
