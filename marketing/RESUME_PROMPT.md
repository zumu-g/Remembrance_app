# Resume Prompt — Paste this to continue tomorrow

```
Continue setting up the Remembrance app marketing pipeline. Here's where we left off:

## What's Done
- Telegram bot (@remembrance_marketing_bot) built and working — approves/rejects posts with inline buttons
- Fal.ai image generation integrated — auto-generates carousel slides from prompts
- Blotato API integrated for publishing (drafts-only mode, nothing auto-publishes)
- 20 posts of content written with hooks, captions, and image prompts
- Analytics feedback loop built (/report and /insights commands)
- Personal accounts hardcoded as blocked so marketing never posts to them

## What Needs Doing Next
1. I need to create a Gmail account for Remembrance (e.g. remembranceapp@gmail.com)
2. Create a TikTok account for Remembrance using that Gmail
3. Create an Instagram account for Remembrance using that Gmail
4. Connect both to Blotato and get the account IDs
5. Add the account IDs to marketing/telegram-bot/.env
6. Take app screenshots for carousel slides 4-5 (Today view, Timeline, Quotes)
7. Test the full end-to-end pipeline: submit post → images generate → approve in Telegram → draft appears in TikTok
8. Start posting! Target: 2 posts/day for first 2 weeks

## Known Issue
Node.js DNS resolver times out for api.telegram.org — there's a workaround in bot.ts using a hardcoded IP (149.154.166.110). If the bot crashes on startup, this IP may have changed.

## To Start the Bot
cd marketing/telegram-bot && npm run dev

## To Submit a Test Post
curl -X POST http://localhost:3847/drafts -H "Content-Type: application/json" -d '{"hook": "Test hook", "caption": "Test caption", "imagePrompts": ["A warm photo of morning light through a window, portrait orientation, photorealistic"]}'
```
