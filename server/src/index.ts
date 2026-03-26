import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import http from 'http';
import path from 'path';

import { initSocket } from './socket';
import authRouter from './routes/auth';
import usersRouter from './routes/users';
import itemsRouter from './routes/items';
import swipesRouter from './routes/swipes';
import matchesRouter from './routes/matches';
import messagesRouter from './routes/messages';

const app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Static uploads
app.use('/uploads', express.static(path.resolve(process.env.UPLOAD_DIR || './uploads')));

// Routes
app.use('/api/auth', authRouter);
app.use('/api/users', usersRouter);
app.use('/api/items', itemsRouter);
app.use('/api/swipes', swipesRouter);
app.use('/api/matches', matchesRouter);
app.use('/api/matches/:matchId/messages', messagesRouter);

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Global error handler
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  if (err.name === 'MulterError') {
    res.status(400).json({ success: false, error: err.message });
    return;
  }
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, error: 'Internal server error' });
});

const server = http.createServer(app);
const io = initSocket(server);
app.set('io', io);

const PORT = parseInt(process.env.PORT || '3000', 10);

server.listen(PORT, () => {
  console.log(`FitFlip server running on http://localhost:${PORT}`);
});

export { app, server };
