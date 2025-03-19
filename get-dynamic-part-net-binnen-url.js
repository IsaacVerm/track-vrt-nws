const { chromium } = require('playwright');

async function getDynamicUrlPart() {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  
  // Create a promise that will resolve with our dynamic URL part
  const dataPromise = new Promise(resolve => {
    page.on('request', request => {
      const url = request.url();
      if (url.includes('/_next/data/') && url.includes('/nl/net-binnen.json')) {
        // Extract the dynamic part from the URL using regex
        const match = url.match(/\/_next\/data\/([^/]+)\/nl\/net-binnen\.json/);
        if (match && match[1]) {
          resolve(match[1]);
        }
      }
    });
  });
  
  // Navigate to the page
  await page.goto('https://www.vrt.be/vrtnws/nl/net-binnen/');
  
  // Wait for the promise to resolve or timeout after 10 seconds
  const dynamicPart = await Promise.race([
    dataPromise,
    new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout waiting for request')), 10000))
  ]);
  
  await browser.close();
  return dynamicPart;
}

// Run the function and print the result
getDynamicUrlPart()
  .then(dynamicPart => {
    console.log(dynamicPart);
    require('fs').writeFileSync('dynamic-part-net-binnen-url.txt', dynamicPart);
    process.exit(0);
  })
  .catch(error => {
    console.error('Error:', error);
    process.exit(1);
  });