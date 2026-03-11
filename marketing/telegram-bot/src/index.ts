import 'dotenv/config';
import dns from 'dns';
// Force IPv4 — Node may try IPv6 first and timeout on some networks
dns.setDefaultResultOrder('ipv4first');

import bot from './bot.js';
import app from './server.js';

const PORT = parseInt(process.env.WEBHOOK_PORT || '3847', 10);

// Validate required env vars
const required = ['TELEGRAM_BOT_TOKEN', 'TELEGRAM_AUTHORIZED_USER_ID'];
for (const key of required) {
  if (!process.env[key]) {
    console.error(`Missing required environment variable: ${key}`);
    process.exit(1);
  }
}

// Start Express webhook server
app.listen(PORT, () => {
  console.log(`📡 Webhook server running on http://localhost:${PORT}`);
  console.log(`   Submit drafts: POST http://localhost:${PORT}/drafts`);
  console.log(`   Health check:  GET  http://localhost:${PORT}/health`);
});

// Start Telegram bot (long polling)
bot.launch().then(() => {
  console.log('🤖 Telegram bot started');
});

// Graceful shutdown
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));
