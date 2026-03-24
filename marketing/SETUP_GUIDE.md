# Remembrance App — Marketing Channel Setup Guide

## Overview
This guide sets up an autonomous TikTok + Instagram marketing pipeline for the Remembrance app, inspired by the "Larry" agent workflow from Greg Isenberg's channel.

**Goal:** Drive App Store downloads through viral photo carousel content on TikTok and Instagram.

---

## Step 1: Create Social Media Accounts

### TikTok
1. Download TikTok or go to tiktok.com
2. Sign up with a new account
3. **Username:** `@remembrance.app` (or closest available)
4. **Display Name:** Remembrance
5. **Bio:** "One photo. One quote. Every day. For someone you'll never forget. 💚 Free on the App Store ⬇️"
6. **Link in bio:** Your App Store URL
7. **Profile photo:** App icon or memorial-themed image
8. Switch to a **Business Account** (Settings > Manage Account > Switch to Business Account) for analytics

### Instagram
1. Create a new Instagram account
2. **Username:** `@remembrance.app` (or closest available)
3. **Display Name:** Remembrance — Memorial Photos
4. **Bio:** Same as TikTok
5. **Link in bio:** App Store URL (use Linktree if you want multiple links)
6. Switch to a **Professional Account** for analytics

---

## Step 2: Install OpenClaw

```bash
# Check https://github.com/openclaw for latest install instructions
# Typical install:
npm install -g openclaw

# Or clone and run locally:
git clone https://github.com/openclaw/openclaw.git
cd openclaw
npm install
npm start
```

### Configure OpenClaw
1. Set up a persistent identity (name: "Memorial" or similar)
2. Point it to the skill file: `marketing/openclaw-marketing-skill.md`
3. Connect your OpenAI API key for image generation
4. Connect Postiz API for social posting

---

## Step 3: Set Up Postiz (Social Media Scheduler)

```bash
# Postiz is open-source — self-host or use their cloud
# See: https://postiz.com

# For API integration with OpenClaw:
# 1. Create a Postiz account
# 2. Connect your TikTok and Instagram accounts
# 3. Get your API key
# 4. Add to OpenClaw config
```

---

## Step 4: Get API Keys

You'll need:
- **OpenAI API key** — for GPT-Image generation (slide images)
- **Postiz API key** — for draft uploading
- Store these in a `.env` file (NEVER commit to git):

```bash
# marketing/.env
OPENAI_API_KEY=sk-...
POSTIZ_API_KEY=...
```

---

## Step 5: Run the Marketing Agent

Once everything is connected:

```bash
# Start OpenClaw with the marketing skill
openclaw --skill marketing/openclaw-marketing-skill.md
```

The agent will:
1. Generate 6-slide carousel images (portrait 1024x1536)
2. Add text overlays to slides 1 and 6
3. Write story-driven captions
4. Upload as drafts to TikTok/Instagram via Postiz

**You then:**
1. Open TikTok drafts
2. Add trending audio
3. Hit publish
4. ~60 seconds per post

---

## Posting Schedule

- **Week 1-2:** 2 posts/day (build momentum)
- **Week 3+:** 1 post/day (sustain)
- **Best times for grief/wellness content:**
  - Morning: 7-9am (daily reflection time)
  - Evening: 8-10pm (quiet, emotional browsing)

---

## Tracking Success

Monitor weekly:
- TikTok analytics (views, shares, profile visits)
- Instagram insights (reach, saves, link clicks)
- App Store Connect (downloads, source attribution)
- Goal: 100K views in first week, 50+ downloads
