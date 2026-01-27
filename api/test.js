module.exports = async (req, res) => {
  const apiKey = process.env.OPENAI_API_KEY;
  
  return res.status(200).json({
    hasApiKey: !!apiKey,
    keyPrefix: apiKey ? apiKey.substring(0, 15) : 'NOT_SET',
    keyLength: apiKey ? apiKey.length : 0,
    provider: 'OpenAI'
  });
};