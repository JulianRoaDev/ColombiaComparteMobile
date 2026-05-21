import mongoose, { Document, Schema, Types } from 'mongoose';

export interface INoticia {
  titulo: string;
  resumen: string;
  contenido: string;
  autor: string;
  imagen_url: string | null;
  pais: Types.ObjectId;
  creador: Types.ObjectId | null;
  estado: 'borrador' | 'publicado';
  fecha_creacion: Date;
}

export interface INoticiaDocument extends INoticia, Document {}

const noticiaSchema = new Schema<INoticiaDocument>({
  titulo:         { type: String, required: true },
  resumen:        { type: String, required: true },
  contenido:      { type: String, required: true },
  autor:          { type: String, required: true },
  imagen_url:     { type: String, default: null },
  creador:        { type: Schema.Types.ObjectId, ref: 'Usuario', default: null },
  pais:           { type: Schema.Types.ObjectId, ref: 'Pais', required: true },
  estado: {
    type: String,
    enum: ['borrador', 'publicado'],
    default: 'borrador'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

export default mongoose.model<INoticiaDocument>('Noticia', noticiaSchema);