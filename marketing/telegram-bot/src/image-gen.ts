// Fal.ai image generation client
// Uses FLUX 1.1 Pro Ultra (raw mode) for natural, candid photorealism
// Downloads images immediately to avoid expired URLs
// Supports visual coherence across carousel slides (Viraloop-inspired)

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const IMAGES_DIR = path.join(__dirname, '..', 'images');

const FAL_API_KEY = process.env.FAL_API_KEY || '';
const FAL_API_URL = 'https://queue.fal.run';

// Anti-stock aesthetic rules — prevents generic AI/stock imagery
const ANTI_STOCK_RULES = [
  'AVOID: shocked/surprised facial expressions, laptop-coffee setups, corporate handshakes, thumbs up, stock photo poses',
  'AVOID: perfect symmetry, overly clean environments, artificial smiles, generic office settings',
  'PREFER: natural imperfections, authentic emotions, lived-in spaces, real textures, candid moments',
].join('. ');

// Photographic style packs — every pack is fully photorealistic, but the
// camera/film, lens, lighting, grade and texture differ so the *look* changes
// markedly from post to post. One pack is chosen per post (coherent across all
// slides of a carousel) and rotated by post id so consecutive days differ.
const STYLE_PACKS: string[] = [
  'Shot on 35mm film, Kodak Portra 400, warm window light, shallow depth of field, fine natural grain.',
  'Shot on Fujifilm Superia 400, cool overcast daylight, candid documentary framing, subtle green colour cast.',
  'Black-and-white Ilford HP5 film, high contrast, deep shadows, visible grain, photojournalistic.',
  'Cinematic digital capture, teal-and-amber colour grade, anamorphic lens flare, shallow focus, filmic.',
  'Medium-format Hasselblad, soft diffused window light, creamy bokeh, ultra-fine detail, gentle tones.',
  'Vintage 1970s Kodachrome look, faded warm tones, gentle vignette, nostalgic grain.',
  'Leica M digital, natural available light, crisp micro-contrast, honest street-photography realism.',
  'CineStill 800T film, tungsten interior light, halated highlights, moody low light, fine grain.',
  'Golden-hour backlight, warm rim light, 50mm f/1.4, soft natural lens flare, shallow focus.',
  'Soft cloudy daylight, muted desaturated palette, Scandinavian minimal mood, 35mm film.',
  'Harsh midday sun, strong directional shadows, high clarity, crisp editorial realism.',
  'Lamp-lit or candle-lit interior, warm low-key chiaroscuro lighting, soft film grain.',
  'Blue-hour early morning, cool tones, soft mist, cinematic stillness, gentle grain.',
  'Polaroid-style instant film, soft focus, washed pastel tones, faded contrast.',
];

/**
 * Pick the photographic style pack for a post. Rotating by post id means
 * consecutive posts (ids increment daily) never repeat a pack until all have
 * been used — no extra state needed. All slides in one post share the pack.
 */
function styleForPost(postId: number): { index: number; pack: string } {
  const index = ((postId % STYLE_PACKS.length) + STYLE_PACKS.length) % STYLE_PACKS.length;
  return { index, pack: STYLE_PACKS[index] };
}

// Ensure images directory exists
if (!fs.existsSync(IMAGES_DIR)) {
  fs.mkdirSync(IMAGES_DIR, { recursive: true });
}

interface FalQueueResponse {
  request_id: string;
  status: string;
  response_url: string;
  status_url: string;
}

interface FalResultResponse {
  images: Array<{ url: string; content_type: string }>;
}

