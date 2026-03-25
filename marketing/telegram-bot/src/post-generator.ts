/**
 * Dynamic Post Generation Engine
 * Creates new hooks and captions algorithmically based on templates
 * and (optionally) performance learnings from past posts.
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LEARNINGS_FILE = path.join(__dirname, '..', 'learnings.json');

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface Learnings {
  categoryPerformance: Record<string, { avgViews: number; avgEngagement: number; postCount: number }>;
  topHookPatterns: string[];
  bestPostingTimes: string[];
  updatedAt: string;
}

export interface GeneratedPost {
  hook: string;
  caption: string;
  imagePrompts: string[];
  audioDirection: string;
  category: string;
  isGenerated: boolean; // true = algorithmically generated, not from static bank
}

// ---------------------------------------------------------------------------
// Template Data
// ---------------------------------------------------------------------------

const HOOK_TEMPLATES: Record<string, string[]> = {
  discovery: [
    '"A stranger on {platform} told me about this app. {timeframe} later, it\'s the first thing I open every morning."',
    '"I found this in {platform}\'s comments section. It changed how I start every day."',
    '"Someone in {community} mentioned an app that shows you one photo of your person every day. I thought it would be gimmicky."',
  ],
  ritual: [
    '"My {professional} said I needed a daily grief ritual. This is what I do every {time} now."',
    '"One {notification_type} changed how I start every single day."',
    '"It\'s been {duration} and I still open this app every morning."',
  ],
  forgetting: [
    '"I was terrified I was forgetting {person}\'s {feature}. Then I found this."',
    '"{person}\'s photos were buried in my camera roll. {quantity} of them. I couldn\'t find {pronoun} anymore."',
    '"My phone said \'free up storage.\' Every photo it wanted to delete was {possessive}."',
  ],
  conflict: [
    '"My {relative} asked \'{challenge_question}\' I showed {pronoun} my phone."',
    '"Everyone says \'{common_advice}.\' This app says \'{counter_advice}.\'"',
    '"My {professional} asked what app I use. Now {pronoun} recommends it to everyone."',
  ],
  milestone: [
    '"Today marks {duration} since I lost {pronoun}. This is how I survived it."',
    '"{event} hits different when {pronoun}\'s gone. This is how I got through it."',
    '"{possessive} {event} is tomorrow. For the first time, I\'m not dreading it."',
  ],
};

const FILL_VALUES: Record<string, string[]> = {
  platform: ['Reddit', 'TikTok', 'a grief forum', 'Instagram', 'Facebook'],
  timeframe: ['Three months', 'Six weeks', 'Two months', 'A year'],
  community: ['r/GriefSupport', 'a grief support group', 'a bereavement forum', 'a widow\'s group'],
  professional: ['therapist', 'grief counsellor', 'bereavement specialist', 'doctor'],
  time: ['morning', 'evening', 'night'],
  notification_type: ['notification', 'morning alert', 'daily reminder'],
  duration: ['7 years', '3 years', '18 months', '547 days', '1,000 days'],
  person: ['mum', 'dad', 'my wife', 'my husband', 'my brother', 'my sister', 'my best friend'],
  feature: ['face', 'smile', 'laugh', 'voice'],
  pronoun: ['her', 'him', 'them'],
  possessive: ['her', 'his', 'their'],
  quantity: ['3,000', '847', '2,400', '1,200'],
  relative: ['sister', 'brother', 'friend', 'landlord', 'colleague'],
  challenge_question: [
    'do you even remember her anymore?',
    'why do you still talk about him?',
    'isn\'t it time to move on?',
  ],
  common_advice: ['let go', 'move on', 'it gets easier', 'time heals'],
  counter_advice: ['hold on differently', 'carry them with you', 'remember beautifully', 'never forget'],
  event: ['Mother\'s Day', 'Father\'s Day', 'Christmas', 'Their birthday', 'The anniversary'],
};

const CAPTION_TEMPLATES: string[] = [
  '{emotional_story}\n\nRemembrance gives me one photo and one quote each morning. {outcome}\n\n{hashtags}',
  '{emotional_story}\n\nNow I wake up to {person}\'s face every morning. {outcome}\n\n{hashtags}',
  '{emotional_story}\n\n{app_description} {outcome}\n\n{hashtags}',
];

const EMOTIONAL_STORIES: string[] = [
  'I didn\'t think anything could make mornings easier. That first second of waking up and remembering they\'re gone — it never gets easier. But what comes after can change.',
  'Grief isn\'t a problem to solve. It\'s a relationship to maintain. I just needed something that understood that.',
  'I tried journals, meditation, support groups. None of them stuck. Because none of them let me just see {possessive} face.',
  'People keep saying it gets easier. It doesn\'t. But it gets different. And that\'s enough.',
  'I was drowning in {quantity} photos and couldn\'t find {pronoun} anymore. Not really.',
  'My {professional} said structure helps. Not a schedule — just one small thing, every day, to honour them.',
  '{person}\'s photos were scattered across three phones and a cloud backup I couldn\'t access. I needed them in one place.',
  'Everyone grieves differently. I just needed to see {possessive} face every morning. That\'s all.',
];

const OUTCOMES: string[] = [
  'Some days it makes me smile. Some days I cry. But I never forget.',
  'It\'s not therapy. It\'s not a fix. It\'s just {pronoun}. Every day.',
  'Best decision I\'ve made since losing {pronoun}.',
  'My {professional} noticed I was doing better. This is the only thing that changed.',
  'I can\'t describe what it feels like. But I\'ll never stop.',
  'Now mornings are mine again.',
  'It doesn\'t fix the grief. It makes sure I don\'t lose {pronoun} twice.',
];

const APP_DESCRIPTIONS: string[] = [
  'Remembrance shows me one photo and one quote every morning. No homework. No pressure. Just {pronoun}.',
  'One photo. One quote. Every day. Remembrance doesn\'t try to fix grief — it honours it.',
  'Remembrance keeps {possessive} photos safe, surfaced, and meaningful. One a day. Not buried in a folder. Present.',
];

const HASHTAG_SETS: string[] = [
  '#griefjourney #griefhealing #memorial #remembrance #lovedones',
  '#grieftok #missingyou #memorial #remembrance #inmemory',
  '#griefhealing #grieftok #memorial #remembrance #healingjourney',
  '#griefjourney #missingmum #missingdad #remembrance #memorial',
];

const SLIDE_TEMPLATES = {
  slide1_emotional: [
    'Warm, soft-lit photograph of a person sitting by a window in morning light, looking at a phone with a gentle expression. Muted warm tones, cozy setting, golden hour light. Portrait 1024x1536. Photorealistic, editorial style.',
    'Close-up of hands holding a faded photograph, soft natural light, slightly out of focus background. Emotional, nostalgic tone. Warm muted colours. Portrait 1024x1536. Photorealistic.',
    'A person sitting quietly with a cup of tea, morning light streaming in, looking at an old photo on their phone. Warm, reflective atmosphere. Portrait 1024x1536. Photorealistic.',
    'A bedside table with a framed photo, a candle, and a phone showing a memorial app. Intimate, warm lighting. Portrait 1024x1536. Photorealistic.',
  ],
  slide2_struggle: [
    'A person scrolling through thousands of phone photos, looking overwhelmed. Blue-tinted lighting, feeling of being lost in memories. Portrait 1024x1536. Photorealistic.',
    'Phone screen showing "Storage Full" warning, a finger hovering over delete. Tense, cold lighting. Portrait 1024x1536. Photorealistic.',
    'A person lying in bed staring at the ceiling, morning light barely coming through curtains. Feeling of emptiness. Cool tones. Portrait 1024x1536. Photorealistic.',
    'An empty chair at a kitchen table, untouched breakfast, morning light. Feeling of absence. Cool blue-grey tones. Portrait 1024x1536. Photorealistic.',
  ],
  slide3_hope: [
    'A person smiling at their phone in warm morning light, seeing a memorial photo. Warm golden tones, relief and comfort. Portrait 1024x1536. Photorealistic.',
    'A phone screen glowing warmly in dim lighting, showing a beautiful memorial photo with a quote. Warm, hopeful tones. Portrait 1024x1536. Photorealistic.',
    'A person walking through a park, phone in hand, peaceful expression. Golden hour light, trees, memorial green accents. Portrait 1024x1536. Photorealistic.',
    'Two phones side by side on a kitchen table, both showing a memorial photo app. Morning light, coffee cups nearby. Warm tones. Portrait 1024x1536. Photorealistic.',
  ],
};

const AUDIO_DIRECTIONS: string[] = [
  'Soft, emotional piano or acoustic guitar. Trending sounds in the "healing" or "emotional storytelling" category.',
  'Gentle, melancholic piano. Something that builds from sad to hopeful.',
  'Starts melancholic, transitions to hopeful. Trending emotional piano or lo-fi.',
  'Uplifting but gentle. Acoustic guitar or warm piano.',
  'Emotional indie/folk track. Something about family bonds or remembrance.',
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function fillTemplate(template: string, usedFills?: Map<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (_match, key: string) => {
    // Re-use the same fill value for the same key within one post
    // (so {pronoun} is consistent throughout)
    if (usedFills?.has(key)) {
      return usedFills.get(key)!;
    }
    const values = FILL_VALUES[key];
    if (!values) return `{${key}}`; // leave unknown placeholders as-is
    const chosen = pick(values);
    usedFills?.set(key, chosen);
    return chosen;
  });
}

// ---------------------------------------------------------------------------
// Learnings loader
// ---------------------------------------------------------------------------

export function loadLearnings(): Learnings | null {
  try {
    const data = fs.readFileSync(LEARNINGS_FILE, 'utf-8');
    return JSON.parse(data) as Learnings;
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Weighted category selection
// ---------------------------------------------------------------------------

function selectCategory(learnings?: Learnings | null): string {
  const categories = Object.keys(HOOK_TEMPLATES);

  if (!learnings?.categoryPerformance) {
    // No learnings — uniform random
    return pick(categories);
  }

  // Build weights from average views (or default 1.0)
  const weights: number[] = categories.map((cat) => {
    const perf = learnings.categoryPerformance[cat];
    if (!perf || perf.avgViews === 0) return 1.0;
    return perf.avgViews;
  });

  // Normalise so the smallest weight is 1.0
  const minWeight = Math.max(Math.min(...weights), 0.1);
  const normalised = weights.map((w) => w / minWeight);

  // Weighted random selection
  const total = normalised.reduce((a, b) => a + b, 0);
  let r = Math.random() * total;
  for (let i = 0; i < categories.length; i++) {
    r -= normalised[i];
    if (r <= 0) return categories[i];
  }

  return categories[categories.length - 1];
}

// ---------------------------------------------------------------------------
// Post generation
// ---------------------------------------------------------------------------

// Track generated hooks within a session to avoid duplicates
const generatedHooks = new Set<string>();

export function generateNewPost(learnings?: Learnings | null): GeneratedPost {
  const category = selectCategory(learnings);
  const templates = HOOK_TEMPLATES[category];

  // Shared fill context so pronoun/possessive stay consistent
  const fills = new Map<string, string>();

  // Pick a person first so related fills are coherent
  const person = pick(FILL_VALUES.person);
  fills.set('person', person);

  // Derive pronoun/possessive from person
  if (['mum', 'my wife', 'my sister'].includes(person)) {
    fills.set('pronoun', 'her');
    fills.set('possessive', 'her');
  } else if (['dad', 'my husband', 'my brother'].includes(person)) {
    fills.set('pronoun', 'him');
    fills.set('possessive', 'his');
  } else {
    fills.set('pronoun', 'them');
    fills.set('possessive', 'their');
  }

  // Generate hook, retrying if it's a duplicate
  let hook = '';
  let attempts = 0;
  while (attempts < 20) {
    const template = pick(templates);
    hook = fillTemplate(template, new Map(fills));
    if (!generatedHooks.has(hook)) {
      generatedHooks.add(hook);
      break;
    }
    attempts++;
  }

  // Generate caption
  const captionTemplate = pick(CAPTION_TEMPLATES);
  const emotionalStory = fillTemplate(pick(EMOTIONAL_STORIES), fills);
  const outcome = fillTemplate(pick(OUTCOMES), fills);
  const appDescription = fillTemplate(pick(APP_DESCRIPTIONS), fills);
  const hashtags = pick(HASHTAG_SETS);

  // Build caption by filling special caption-level placeholders
  let caption = captionTemplate
    .replace('{emotional_story}', emotionalStory)
    .replace('{outcome}', outcome)
    .replace('{app_description}', appDescription)
    .replace('{hashtags}', hashtags);

  // Fill any remaining template vars in caption
  caption = fillTemplate(caption, fills);

  // Generate image prompts (3 slides)
  const imagePrompts = [
    pick(SLIDE_TEMPLATES.slide1_emotional),
    pick(SLIDE_TEMPLATES.slide2_struggle),
    pick(SLIDE_TEMPLATES.slide3_hope),
  ];

  const audioDirection = pick(AUDIO_DIRECTIONS);

  return {
    hook,
    caption,
    imagePrompts,
    audioDirection,
    category,
    isGenerated: true,
  };
}

export function generatePostBatch(count: number): GeneratedPost[] {
  const learnings = loadLearnings();
  const posts: GeneratedPost[] = [];
  for (let i = 0; i < count; i++) {
    posts.push(generateNewPost(learnings));
  }
  return posts;
}

export function shouldGenerateNew(currentIndex: number, bankSize: number): boolean {
  // If we've posted at least as many as the bank size, start generating
  return currentIndex >= bankSize;
}
