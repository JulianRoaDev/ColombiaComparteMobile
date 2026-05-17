import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import connectDB from './config/db';

import authRoutes        from './routes/auth.routes';
import dashboardRoutes   from './routes/dashboard.routes';
import paisesRoutes      from './routes/paises.routes';
import solicitudesRoutes from './routes/solicitudes.routes';
import testimoniosRoutes from './routes/testimonios.routes';
import noticiasRoutes    from './routes/noticias.routes';

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use('/auth',        authRoutes);
app.use('/dashboard',   dashboardRoutes);
app.use('/paises',      paisesRoutes);
app.use('/solicitudes', solicitudesRoutes);
app.use('/testimonios', testimoniosRoutes);
app.use('/noticias',    noticiasRoutes);

app.get('/', (_req, res) => {
  res.json({ message: '✅ CMS Latinoamérica Comparte API corriendo' });
});

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://192.168.20.25:${PORT}`);
});