/**
 * `oss` パッケージの公開API。
 *
 * `public/` 配下は GitHub Actions により公開リポジトリ `oss` へ同期されます。
 * 非公開コードや内部用コードは置かないでください。
 */

/**
 * あいさつ文を作成する。
 *
 * @param {string} [name="world"] あいさつ対象の名前。
 * @returns {string} あいさつ文。
 */
export function greet(name = "world") {
  if (typeof name !== "string") {
    throw new TypeError("name must be a string");
  }
  const trimmed = name.trim();
  return `Hello, ${trimmed === "" ? "world" : trimmed}!`;
}

/**
 * 数値の配列を合計する
 *
 * @param {number[]} [values=[]] 合計する数値の配列。
 * @returns {number} 合計値。
 */
export function sum(values = []) {
  if (!Array.isArray(values)) {
    throw new TypeError("values must be an array");
  }
  return values.reduce((total, value) => {
    if (typeof value !== "number" || Number.isNaN(value)) {
      throw new TypeError("values must contain only numbers");
    }
    return total + value;
  }, 0);
}
