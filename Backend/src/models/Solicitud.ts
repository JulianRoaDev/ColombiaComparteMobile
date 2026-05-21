import mongoose, { Document, Schema, Types } from 'mongoose';

export interface ISolicitud {
  nombre: string;
  correo: string;
  telefono: string;
  finalidad: string;
  pais: Types.ObjectId;
  creador: Types.ObjectId | null;
  estado: 'pendiente' | 'gestionada' | 'respondida';
  fecha_creacion: Date;
}

export interface ISolicitudDocument extends ISolicitud, Document {}

const solicitudSchema = new Schema<ISolicitudDocument>({
  nombre:         { type: String, required: true },
  correo:         { type: String, required: true },
  telefono:       { type: String, required: true },
  finalidad:      { type: String, required: true },
  pais:           { type: Schema.Types.ObjectId, ref: 'Pais', required: true },
  creador:        { type: Schema.Types.ObjectId, ref: 'Usuario', default: null },
  estado: {
    type: String,
    enum: ['pendiente', 'gestionada', 'respondida'],
    default: 'pendiente'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

export default mongoose.model<ISolicitudDocument>('Solicitud', solicitudSchema);