import 'dotenv/config';
import dns from 'dns';
import net from 'net';
// Force IPv4 — Node may try IPv6 first and timeout on some networks
dns.setDefaultResultOrder('ipv4first');
// Disable Node 20 happy eyeballs (autoSelectFamily) which hangs with custom DNS lookups
if (typeof net.setDefaultAutoSelectFamily === 'function') {
  net.setDefaultAutoSelectFamily(false);
}

// Monkey-patch DNS lookup to hardcode api.telegram.org → known IPv4
// This ensures ALL HTTP libraries (including Telegraf's internal node-fetch) use the right IP
const originalLookup = dns.lookup;
dns.lookup = function(hostname: any, optionsOrCb: any, maybeCb?: any) {
  if (hostname === 'api.telegram.org') {
    const cb = typeof optionsOrCb === 'function' ? optionsOrCb : maybeCb;
    const opts = typeof optionsOrCb === 'object' ? optionsOrCb : {};
    if (typeof cb === 'function') {
      if (opts.all) {
        cb(null, [{ address: '149.154.166.110', family: 4 }]);
      } else {
        cb(null, '149.154.166.110', 4);
      }
      return;
    }
  }
  return (originalLookup as any).apply(dns, [hostname, optionsOrCb, maybeCb].filter(a => a !== undefined));
} as any;

import bot from './bot.js';
import app from './server.js';
import { startScheduler } from './scheduler.js';

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
  console.log('🤖 Telegram bot started (long polling)');
}).catch((err: Error) => {
  console.error('Failed to start Telegram bot:', err.message);
});

// Start daily post scheduler — submits one post at 9:00 AM for approval
const scheduleHour = parseInt(process.env.SCHEDULE_HOUR || '9', 10);
const scheduleMinute = parseInt(process.env.SCHEDULE_MINUTE || '0', 10);
startScheduler(scheduleHour, scheduleMinute);

// Graceful shutdown
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));
