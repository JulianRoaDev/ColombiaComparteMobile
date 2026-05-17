import mongoose, { Document, Schema } from 'mongoose';

export interface IPais {
  nombre: string;
  codigo: string;
  activo: boolean;
}

export interface IPaisDocument extends IPais, Document {}

const paisSchema = new Schema<IPaisDocument>({
  nombre: { type: String, required: true },
  codigo: { type: String, required: true },
  activo: { type: Boolean, default: true }
});

export default mongoose.model<IPaisDocument>('Pais', paisSchema);