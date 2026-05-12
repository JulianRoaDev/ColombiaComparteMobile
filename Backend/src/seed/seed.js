require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const mongoose  = require('mongoose');
const bcrypt    = require('bcryptjs');
const Pais       = require('../models/Pais');
const Usuario    = require('../models/Usuario');
const Solicitud  = require('../models/Solicitud');
const Testimonio = require('../models/Testimonio');
const Noticia    = require('../models/Noticia');

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('🌱 Conectado a MongoDB para seed...');

    // Clean everything before seeding
    await Promise.all([
      Pais.deleteMany({}),
      Usuario.deleteMany({}),
      Solicitud.deleteMany({}),
      Testimonio.deleteMany({}),
      Noticia.deleteMany({})
    ]);
    console.log('🗑️  Colecciones limpiadas');

    // ── 1. Create countries ──────────────────────────────────────────────────────
    const [colombia, chile, ecuador] = await Pais.insertMany([
      { nombre: 'Colombia', codigo: 'CO', activo: true },
      { nombre: 'Chile',    codigo: 'CL', activo: true },
      { nombre: 'Ecuador',  codigo: 'EC', activo: true }
    ]);
    console.log('🌎 Países creados');

    // ── 2. Create Users ────────────────────────────────────────────────────
    const salt = await bcrypt.genSalt(10);
    const hash = (pwd) => bcrypt.hash(pwd, salt);

    await Usuario.insertMany([
      {
        nombre: 'Super Admin',
        correo: 'superadmin@comparte.org',
        password_hash: await hash('admin123'),
        rol: 'superadmin',
        pais_asignado: null
      },
      {
        nombre: 'Admin Colombia',
        correo: 'admin.co@comparte.org',
        password_hash: await hash('colombia123'),
        rol: 'admin_pais',
        pais_asignado: colombia._id
      },
      {
        nombre: 'Admin Chile',
        correo: 'admin.cl@comparte.org',
        password_hash: await hash('chile123'),
        rol: 'admin_pais',
        pais_asignado: chile._id
      },
      {
        nombre: 'Admin Ecuador',
        correo: 'admin.ec@comparte.org',
        password_hash: await hash('ecuador123'),
        rol: 'admin_pais',
        pais_asignado: ecuador._id
      },
      {
        nombre: 'Editor Colombia',
        correo: 'editor.co@comparte.org',
        password_hash: await hash('editor123'),
        rol: 'editor',
        pais_asignado: colombia._id
      }
    ]);
    console.log('👥 Usuarios creados');

    // ── 3. Create test requests ───────────────────────────────────────
    await Solicitud.insertMany([
      { nombre: 'Juan Pérez',    correo: 'juan@mail.com',   telefono: '3001234567', finalidad: 'Programa Edifica',  pais: colombia._id, estado: 'pendiente'  },
      { nombre: 'María García',  correo: 'maria@mail.com',  telefono: '3009876543', finalidad: 'Conferencista',     pais: colombia._id, estado: 'gestionada' },
      { nombre: 'Carlos Ruiz',   correo: 'carlos@mail.com', telefono: '3111234567', finalidad: 'Programa Nodus',    pais: colombia._id, estado: 'pendiente'  },
      { nombre: 'Laura Gómez',   correo: 'laura@mail.com',  telefono: '3201234567', finalidad: 'Programa Edifica',  pais: colombia._id, estado: 'respondida' },
      { nombre: 'Ana Morales',   correo: 'ana@mail.cl',     telefono: '987654321',  finalidad: 'Programa Edifica',  pais: chile._id,    estado: 'pendiente'  },
      { nombre: 'Luis Torres',   correo: 'luis@mail.cl',    telefono: '912345678',  finalidad: 'Programa Nodus',    pais: chile._id,    estado: 'respondida' },
      { nombre: 'Sofía Vega',    correo: 'sofia@mail.ec',   telefono: '0991234567', finalidad: 'Conferencista',     pais: ecuador._id,  estado: 'pendiente'  },
      { nombre: 'Diego Salinas', correo: 'diego@mail.ec',   telefono: '0987654321', finalidad: 'Programa Edifica',  pais: ecuador._id,  estado: 'gestionada' }
    ]);
    console.log('📬 Solicitudes creadas');

    // ── 4. Create test testimonies ───────────────────────────────────────
    await Testimonio.insertMany([
      { nombre: 'Pedro Vargas',  foto_url: 'https://i.pravatar.cc/150?img=1', testimonio: 'El programa Edifica cambió mi vida.', pais: colombia._id, estado: 'publicado'    },
      { nombre: 'Lucía Ramírez', foto_url: 'https://i.pravatar.cc/150?img=2', testimonio: 'Gracias a Nodus escalé mi empresa.',  pais: colombia._id, estado: 'borrador'     },
      { nombre: 'Diego Salas',   foto_url: 'https://i.pravatar.cc/150?img=3', testimonio: 'Increíble experiencia en Santiago.',  pais: chile._id,    estado: 'publicado'    },
      { nombre: 'Valeria Rojas', foto_url: 'https://i.pravatar.cc/150?img=4', testimonio: 'Transformé mi negocio en 3 meses.',   pais: ecuador._id,  estado: 'publicado'    },
      { nombre: 'Marco Peña',    foto_url: 'https://i.pravatar.cc/150?img=5', testimonio: 'El apoyo fue increíble.',             pais: chile._id,    estado: 'despublicado' }
    ]);
    console.log('🌟 Testimonios creados');

    // ── 5. Create test news ──────────────────────────────────────────
    await Noticia.insertMany([
      { titulo: 'Nueva convocatoria Edifica 2026',  resumen: 'Abre inscripciones el programa.', contenido: 'Contenido detallado aquí...', autor: 'Admin Colombia', pais: colombia._id, estado: 'publicado' },
      { titulo: 'Nodus cierra trimestre histórico', resumen: 'El programa superó sus metas.',   contenido: 'Contenido detallado aquí...', autor: 'Admin Colombia', pais: colombia._id, estado: 'borrador'  },
      { titulo: 'Conferencista estrella en Santiago', resumen: 'Gran evento en Chile.',         contenido: 'Contenido detallado aquí...', autor: 'Admin Chile',    pais: chile._id,    estado: 'publicado' },
      { titulo: 'Lanzamiento nuevo ciclo Ecuador',  resumen: 'Nuevo ciclo en Ecuador.',         contenido: 'Contenido detallado aquí...', autor: 'Admin Ecuador',  pais: ecuador._id,  estado: 'publicado' },
      { titulo: 'Edifica en Bogotá 2026',           resumen: 'Evento especial Bogotá.',         contenido: 'Contenido detallado aquí...', autor: 'Admin Colombia', pais: colombia._id, estado: 'publicado' },
      { titulo: 'Expansión Nodus Chile',            resumen: 'Nodus llega a nuevas regiones.',  contenido: 'Contenido detallado aquí...', autor: 'Admin Chile',    pais: chile._id,    estado: 'borrador'  }
    ]);
    console.log('📰 Noticias creadas');

    console.log('\n✅ Seed completado exitosamente');
    console.log('─────────────────────────────────────────');
    console.log('USUARIOS DE PRUEBA:');
    console.log('superadmin@comparte.org  / admin123    (superadmin)');
    console.log('admin.co@comparte.org    / colombia123 (admin_pais — Colombia)');
    console.log('admin.cl@comparte.org    / chile123    (admin_pais — Chile)');
    console.log('admin.ec@comparte.org    / ecuador123  (admin_pais — Ecuador)');
    console.log('editor.co@comparte.org   / editor123   (editor — Colombia)');
    console.log('─────────────────────────────────────────');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error en seed:', error);
    process.exit(1);
  }
};

seed();