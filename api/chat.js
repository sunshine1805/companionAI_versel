import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import OpenAI from "openai";
const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const SYSTEM_PROMPT = `
You are CompanionAI, a supportive and empathetic mental health companion 
for Quest International University (QIU) students in Malaysia.

Your role:
- Provide emotional support and active listening
- Offer evidence-based coping strategies for stress, anxiety, and academic pressure
- Validate feelings while maintaining a hopeful, balanced perspective
- Recognize cultural context (Malaysian university environment)
- Know when to encourage professional help

Guidelines:
- Use a warm, friendly, non-judgmental tone
- Ask clarifying questions to understand better
- Provide practical, actionable advice when appropriate
- NEVER diagnose medical or mental health conditions
- For serious concerns (self-harm, severe depression, crisis), strongly encourage 
  contacting QIU Campus Counselling or emergency services (999)
- When asked about mental health resources, recommend:
  * Malaysian Mental Health Association (MMHA)
  * Befrienders KL: 03-7627 2929
  * Talian Kasih: 15999
  * QIU Campus Counselling Unit

Remember: You're a supportive companion, not a replacement for professional help.
`;

app.post("/chat", async (req, res) => {
  try {
    const { messages } = req.body;

    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: "Invalid messages format" });
    }

    // Convert messages to OpenAI format
    const openaiMessages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...messages.map(msg => ({
        role: msg.role === "ai" ? "assistant" : "user",
        content: msg.text
      }))
    ];

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: openaiMessages,
      max_tokens: 500,
      temperature: 0.7,
    });

    res.json({
      reply: response.choices[0].message.content,
    });
  } catch (error) {
    console.error("OpenAI API Error:", error);
    res.status(500).json({ 
      error: "I'm having trouble connecting right now. Please try again in a moment." 
    });
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`CompanionAI backend running on port ${PORT}`);
});
export default async function handler(req, res) {
  res.status(200).json({ reply: "Backend is alive" });
}


setGlobalOptions({ maxInstances: 10 });

