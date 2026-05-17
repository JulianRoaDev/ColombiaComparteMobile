import mongoose, { Document, Schema, Types } from 'mongoose';

export interface ITestimonio {
  nombre: string;
  foto_url: string;
  testimonio: string;
  pais: Types.ObjectId;
  instagram_url: string | null;
  facebook_url: string | null;
  estado: 'borrador' | 'publicado' | 'despublicado';
  fecha_creacion: Date;
}

export interface ITestimonioDocument extends ITestimonio, Document {}

const testimonioSchema = new Schema<ITestimonioDocument>({
  nombre:        { type: String, required: true },
  foto_url:      { type: String, required: true },
  testimonio:    { type: String, required: true },
  pais:          { type: Schema.Types.ObjectId, ref: 'Pais', required: true },
  instagram_url: { type: String, default: null },
  facebook_url:  { type: String, default: null },
  estado: {
    type: String,
    enum: ['borrador', 'publicado', 'despublicado'],
    default: 'borrador'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

export default mongoose.model<ITestimonioDocument>('Testimonio', testimonioSchema);