export type PostStatus = 'pending' | 'approved' | 'rejected' | 'published' | 'failed';

export interface DraftPost {
  hook: string;
  caption: string;
  imageUrls?: string[];
  imagePrompts?: string[];
  audioDirection?: string;
  notes?: string;
  platform?: 'tiktok' | 'instagram' | 'both';
}

export interface PostRecord {
  id: number;
  hook: string;
  caption: string;
  image_prompts: string | null;
  image_urls: string | null;
  audio_direction: string | null;
  notes: string | null;
  platform: string;
  status: PostStatus;
  reviewer_note: string | null;
  telegram_message_id: number | null;
  telegram_chat_id: number | null;
  postiz_post_id: string | null;
  postiz_response: string | null;
  created_at: string;
  reviewed_at: string | null;
  published_at: string | null;
}

export type HookCategory = 'ritual' | 'forgetting' | 'conflict' | 'discovery' | 'milestone' | 'feature' | 'other';

export interface PostMetrics {
  id: number;
  post_id: number;
  platform: string;
  views: number;
  likes: number;
  comments: number;
  shares: number;
  saves: number;
  profile_visits: number;
  downloads_est: number;
  recorded_at: string;
}

export interface AwaitingInput {
  postId: number;
  field: 'caption' | 'hook' | 'reject_reason' | 'metrics';
}
