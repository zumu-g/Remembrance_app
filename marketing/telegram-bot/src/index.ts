import 'dotenv/config';
import dns from 'dns';
import https from 'https';

// Force IPv4 — Node may try IPv6 first and timeout on some networks
dns.setDefaultResultOrder('ipv4first');

import bot from './bot.js';
import app from './server.js';

const PORT = parseInt(process.env.WEBHOOK_PORT || '3847', 10);
const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN!;

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

// --- Custom IPv4-safe polling (replaces telegraf's broken polling on Node v20) ---

function telegramApi(method: string, body?: Record<string, unknown>): Promise<any> {
  return new Promise((resolve, reject) => {
    const postData = body ? JSON.stringify(body) : '{}';
    const req = https.request(
      {
        hostname: 'api.telegram.org',
        path: `/bot${BOT_TOKEN}/${method}`,
        method: 'POST',
        family: 4,
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
        },
        timeout: method === 'getUpdates' ? 60000 : 15000,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            if (!json.ok) reject(new Error(json.description || 'API error'));
            else resolve(json.result);
          } catch {
            reject(new Error(`Invalid JSON: ${data.slice(0, 100)}`));
          }
        });
      }
    );
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Request timeout')); });
    req.write(postData);
    req.end();
  });
}

let offset = 0;
let running = true;

async function poll() {
  let pollCount = 0;
  while (running) {
    try {
      pollCount++;
      if (pollCount <= 3 || pollCount % 10 === 0) {
        console.log(`🔄 Poll #${pollCount} (offset: ${offset})...`);
      }
      const updates = await telegramApi('getUpdates', {
        offset,
        timeout: 30,
        limit: 100,
      });
      if (pollCount <= 3) {
        console.log(`   Poll #${pollCount} returned ${updates.length} updates`);
      }

      if (updates.length > 0) {
        console.log(`📥 Received ${updates.length} update(s)`);
      }

      for (const update of updates) {
        offset = update.update_id + 1;
        const msgText = update.message?.text || update.callback_query?.data || 'unknown';
        console.log(`  Processing update ${update.update_id}: ${msgText}`);
        try {
          await bot.handleUpdate(update);
          console.log(`  ✅ Handled update ${update.update_id}`);
        } catch (err) {
          console.error('Error handling update:', err);
        }
      }
    } catch (err: any) {
      if (err.message !== 'Request timeout') {
        console.error('Polling error:', err.message);
      }
      // Brief pause before retry on error
      await new Promise((r) => setTimeout(r, 1000));
    }
  }
}

async function start() {
  try {
    // Delete any existing webhook
    await telegramApi('deleteWebhook');

    // Get bot info (needed by telegraf internals)
    const me = await telegramApi('getMe');
    bot.botInfo = me;

    console.log(`🤖 Telegram bot @${me.username} started (custom IPv4 polling)`);

    // Start polling loop
    poll();
  } catch (err) {
    console.error('Failed to start bot:', err);
    process.exit(1);
  }
}

start();

// Graceful shutdown
process.once('SIGINT', () => { running = false; process.exit(0); });
process.once('SIGTERM', () => { running = false; process.exit(0); });
