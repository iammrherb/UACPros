const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.json());

app.post('/api/proxy', async (req, res) => {
  const { service, query, apiKey } = req.body;
  let url, headers;

  switch (service) {
    case 'openai':
      url = 'https://api.openai.com/v1/completions';
      headers = { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' };
      break;
    case 'deepseek':
      url = 'https://api.deepseek.com/v1/query'; // Adjust URL as per DeepSeek docs
      headers = { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' };
      break;
    case 'anthropic':
      url = 'https://api.anthropic.com/v1/query'; // Adjust URL as per Anthropic docs
      headers = { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' };
      break;
    default:
      return res.status(400).json({ error: 'Invalid AI service' });
  }

  try {
    const response = await axios.post(url, { prompt: query, max_tokens: 100 }, { headers });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'API request failed: ' + error.message });
  }
});

app.listen(3000, () => console.log('Proxy running on port 3000'));
