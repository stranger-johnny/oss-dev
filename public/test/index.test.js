import assert from "node:assert/strict";
import { test } from "node:test";

import { greet, sum } from "../src/index.js";

test("greet() defaults to world", () => {
  assert.equal(greet(), "Hello, world!");
});

test("greet(name) uses the given name", () => {
  assert.equal(greet("Kenta"), "Hello, Kenta!");
});

test("greet() trims and falls back to world when blank", () => {
  assert.equal(greet("  "), "Hello, world!");
});

test("greet() rejects non-string input", () => {
  assert.throws(() => greet(123), TypeError);
});

test("sum() adds numbers", () => {
  assert.equal(sum([1, 2, 3]), 6);
});

test("sum() defaults to 0", () => {
  assert.equal(sum(), 0);
});

test("sum() rejects non-number members", () => {
  assert.throws(() => sum([1, "2"]), TypeError);
});
