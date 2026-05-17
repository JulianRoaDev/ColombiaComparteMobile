import mongoose from 'mongoose';

const connectDB = async (): Promise<void> => {
  try {
    const uri = process.env.MONGO_URI ?? '';
    await mongoose.connect(uri);
    console.log('✅ MongoDB conectado correctamente');
  } catch (error) {
    console.error('❌ Error conectando a MongoDB:', (error as Error).message);
    process.exit(1);
  }
};

export default connectDB;