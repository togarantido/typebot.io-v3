import { test, expect } from "@playwright/test";
import {
  TypebotPage,
  pickTestCpf,
  getStagingUrls,
  extractQuoteIdFromUrl,
} from "@togarantido/e2e-utils";

/**
 * Smokes do fork self-hosted do Typebot (apps/viewer). Validam que o
 * flow `ifood-001-e2e` carrega e completa, redirecionando pro checkout.
 *
 * Pré-requisito: o flow dedicado `ifood-001-e2e` deve estar publicado
 * no viewer de staging — clonado do `ifood-001-urlv3` (ver Sprint 0).
 */

test.describe("typebot fork: smokes", () => {
  test("@smoke viewer carrega e renderiza primeiro input", async ({ page }) => {
    const { typebot } = getStagingUrls();
    const bot = new TypebotPage(page);
    await bot.goto(typebot);

    // Confirma que o primeiro input do flow renderizou.
    await expect(
      page.locator('input:visible:not([type="hidden"]), textarea:visible')
    ).toBeVisible({ timeout: 60_000 });
  });

  test("@smoke flow completo redireciona pro checkout", async ({ page }) => {
    const { typebot } = getStagingUrls();
    const bot = new TypebotPage(page);
    await bot.goto(typebot);

    await bot.fillFunnel({
      cpf: pickTestCpf(),
      name: "TESTE SMOKE",
      email: "smoke@togarantido.com.br",
    });

    await page.waitForURL(/\/select-plan(?:-promo)?\//, { timeout: 120_000 });

    const quoteId = extractQuoteIdFromUrl(page.url());
    expect(quoteId, "URL final do flow deve ter quoteId").toBeTruthy();
  });
});
