const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const outputDir = path.join(__dirname, '../visual assets');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const logoPath = path.join(__dirname, '../assets/copyrights/astra-logo.png');

const screenshots = [
  '/Users/zicmu/.gemini/antigravity-ide/brain/e2233c13-f49a-4da1-b3ae-7405e4e29fe6/.user_uploaded/media_1789808503773.png',
  '/Users/zicmu/.gemini/antigravity-ide/brain/e2233c13-f49a-4da1-b3ae-7405e4e29fe6/.user_uploaded/media_1789810552165.png',
  '/Users/zicmu/.gemini/antigravity-ide/brain/e2233c13-f49a-4da1-b3ae-7405e4e29fe6/.user_uploaded/media_1789811970186.png',
  '/Users/zicmu/.gemini/antigravity-ide/brain/e2233c13-f49a-4da1-b3ae-7405e4e29fe6/.user_uploaded/media_1789811979437.png',
  '/Users/zicmu/.gemini/antigravity-ide/brain/e2233c13-f49a-4da1-b3ae-7405e4e29fe6/.user_uploaded/media_1789815672275.jpg'
];

async function generateAssets() {
  try {
    console.log('Generating App Icon (512x512)...');
    await sharp(logoPath)
      .resize(512, 512, { fit: 'contain', background: { r: 255, g: 255, b: 255, alpha: 1 } })
      .toFile(path.join(outputDir, 'app_icon.png'));

    console.log('Generating Feature Graphic (1024x500)...');
    // Create a 1024x500 dark background and composite the logo in the center
    const featureLogo = await sharp(logoPath)
      .resize(400, 400, { fit: 'inside' })
      .toBuffer();
    
    await sharp({
      create: {
        width: 1024,
        height: 500,
        channels: 4,
        background: { r: 18, g: 18, b: 18, alpha: 1 } // Dark background matching app theme
      }
    })
    .composite([{ input: featureLogo, gravity: 'center' }])
    .toFile(path.join(outputDir, 'feature_graphic.png'));

    console.log('Generating Phone Screenshots (1080x1920)...');
    for (let i = 0; i < screenshots.length; i++) {
      const file = screenshots[i];
      if (fs.existsSync(file)) {
        await sharp(file)
          .resize(1080, 1920, { 
            fit: 'contain', 
            background: { r: 0, g: 0, b: 0, alpha: 1 } 
          })
          .jpeg({ quality: 90 }) // JPEG for safety to keep under 8MB
          .toFile(path.join(outputDir, `screenshot_${i + 1}.jpg`));
        console.log(`- Created screenshot_${i + 1}.jpg`);
      } else {
        console.warn(`File not found: ${file}`);
      }
    }
    
    console.log('All visual assets generated successfully!');
  } catch (err) {
    console.error('Error generating assets:', err);
  }
}

generateAssets();
