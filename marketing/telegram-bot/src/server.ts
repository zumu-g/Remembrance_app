import express from 'express';
import { createPost, getPost, getRecentPosts, updateImageUrls } from './db.js';
import { notifyNewPost } from './bot.js';
import { generateSlideImages, isFalConfigured } from './image-gen.js';
import type { DraftPost } from './types.js';

const app = express();
app.use(express.json({ limit: '10mb' }));

const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || '';

// Auth middleware for webhook
function webhookAuth(req: express.Request, res: express.Response, next: express.NextFunction): void {
  if (!WEBHOOK_SECRET) {
    // No secret configured — allow all (dev mode)
    next();
    return;
  }

  const auth = req.headers.authorization;
  if (!auth || auth !== `Bearer ${WEBHOOK_SECRET}`) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }
  next();
}

// POST /drafts — submit a new post for approval
app.post('/drafts', webhookAuth, async (req, res) => {
  try {
    const body = req.body as DraftPost;

    // Validate required fields
    if (!body.hook || !body.caption) {
      res.status(400).json({ error: 'Missing required fields: hook, caption' });
      return;
    }

    // Insert into database
    const id = createPost(body);

    // Auto-generate images if prompts provided but no images, and fal.ai is configured
    if (isFalConfigured() && body.imagePrompts && body.imagePrompts.length > 0 && (!body.imageUrls || body.imageUrls.length === 0)) {
      console.log(`Generating ${body.imagePrompts.length} images for post #${id}...`);
      try {
        const generatedUrls = await generateSlideImages(body.imagePrompts, id);
        if (generatedUrls.length > 0) {
          updateImageUrls(id, generatedUrls);
        }
      } catch (err) {
        console.error('Image generation failed:', err);
      }
    }

    const post = getPost(id);

    if (!post) {
      res.status(500).json({ error: 'Failed to create post' });
      return;
    }

    // Notify on Telegram
    await notifyNewPost(post);

    res.status(201).json({
      id: post.id,
      status: post.status,
      message: 'Post submitted for approval. Check Telegram.',
    });
  } catch (err) {
    console.error('Error creating draft:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /drafts — list recent posts
app.get('/drafts', webhookAuth, (_req, res) => {
  const posts = getRecentPosts(20);
  res.json(posts);
});

// GET /drafts/:id — get specific post
app.get('/drafts/:id', webhookAuth, (req, res) => {
  const id = parseInt(req.params.id, 10);
  const post = getPost(id);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }
  res.json(post);
});

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

export default app;
