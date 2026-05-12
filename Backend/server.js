require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./src/config/db');

// Import Routes
const authRoutes = require('./src/routes/auth.routes');
const dashboardRoutes = require('./src/routes/dashboard.routes');
const paisesRoutes = require('./src/routes/paises.routes');
const solicitudesRoutes  = require('./src/routes/solicitudes.routes');
const testimoniosRoutes  = require('./src/routes/testimonios.routes');
const noticiasRoutes     = require('./src/routes/noticias.routes');

const app = express();

// Conect to the database (MongoDB)
connectDB();

// Global middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/auth', authRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/paises', paisesRoutes);
app.use('/solicitudes',  solicitudesRoutes);
app.use('/testimonios',  testimoniosRoutes);
app.use('/noticias',     noticiasRoutes);

// Checking if the server is running
app.get('/', (req, res) => {
  res.json({ message: 'CMS Latinoamérica Comparte API corriendo' });
});

// Init server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://192.168.20.25:${PORT}`);
});