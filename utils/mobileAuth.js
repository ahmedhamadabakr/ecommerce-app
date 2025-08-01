import jwt from 'jsonwebtoken';
import { getDb } from './mongodb';

export async function verifyMobileToken(req) {
  try {
    const authHeader = req.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    
    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // البحث عن المستخدم في قاعدة البيانات
    const db = await getDb();
    const user = await db.collection('users').findOne({ 
      email: decoded.email 
    });
    
    if (!user) {
      return null;
    }
    
    return {
      user: {
        email: user.email,
        _id: user._id,
        name: user.name || user.fullName
      }
    };
  } catch (error) {
    console.error('Mobile token verification failed:', error);
    return null;
  }
}
