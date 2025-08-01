# حل مشكلة التوافق مع السيرفر

## المشكلة
السيرفر الحالي يستخدم NextAuth sessions للمصادقة، بينما التطبيق Flutter يستخدم Bearer tokens.

## الحل المقترح: إضافة API endpoints للموبايل

### 1. إضافة middleware للتحقق من Bearer tokens

```javascript
// utils/auth.js
import jwt from 'jsonwebtoken';
import { getDb } from './mongodb';

export async function verifyBearerToken(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  
  const token = authHeader.substring(7);
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const db = await getDb();
    const user = await db.collection('users').findOne({ email: decoded.email });
    return user;
  } catch (error) {
    return null;
  }
}
```

### 2. إضافة endpoint للموبايل: `/api/mobile/cart/add`

```javascript
// app/api/mobile/cart/add/route.js
import { verifyBearerToken } from "@/utils/auth";
import { getDb } from "@/utils/mongodb";
import { ObjectId } from "mongodb";

export async function POST(req) {
  try {
    // التحقق من Bearer token
    const authHeader = req.headers.get('authorization');
    const user = await verifyBearerToken(authHeader);
    
    if (!user) {
      return new Response("Unauthorized", { status: 401 });
    }
    
    const { productId, quantity = 1 } = await req.json();

    if (!productId) {
      return new Response(JSON.stringify({ error: "Product ID is required" }), {
        status: 400,
      });
    }
    
    const db = await getDb();
    
    // نفس منطق السيرفر الأصلي
    const currentCart = await db
      .collection("carts")
      .findOne({ userEmail: user.email });
      
    const currentItems = currentCart?.items || [];
    
    // باقي الكود نفسه...
    // ...
    
    return new Response(JSON.stringify({ items: currentItems }), {
      status: 200,
    });
    
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: "Failed to add to cart",
        details: error.message,
      }),
      { status: 500 }
    );
  }
}
```

### 3. تحديث Flutter API service

```dart
// تغيير endpoints للموبايل
Future<Response> addToCart(String productId, int quantity) async {
  return await _dio.post(
    '/api/mobile/cart/add',  // استخدام endpoint الموبايل
    data: {'productId': productId, 'quantity': quantity},
  );
}
```

## البديل البسيط: تحديث interceptor في Flutter

```dart
// في ApiService
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      // إضافة headers إضافية للموبايل
      options.headers['X-Mobile-App'] = 'true';
      options.headers['X-Platform'] = 'flutter';
      
      // باقي الكود...
      handler.next(options);
    },
  ),
);
```

## ملاحظات مهمة:
1. السيرفر الحالي غير متوافق مع Bearer tokens
2. نحتاج إما تعديل السيرفر أو إضافة endpoints جديدة
3. التطبيق Flutter محتاج تعديلات بسيطة فقط
