import { defineConfig } from "@playwright/test";
import { baseConfig } from "@togarantido/e2e-utils";

export default defineConfig({
  ...baseConfig,
  testDir: "./tests",
  outputDir: "./test-results",
  // Typebot tem boot lento em cold start (Railway free tier). 5min é folga.
  timeout: 5 * 60 * 1000,
});
