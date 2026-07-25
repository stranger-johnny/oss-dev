/**
 * Public API of the `oss` package.
 *
 * NOTE: Everything under `public/` is mirrored to the public `oss` repository
 * by the `sync-public` GitHub Actions workflow. Do NOT put private/internal
 * code here.
 */

/**
 * Build a friendly greeting.
 *
 * @param {string} [name="world"] The name to greet.
 * @returns {string} A greeting message.
 */
export function greet(name = "world") {
  if (typeof name !== "string") {
    throw new TypeError("name must be a string");
  }
  const trimmed = name.trim();
  return `Hello, ${trimmed === "" ? "world" : trimmed}!`;
}

/**
 * Sum a list of numbers.
 *
 * @param {number[]} [values=[]] Numbers to add together.
 * @returns {number} The total.
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
