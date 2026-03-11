// Fal.ai image generation client
// Uses Flux for high-quality portrait images

const FAL_API_KEY = process.env.FAL_API_KEY || '';
const FAL_API_URL = 'https://queue.fal.run';

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

async function generateImage(prompt: string): Promise<string> {
  // Submit to queue
  const submitRes = await falFetch(`${FAL_API_URL}/fal-ai/flux/dev`, {
    method: 'POST',
    body: JSON.stringify({
      prompt,
      image_size: {
        width: 1024,
        height: 1536,
      },
      num_images: 1,
      enable_safety_checker: true,
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
        return result.images[0].url;
      }
      throw new Error('No images in fal.ai response');
    }

    if (status.status === 'FAILED') {
      throw new Error('Fal.ai image generation failed');
    }
  }

  throw new Error('Fal.ai image generation timed out');
}

export async function generateSlideImages(prompts: string[]): Promise<string[]> {
  const urls: string[] = [];

  for (const prompt of prompts) {
    try {
      console.log(`Generating image: ${prompt.slice(0, 60)}...`);
      const url = await generateImage(prompt);
      urls.push(url);
      console.log(`Generated: ${url}`);
    } catch (err) {
      console.error(`Image generation failed for prompt: ${prompt.slice(0, 60)}...`, err);
      // Continue with remaining images rather than failing entirely
    }
  }

  return urls;
}

export function isFalConfigured(): boolean {
  return Boolean(FAL_API_KEY);
}
