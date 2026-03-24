#!/usr/bin/env tsx
/**
 * Daily Post Generator
 * Reads from the post content bank and submits one post per day
 * to the Telegram bot webhook for approval.
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const POSTS_DIR = path.join(__dirname, '..', '..', 'posts');
const STATE_FILE = path.join(__dirname, '..', '.post-state.json');
const WEBHOOK_URL = `http://localhost:${process.env.WEBHOOK_PORT || 3847}/drafts`;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || '';

// All hooks from the content bank (posts 01-20 + extras)
const POST_BANK: Array<{
  hook: string;
  caption: string;
  imagePrompts: string[];
  audioDirection?: string;
  notes?: string;
}> = [
  // Post 01 — Grief Ritual
  {
    hook: '"My therapist said I needed a daily grief ritual. This is what I do every morning now."',
    caption: 'My therapist told me grief needs structure. Not a schedule — just something small, every day, to honour them. Remembrance gives me one photo and one quote each morning. Some days it makes me smile. Some days I cry. But I never forget. 💚\n\n#griefjourney #griefhealing #memorial #lovedones #remembrance',
    imagePrompts: [
      'Warm, soft-lit photograph of a person sitting by a window in morning light, holding a cup of tea, looking at a phone with a gentle expression. Muted warm tones, cozy blanket, golden hour light streaming in. Portrait orientation 1024x1536. Photorealistic, editorial style.',
      'Moody, slightly desaturated photograph of a person lying in bed staring at the ceiling, morning light barely coming through curtains. Feeling of emptiness, no direction. Portrait 1024x1536. Photorealistic.',
      'Close-up of hands holding a phone, screen showing a memorial photo app interface (warm green tones). Soft focus background of a cozy room. Warm lighting. Portrait 1024x1536. Photorealistic.',
    ],
    audioDirection: 'Soft, emotional piano or acoustic guitar. Trending sounds in the "healing" or "emotional storytelling" category.',
  },
  // Post 02 — Forgetting Her Face
  {
    hook: '"I was terrified I was forgetting my mum\'s face. Then I found this."',
    caption: "It's been 1,247 days since I lost my mum. Last month I realised I couldn't picture her smile anymore. That terrified me. Now I see her face every morning in Remembrance — a different photo, a different quote. She's not fading anymore.\n\n#grieftok #missingyou #memorial #griefjourney #inmemory",
    imagePrompts: [
      'Close-up of a person\'s hands holding a faded, worn photograph of a woman smiling. Soft natural light, slightly out of focus background. Emotional, nostalgic tone. Warm muted colours. Portrait 1024x1536. Photorealistic.',
      'A phone camera roll scrolled far down, hundreds of tiny thumbnails — the feeling of photos being buried and forgotten. Slightly cold/blue tone to convey neglect. Portrait 1024x1536. Photorealistic.',
      'A phone screen glowing warmly in dim lighting, showing a beautiful memorial photo with a quote underneath. The phone is resting on a bedside table next to a candle. Warm, hopeful tones. Portrait 1024x1536. Photorealistic.',
    ],
    audioDirection: 'Gentle, melancholic piano. Something that builds from sad to hopeful.',
  },
  // Post 03 — Sister's Challenge
  {
    hook: '"My sister asked \'do you even remember her anymore?\' I showed her my phone."',
    caption: "She didn't mean to hurt me. But it cut deep. I opened Remembrance and showed her — 847 of mum's photos, rotating daily, with quotes that feel like they were written just for us. She downloaded it before she left. Now we text each other every morning: \"Did you see today's photo?\" 💚\n\n#griefjourney #sisters #memorial #lovedones #remembrance",
    imagePrompts: [
      'Two women sitting on a sofa, one showing the other something on her phone. Warm living room lighting, emotional atmosphere. Soft focus background with family photos on the wall. Portrait 1024x1536. Photorealistic.',
      'A woman sitting alone in a room, looking at old family photo albums spread across a table. Melancholic but warm lighting. Portrait 1024x1536. Photorealistic.',
      'Two phones side by side on a kitchen table, both showing a memorial photo app with the same person\'s photo. Morning light, coffee cups nearby. Warm tones. Portrait 1024x1536. Photorealistic.',
    ],
    audioDirection: 'Emotional indie/folk track. Something about sisterhood or family bonds.',
  },
  // Post 04 — Dread Mornings
  {
    hook: '"I used to dread mornings. That moment you wake up and remember they\'re gone."',
    caption: "That first second of consciousness when it all comes flooding back. Every single day. I couldn't change that moment. But I could change what comes next. Now I wake up to a photo of her and a quote that somehow always says exactly what I need to hear. Mornings are mine again.\n\n#griefjourney #griefhealing #memorial #remembrance #healingjourney",
    imagePrompts: [
      'A person lying in bed, eyes open, staring at the ceiling. Early morning blue-grey light. Feeling of weight and dread. Bedsheets slightly tangled. Portrait 1024x1536. Photorealistic, cinematic.',
      'The same bedroom but now with warm golden light coming through the curtains. A phone on the bedside table glowing softly. Shift from cold to warm. Portrait 1024x1536. Photorealistic.',
      'Close-up of a phone screen showing a beautiful memorial photo with a warm quote. Soft morning light reflecting off the screen. Hopeful feeling. Portrait 1024x1536. Photorealistic.',
    ],
    audioDirection: 'Starts melancholic, transitions to hopeful. Trending emotional piano or lo-fi.',
  },
  // Post 05 — Never Thought an App
  {
    hook: '"I never thought an app could help with grief. I was wrong."',
    caption: "I've tried journaling. Therapy. Support groups. Meditation apps. None of them stuck. Because none of them understood that I didn't want to \"process\" my grief — I wanted to see his face. Remembrance gets it. One photo. One quote. Every day. No homework. Just him.\n\n#griefhealing #grieftok #memorial #remembrance #missingyou",
    imagePrompts: [
      'A phone screen showing multiple deleted app icons — meditation apps, journal apps. One app remains highlighted with a green glow. Clean desk background. Portrait 1024x1536. Photorealistic.',
      'A person sitting peacefully with their phone, slight smile, looking at a photo. Warm lighting, cozy corner of a room. Feeling of comfort and connection. Portrait 1024x1536. Photorealistic.',
      'A warm, glowing phone screen showing a memorial photo and an inspirational quote. Soft bokeh lights in the background. Evening setting. Portrait 1024x1536. Photorealistic.',
    ],
    audioDirection: 'Uplifting but gentle. Acoustic guitar or warm piano.',
  },
  // Post 06 — Almost Deleted His Photos
  {
    hook: '"I almost deleted all of dad\'s photos to free up storage. This app changed my mind."',
    caption: "I was running out of space. 14,000 photos and I couldn't find his anymore. I nearly deleted the whole folder. Then I found Remembrance. Now his 200 best photos rotate daily with quotes that keep him close. Best decision I ever made.\n\n#grieftok #missingyou #memorial #remembrance #lovedones",
    imagePrompts: [
      'Phone screen showing "Storage Full" warning with a finger hovering over delete button. Tense, cold lighting. Portrait 1024x1536. Photorealistic.',
      'A person scrolling through thousands of phone photos, looking overwhelmed. Blue-tinted lighting. Portrait 1024x1536. Photorealistic.',
      'A person smiling at their phone in warm morning light, seeing a memorial photo. Warm golden tones. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 07 — Kids Never Met Him
  {
    hook: '"My kids never met their grandad. But they see him every morning."',
    caption: "He passed before they were born. I always wondered how to keep him alive for them. Now every morning at breakfast, we look at Remembrance together — his photo, a quote about love or strength. My 4-year-old says \"morning grandad\" to the screen. I can't describe what that feels like.\n\n#griefjourney #grandad #memorial #lovedones #remembrance",
    imagePrompts: [
      'A small child and parent looking at a phone together at a breakfast table. Warm morning light, cereal bowls, cozy kitchen. The phone screen glows warmly. Portrait 1024x1536. Photorealistic.',
      'An old photograph of a smiling grandfather, slightly faded, placed on a mantelpiece with flowers. Warm nostalgic tones. Portrait 1024x1536. Photorealistic.',
      'A child\'s hand pointing at a phone screen showing a man\'s smiling photo. Kitchen setting, morning light. Warm, heartfelt. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 08 — Downloaded 12 Grief Apps
  {
    hook: '"I downloaded 12 grief apps. Only one stuck."',
    caption: "Most grief apps want you to journal, meditate, or talk to strangers. I just wanted to see her. Remembrance gets it — one photo, one quote, every day. No pressure. No homework. Just her.\n\n#griefhealing #grieftok #memorial #remembrance #griefjourney",
    imagePrompts: [
      'Phone home screen with many apps visible, most greyed out or faded, one app glowing green. Clean, modern phone. Portrait 1024x1536. Photorealistic.',
      'A person looking frustrated at their phone, sitting on a couch. Several app notification badges visible. Cool lighting. Portrait 1024x1536. Photorealistic.',
      'Same person now peaceful, holding phone with a warm-glowing memorial photo visible on screen. Warm evening light. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 09 — Mother's Day
  {
    hook: '"Mother\'s Day hits different when she\'s gone. This is how I got through it."',
    caption: "I used to hide on Mother's Day. This year, I opened Remembrance and saw her smiling with me at age 7. The quote was about strength. I cried, but for the first time it felt like healing, not breaking.\n\n#mothersday #missingmum #griefjourney #remembrance #memorial",
    imagePrompts: [
      'A person sitting alone on a park bench, Mother\'s Day cards and flowers visible in a shop window behind them. Bittersweet feeling, soft overcast lighting. Portrait 1024x1536. Photorealistic.',
      'A phone showing a nostalgic photo of a mother and young child, the phone resting on a garden table with flowers. Warm, soft lighting. Portrait 1024x1536. Photorealistic.',
      'Flowers laid at a memorial stone or grave marker. Soft morning light, peaceful setting. Memorial green tones. Portrait 1024x1536. Photorealistic.',
    ],
    notes: 'Post 1-2 weeks before Mother\'s Day',
  },
  // Post 10 — One Year
  {
    hook: '"Today marks one year since I lost her. This is how I survived it."',
    caption: "365 mornings of opening Remembrance. 365 photos. 365 quotes. Some days I almost skipped it. But every time I opened the app, she was there. That's how you survive a year — one morning at a time.\n\n#griefanniversary #oneyear #memorial #remembrance #griefhealing",
    imagePrompts: [
      'A calendar showing 365 days with small check marks on each day. Warm lighting, a candle burning nearby. Feeling of perseverance. Portrait 1024x1536. Photorealistic.',
      'A person holding their phone, tears in their eyes but smiling. Morning light streaming through a window. Bittersweet, hopeful. Portrait 1024x1536. Photorealistic.',
      'A single candle burning in front of a framed photograph. One year anniversary feeling. Warm, intimate lighting. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 11 — Reddit Stranger
  {
    hook: '"A stranger on Reddit told me about this app. It changed everything."',
    caption: "Someone in r/GriefSupport mentioned an app that shows you one photo of your person every day. I thought it would be gimmicky. Three months later, it's the first thing I open every morning. Thank you, stranger.\n\n#grieftok #reddit #memorial #remembrance #griefhealing",
    imagePrompts: [
      'A phone screen showing a Reddit thread about grief support, warm lighting from a desk lamp. Late night browsing feeling. Portrait 1024x1536. Photorealistic.',
      'A person discovering something on their phone, expression changing from skeptical to moved. Cozy room setting. Portrait 1024x1536. Photorealistic.',
      'Morning scene — person opening phone first thing, memorial photo glowing on screen. Warm sunrise light. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 12 — Not About Letting Go
  {
    hook: '"Everyone says \'let go.\' This app says \'hold on differently.\'"',
    caption: "Grief isn't about forgetting. It's about finding a way to carry them with you. Remembrance doesn't try to fix you. It just makes sure you never go a day without seeing their face. That's enough.\n\n#griefjourney #griefhealing #lovedones #remembrance #memorial",
    imagePrompts: [
      'Open hands releasing something into the wind (petals, light). Conflicted feeling. Soft backlit photography. Portrait 1024x1536. Photorealistic.',
      'Same hands now holding a phone showing a loved one\'s photo. The gesture shifts from letting go to holding on. Warm tones. Portrait 1024x1536. Photorealistic.',
      'A person walking through a park, phone in hand, peaceful expression. Golden hour light, trees, memorial green accents. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 13 — Her Birthday
  {
    hook: '"Her birthday is tomorrow. For the first time, I\'m not dreading it."',
    caption: "Last year I couldn't even get out of bed on her birthday. This year, Remembrance showed me a photo of her laughing — really laughing. The quote was about joy. I'm going to celebrate her tomorrow, not mourn her.\n\n#griefjourney #birthday #memorial #remembrance #missingyou",
    imagePrompts: [
      'A birthday cake with unlit candles on a table, an empty chair visible. Bittersweet atmosphere, soft lighting. Portrait 1024x1536. Photorealistic.',
      'A phone screen showing a photo of a woman laughing joyfully. Warm lighting, the viewer smiling slightly. Portrait 1024x1536. Photorealistic.',
      'A person lighting a single candle near a framed photo, small smile on their face. Warm, intimate lighting. Celebration not mourning. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 14 — Notification Changed My Morning
  {
    hook: '"One notification changed how I start every single day."',
    caption: "8am. Every morning. \"Your daily memory is ready.\" It's not a to-do list. It's not news. It's them. And somehow it makes everything that comes after a little easier.\n\n#morningroutine #griefhealing #memorial #remembrance #grieftok",
    imagePrompts: [
      'A phone lock screen showing a gentle notification from a memorial app. Morning light, bedside table, alarm clock nearby. Warm tones. Portrait 1024x1536. Photorealistic.',
      'A person picking up their phone from a bedside table, morning light on their face. Peaceful, anticipatory expression. Portrait 1024x1536. Photorealistic.',
      'Split scene: chaotic morning routine (coffee, keys, rush) vs. one calm moment looking at a memorial photo on phone. Warm vs. cool contrast. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 15 — 7 Years
  {
    hook: '"It\'s been 7 years and I still open this app every morning."',
    caption: "People expect you to \"get over it\" after a year. Two years. Five. But grief doesn't have a timeline. Remembrance doesn't either. 2,555 mornings with his photo and I'm not planning to stop.\n\n#griefjourney #griefhealing #memorial #remembrance #lovedones",
    imagePrompts: [
      'A well-worn phone showing a memorial app, the case slightly aged. Morning coffee routine, kitchen counter. The feeling of years of consistency. Portrait 1024x1536. Photorealistic.',
      'Calendar pages flipping — 7 years of mornings. Warm, time-lapse feeling. Artistic, nostalgic. Portrait 1024x1536. Photorealistic.',
      'An older person peacefully looking at their phone with morning tea. Garden visible through kitchen window. Routine comfort. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 16 — Counsellor Recommended
  {
    hook: '"My grief counsellor asked what app I use. Now she recommends it to everyone."',
    caption: "She noticed I was doing better. I told her about my morning routine with Remembrance. She downloaded it that day. Said it's the first app she's seen that understands grief isn't a problem to solve — it's a relationship to maintain.\n\n#griefcounselling #griefhealing #memorial #remembrance #healingjourney",
    imagePrompts: [
      'A therapy office setting, two people in conversation. Professional but warm atmosphere. Soft lighting, plants in the room. Portrait 1024x1536. Photorealistic.',
      'A therapist looking at a phone screen being shown by a client, expression of genuine interest. Warm office lighting. Portrait 1024x1536. Photorealistic.',
      'A notepad with "Remembrance" written on it among therapy notes, pen resting on it. Warm desk lamp lighting. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 17 — Wedding Photo
  {
    hook: '"His wedding photo came up today. I wasn\'t ready. But I needed it."',
    caption: "Remembrance doesn't let you choose which photo comes up. That's the point. Some mornings it's easy — a holiday snap, a silly face. Some mornings it's the wedding photo. Those are the hardest. And the most important.\n\n#grieftok #widowlife #memorial #remembrance #missingyou",
    imagePrompts: [
      'A phone screen showing an old wedding photograph. The viewer\'s hand is slightly trembling. Emotional, soft lighting. Portrait 1024x1536. Photorealistic.',
      'A wedding ring on a bedside table next to a glowing phone. Morning light, intimate and personal. Portrait 1024x1536. Photorealistic.',
      'A person sitting by a window, holding their phone to their chest, eyes closed. Processing emotion. Warm, peaceful light. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 18 — Therapist Cried
  {
    hook: '"I showed my therapist this app and she started crying."',
    caption: "I didn't mean to make her cry. I just showed her my morning routine — one photo, one quote, one minute of remembering. She said \"this is what continuing bonds looks like.\" I didn't know there was a name for it.\n\n#grieftherapy #continuingbonds #memorial #remembrance #griefhealing",
    imagePrompts: [
      'A therapist with tears in her eyes, moved expression, in a professional office setting. Warm, empathetic atmosphere. Portrait 1024x1536. Photorealistic.',
      'Close-up of a phone being held between two people, showing a memorial photo app. Both sets of hands visible. Warm lighting. Portrait 1024x1536. Photorealistic.',
      'A book spine showing "Continuing Bonds" next to a phone displaying a memorial photo. Therapy office bookshelf. Warm, intellectual tone. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 19 — Free Up Storage
  {
    hook: '"My phone said \'free up storage.\' Every photo it wanted to delete was his."',
    caption: "847 photos of someone who's gone. My phone saw them as data. I see them as everything I have left. Remembrance keeps them safe, surfaced, and meaningful. One photo a day. Not buried in a folder. Present.\n\n#grieftok #missingyou #memorial #remembrance #lovedones",
    imagePrompts: [
      'Phone screen showing storage management suggesting to delete photos. A grid of personal photos visible. Cold, clinical interface lighting. Portrait 1024x1536. Photorealistic.',
      'A person clutching their phone protectively, worried expression. The idea of losing digital memories. Cool lighting. Portrait 1024x1536. Photorealistic.',
      'Same person now relaxed, scrolling through Remembrance app showing curated memorial photos. Warm lighting, relieved expression. Portrait 1024x1536. Photorealistic.',
    ],
  },
  // Post 20 — Father's Day
  {
    hook: '"First Father\'s Day without him. I opened this app and heard his voice in the quote."',
    caption: "He never said \"I'm proud of you\" enough. The quote today was about a father's pride living on in his children. I know he didn't write it. But it felt like he did.\n\n#fathersday #missingdad #griefjourney #remembrance #memorial",
    imagePrompts: [
      'An empty armchair with a folded newspaper and reading glasses. Father\'s Day cards visible on a mantelpiece. Warm, nostalgic lighting. Portrait 1024x1536. Photorealistic.',
      'A person holding their phone, reading a quote, visibly moved. Morning light, kitchen or living room. Portrait 1024x1536. Photorealistic.',
      'A father and child silhouette photo displayed on a phone screen. Sunset tones, warm and emotional. Portrait 1024x1536. Photorealistic.',
    ],
    notes: 'Post 1-2 weeks before Father\'s Day',
  },
];

interface PostState {
  lastPostIndex: number;
  lastPostDate: string;
  postsGenerated: number;
}

function loadState(): PostState {
  try {
    const data = fs.readFileSync(STATE_FILE, 'utf-8');
    return JSON.parse(data);
  } catch {
    return { lastPostIndex: -1, lastPostDate: '', postsGenerated: 0 };
  }
}

function saveState(state: PostState): void {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function getToday(): string {
  return new Date().toISOString().split('T')[0];
}

async function submitPost(post: typeof POST_BANK[number]): Promise<void> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (WEBHOOK_SECRET) {
    headers['Authorization'] = `Bearer ${WEBHOOK_SECRET}`;
  }

  const body = {
    hook: post.hook,
    caption: post.caption,
    imagePrompts: post.imagePrompts,
    audioDirection: post.audioDirection || undefined,
    notes: post.notes || undefined,
    platform: 'both',
  };

  const res = await fetch(WEBHOOK_URL, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Webhook returned ${res.status}: ${err}`);
  }

  const result = await res.json();
  console.log(`✅ Post submitted: #${(result as any).id} — ${(result as any).message}`);
}

export async function generateAndSubmitPost(force = false): Promise<void> {
  const state = loadState();
  const today = getToday();

  // Don't post twice on the same day (unless forced)
  if (state.lastPostDate === today && !force && !process.env.FORCE_POST) {
    console.log(`Already posted today (${today}). Skipping.`);
    return;
  }

  // Get next post (cycle through the bank)
  const nextIndex = (state.lastPostIndex + 1) % POST_BANK.length;
  const post = POST_BANK[nextIndex];

  console.log(`📝 Generating post ${nextIndex + 1}/${POST_BANK.length}`);
  console.log(`   Hook: ${post.hook.slice(0, 60)}...`);

  await submitPost(post);

  saveState({
    lastPostIndex: nextIndex,
    lastPostDate: today,
    postsGenerated: state.postsGenerated + 1,
  });

  console.log(`📊 Total posts generated: ${state.postsGenerated + 1}`);
}

// Run directly if called as script
const isMain = process.argv[1]?.includes('generate-daily-post');
if (isMain) {
  generateAndSubmitPost().catch((err) => {
    console.error('❌ Failed to submit post:', err);
    process.exit(1);
  });
}
