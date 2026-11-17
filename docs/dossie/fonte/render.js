const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const [, , html, out] = process.argv;
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(html), { waitUntil: 'networkidle' });
  await page.evaluate(() => document.fonts.ready);
  const foot = `<div style="width:100%;font-family:Inter,sans-serif;font-size:7.5px;color:#9ca3af;padding:0 16mm;display:flex;justify-content:space-between">
    <span>PD3-302 · DFI302 — Dossiê técnico</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`;
  await page.pdf({ path: out, format: 'A4', printBackground: true, preferCSSPageSize: true,
    displayHeaderFooter: true, headerTemplate: '<div></div>', footerTemplate: foot,
    margin: { top: '18mm', bottom: '18mm', left: '16mm', right: '16mm' } });
  await browser.close();
  console.log('ok');
})();
