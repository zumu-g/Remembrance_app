import type { Context, MiddlewareFn } from 'telegraf';

const AUTHORIZED_USER_ID = parseInt(process.env.TELEGRAM_AUTHORIZED_USER_ID || '0', 10);

export const authMiddleware: MiddlewareFn<Context> = (ctx, next) => {
  const userId = ctx.from?.id;
  if (!userId || userId !== AUTHORIZED_USER_ID) {
    return; // silently ignore unauthorized users
  }
  return next();
};
