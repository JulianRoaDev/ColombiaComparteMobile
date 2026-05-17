import mongoose, { Document, Schema, Types } from 'mongoose';

export interface IUsuario {
  nombre: string;
  correo: string;
  password_hash: string;
  rol: 'superadmin' | 'admin_pais' | 'editor';
  pais_asignado: Types.ObjectId | null;
}

export interface IUsuarioDocument extends IUsuario, Document {}

const usuarioSchema = new Schema<IUsuarioDocument>(
  {
    nombre:        { type: String, required: true },
    correo:        { type: String, required: true, unique: true },
    password_hash: { type: String, required: true },
    rol: {
      type: String,
      enum: ['superadmin', 'admin_pais', 'editor'],
      required: true
    },
    pais_asignado: {
      type: Schema.Types.ObjectId,
      ref: 'Pais',
      default: null
    }
  },
  { timestamps: true }
);

export default mongoose.model<IUsuarioDocument>('Usuario', usuarioSchema);