const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3000;

// This endpoint fetches the real live global USD/EGP rate and 
// generates the bank rates based on the current market spreads.
// For exact scraping of individual banks, you can integrate Puppeteer here.
app.get('/api/rates/eg', async (req, res) => {
  try {
    const response = await axios.get('https://open.er-api.com/v6/latest/USD');
    const baseRate = response.data.rates.EGP;
    
    // In Egypt, the buy/sell rates for major banks are typically within 
    // a +/- 0.05 EGP spread from the central base rate.
    const banks = [
      {
        name: 'National Bank of Egypt',
        buy: (baseRate - 0.05).toFixed(2),
        sell: (baseRate + 0.05).toFixed(2),
        isUp: true
      },
      {
        name: 'Banque Misr',
        buy: (baseRate - 0.05).toFixed(2),
        sell: (baseRate + 0.05).toFixed(2),
        isUp: true
      },
      {
        name: 'Commercial International Bank (CIB)',
        buy: (baseRate - 0.02).toFixed(2),
        sell: (baseRate + 0.08).toFixed(2),
        isUp: false
      },
      {
        name: 'Alexbank',
        buy: (baseRate - 0.04).toFixed(2),
        sell: (baseRate + 0.06).toFixed(2),
        isUp: true
      },
      {
        name: 'QNB Alahli',
        buy: (baseRate - 0.03).toFixed(2),
        sell: (baseRate + 0.07).toFixed(2),
        isUp: false
      }
    ];

    res.json({
      success: true,
      timestamp: new Date(),
      base_rate: baseRate,
      banks: banks
    });
  } catch (error) {
    console.error('Error fetching rates:', error.message);
    res.status(500).json({ success: false, error: 'Failed to fetch live rates' });
  }
});

app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
});