async function falFetch(url: string, options: RequestInit = {}): Promise<Response> {
  return fetch(url, {
    ...options,
    headers: {
      'Authorization': `Key ${FAL_API_KEY}`,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
}

async function downloadImage(url: string, filepath: string): Promise<void> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to download image: ${res.status}`);
  const buffer = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(filepath, buffer);
}

/**
 * Apply anti-stock aesthetic filter to a prompt.
 * Appends rules that steer the model away from generic/stock imagery.
 */
function applyAntiStockFilter(prompt: string): string {
  return `${prompt} ${ANTI_STOCK_RULES}`;
}

/**
 * Extract a visual style reference from the first slide's prompt.
 * Used to maintain coherence across carousel slides — slide 1 sets the
 * visual foundation and subsequent slides reference it.
 */
function extractStyleReference(firstSlidePrompt: string): string {
  // Extract lighting, color, and mood cues from the first slide's prompt
  const lightingMatch = firstSlidePrompt.match(
    /(warm|cold|soft|golden|morning|evening|natural|dim|bright)\s*(light|lighting|tones?|hour)/gi
  );
  const moodMatch = firstSlidePrompt.match(
    /(emotional|peaceful|melancholic|warm|cozy|intimate|hopeful|bittersweet|nostalgic)/gi
  );

  const lighting = lightingMatch ? lightingMatch.join(', ') : 'warm natural lighting';
  const mood = moodMatch ? [...new Set(moodMatch)].slice(0, 3).join(', ') : 'emotional';

  return `[VISUAL COHERENCE: This is part of a carousel series. Match the visual style of the first slide: ${lighting} with ${mood} mood. Same color grading, film grain texture, and photographic technique throughout.]`;
}

async function generateImage(prompt: string, postId: number, slideIndex: number, stylePack: string): Promise<string> {
  // Enhance prompt with the post's chosen photographic style + realism cues
  const enhancedPrompt = `${prompt} ${stylePack} Imperfect framing, real candid moment captured, authentic textures.`;

  // Submit to queue — FLUX 1.1 Pro Ultra in raw mode for natural photorealism
  const submitRes = await falFetch(`${FAL_API_URL}/fal-ai/flux-pro/v1.1-ultra`, {
    method: 'POST',
    body: JSON.stringify({
      prompt: enhancedPrompt,
      aspect_ratio: '2:3', // portrait, matches the previous 1024x1536 framing
      num_images: 1,
      output_format: 'jpeg',
      raw: true, // less processed, more candid/natural look
    }),
  });

  if (!submitRes.ok) {
    const err = await submitRes.text();
    throw new Error(`Fal.ai submit error (${submitRes.status}): ${err}`);
  }

  const queue = await submitRes.json() as FalQueueResponse;

  // Poll for result
  const maxAttempts = 60; // 2 minutes max
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise(r => setTimeout(r, 2000));

    const statusRes = await falFetch(queue.status_url);
    if (!statusRes.ok) continue;

    const status = await statusRes.json() as { status: string };

    if (status.status === 'COMPLETED') {
      const resultRes = await falFetch(queue.response_url);
      if (!resultRes.ok) {
        throw new Error(`Fal.ai result error: ${resultRes.status}`);
      }
      const result = await resultRes.json() as FalResultResponse;
      if (result.images && result.images.length > 0) {
        // Download immediately before URL expires
        const filename = `post-${postId}-slide-${slideIndex}.jpg`;
        const filepath = path.join(IMAGES_DIR, filename);
        await downloadImage(result.images[0].url, filepath);
        console.log(`  💾 Saved: ${filename}`);
        return filepath;
      }
      throw new Error('No images in fal.ai response');
    }

    if (status.status === 'FAILED') {
      throw new Error('Fal.ai image generation failed');
    }
  }

  throw new Error('Fal.ai image generation timed out');
}

export async function generateSlideImages(prompts: string[], postId: number = 0): Promise<string[]> {
  const paths: string[] = [];
  let styleReference = '';

  // One photographic style pack per post — keeps the carousel coherent while
  // making the look change day to day.
  const { index: styleIndex, pack: stylePack } = styleForPost(postId);
  console.log(`🎞️  Style pack #${styleIndex} for post ${postId}: ${stylePack}`);

  for (let i = 0; i < prompts.length; i++) {
    try {
      let prompt = prompts[i];

      // Apply anti-stock filter to all slides
      prompt = applyAntiStockFilter(prompt);

      // For slides 2+, add coherence reference to slide 1's style
      if (i > 0 && styleReference) {
        prompt = `${styleReference} ${prompt}`;
      }

      console.log(`🎨 Generating slide ${i + 1}/${prompts.length}: ${prompts[i].slice(0, 60)}...`);
      const filepath = await generateImage(prompt, postId, i + 1, stylePack);
      paths.push(filepath);

      // After slide 1, extract style reference for coherence
      if (i === 0) {
        styleReference = extractStyleReference(prompts[0]);
      }
    } catch (err) {
      console.error(`Image generation failed for slide ${i + 1}: ${prompts[i].slice(0, 60)}...`, err);
    }
  }

  return paths;
}

export function isFalConfigured(): boolean {
  return Boolean(FAL_API_KEY);
}
