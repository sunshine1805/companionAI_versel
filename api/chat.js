// api/chat.js
// Updated to use OpenAI instead of Anthropic

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ 
      error: 'Method not allowed',
      success: false 
    });
  }

  // Check if API key exists
  if (!process.env.OPENAI_API_KEY) {
    console.error('OPENAI_API_KEY is not set');
    return res.status(500).json({ 
      error: 'API key not configured',
      success: false 
    });
  }

  try {
    const { messages } = req.body;

    // Validate input
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ 
        error: 'Messages array is required',
        success: false 
      });
    }

    console.log('Received messages:', messages.length);

    // Format messages for OpenAI
    const formattedMessages = [
      {
        role: 'system',
        content: 'You are a compassionate mental health companion for university students. Provide supportive, empathetic, and encouraging responses. Be mindful of serious mental health concerns - if someone expresses thoughts of self-harm or suicide, encourage them to seek immediate professional help from counselors, therapists, or emergency services.'
      },
      ...messages.map(msg => ({
        role: msg.role === 'ai' ? 'assistant' : 'user',
        content: msg.text || msg.content || ''
      }))
    ];

    console.log('Calling OpenAI API...');

    // Call OpenAI API
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini', // Fast and cost-effective
        messages: formattedMessages,
        max_tokens: 1024,
        temperature: 0.7,
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('OpenAI API error:', errorData);
      
      return res.status(response.status).json({ 
        error: 'OpenAI API error',
        message: errorData.error?.message || 'Unknown error',
        success: false 
      });
    }

    const data = await response.json();
    console.log('OpenAI API responded successfully');

    return res.status(200).json({
      reply: data.choices[0].message.content,
      success: true
    });

  } catch (error) {
    console.error('Detailed error:', {
      name: error.name,
      message: error.message,
    });

    return res.status(500).json({ 
      error: 'Internal Server Error',
      message: error.message || 'Unknown error occurred',
      success: false
    });
  }
};