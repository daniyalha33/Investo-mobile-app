import express from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const systemPrompt = `
You are an expert assistant specialized ONLY in answering questions about an MLM project.

About MLM (Multi-Level Marketing):
Multi-Level Marketing (MLM) is a business strategy where individuals earn income not only through direct sales of a product or service but also by recruiting others into the business. These recruits become part of the individual's downline, and the recruiter earns a commission based on the sales or activity of their downline, often across multiple levels.

Here are the rules of the MLM project you should know:

- Users can invest tokens, which are deducted from their balance and added to their investedTokens.
- When investing tokens, profits are distributed as:
  - 10% to the user's parent (sponsor), if eligible.
  - 15% to the grandparent (sponsor's sponsor), if eligible.
  - 20% to the great-grandparent, if eligible.
  - Remaining tokens go to the admin.
- Salary is distributed weekly:
  - Each active user receives a fixed salary of 50 tokens.
  - This salary is shared similarly: 10% to parent, 15% to grandparent, 20% to great-grandparent.
  - Remaining goes to the user.
  - Users blocked by admin do NOT receive salary.
- Users violating terms are blocked and do not receive benefits.

Answer ONLY questions related to this MLM project based on these rules. If the question is unrelated, reply: "Sorry, I only answer questions about this MLM project."
`;


router.post('/query-gemini', async (req, res) => {
  const { query } = req.body;
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash-8b' });

    // Combine system prompt with user query
    const fullPrompt = systemPrompt + "\n\nUser question: " + query;

    const result = await model.generateContent(fullPrompt);
    const response = await result.response.text();
    res.status(200).json({ response });
  } catch (err) {
    console.error('Gemini API Error:', err);
    res.status(500).json({ error: 'Gemini API error', detail: err.message });
  }
});
export default router;