# 🚀 دليل إعداد الـ Backend للتطبيق

## 📋 المشكلة الحالية
التطبيق يعمل بنجاح ولكن بعض endpoints مفقودة في السيرفر، مما يؤدي إلى أخطاء 401 و 405.

## 🔧 الحل: إنشاء الملفات المطلوبة

### 1️⃣ **إنشاء utils/mobileAuth.js**
```javascript
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
```

### 2️⃣ **إنشاء app/api/mobile/cart/route.js** (GET للحصول على السلة)
```javascript
import { verifyMobileToken } from "@/utils/mobileAuth";
import { getDb } from "@/utils/mongodb";

export async function GET(req) {
  try {
    const mobileAuth = await verifyMobileToken(req);
    
    if (!mobileAuth) {
      return new Response(JSON.stringify({ 
        error: "Mobile authentication required",
        code: "MOBILE_AUTH_REQUIRED" 
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const db = await getDb();
    const userEmail = mobileAuth.user.email;

    const cart = await db.collection("carts").findOne({ userEmail });
    
    const responseData = {
      success: true,
      items: cart?.items || [],
      cart: cart,
      platform: 'mobile'
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Mobile cart fetch error:', error);
    
    return new Response(JSON.stringify({
      error: "Failed to fetch cart",
      code: "INTERNAL_ERROR",
      details: error.message,
      platform: 'mobile'
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### 3️⃣ **إنشاء app/api/mobile/cart/remove/[productId]/route.js**
```javascript
import { verifyMobileToken } from "@/utils/mobileAuth";
import { getDb } from "@/utils/mongodb";
import { ObjectId } from "mongodb";

export async function DELETE(req, { params }) {
  try {
    const mobileAuth = await verifyMobileToken(req);
    
    if (!mobileAuth) {
      return new Response(JSON.stringify({ 
        error: "Mobile authentication required",
        code: "MOBILE_AUTH_REQUIRED" 
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    const { productId } = params;
    
    if (!productId) {
      return new Response(JSON.stringify({ 
        error: "Product ID is required",
        code: "MISSING_PRODUCT_ID"
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const db = await getDb();
    const userEmail = mobileAuth.user.email;

    // الحصول على السلة الحالية
    const currentCart = await db.collection("carts").findOne({ userEmail });
    
    if (!currentCart || !currentCart.items) {
      return new Response(JSON.stringify({
        error: "Cart not found or empty",
        code: "CART_NOT_FOUND"
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const currentItems = currentCart.items || [];
    
    // البحث عن المنتج في السلة
    const itemIndex = currentItems.findIndex(
      (item) => String(item.id) === String(productId)
    );

    if (itemIndex === -1) {
      return new Response(JSON.stringify({
        error: "Product not found in cart",
        code: "PRODUCT_NOT_IN_CART"
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // إرجاع الكمية إلى المخزون
    const removedItem = currentItems[itemIndex];
    try {
      await db.collection("products").updateOne(
        { _id: new ObjectId(productId) },
        { $inc: { quantity: removedItem.quantity } }
      );
    } catch (err) {
      console.warn('Could not restore product quantity:', err);
    }

    // حذف المنتج من السلة
    currentItems.splice(itemIndex, 1);

    // تحديث السلة في قاعدة البيانات
    const updatedCart = await db.collection("carts").findOneAndUpdate(
      { userEmail },
      {
        $set: {
          items: currentItems,
          updatedAt: new Date(),
          platform: 'mobile',
          lastAction: 'remove_from_cart'
        }
      },
      { returnDocument: "after" }
    );

    const responseData = {
      success: true,
      message: "Product removed from cart successfully",
      items: currentItems,
      cart: updatedCart.value,
      platform: 'mobile'
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Mobile cart remove error:', error);
    
    return new Response(JSON.stringify({
      error: "Failed to remove product from cart",
      code: "INTERNAL_ERROR",
      details: error.message,
      platform: 'mobile'
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### 4️⃣ **إنشاء app/api/mobile/cart/update/[productId]/route.js**
```javascript
import { verifyMobileToken } from "@/utils/mobileAuth";
import { getDb } from "@/utils/mongodb";
import { ObjectId } from "mongodb";

export async function PUT(req, { params }) {
  try {
    const mobileAuth = await verifyMobileToken(req);
    
    if (!mobileAuth) {
      return new Response(JSON.stringify({ 
        error: "Mobile authentication required",
        code: "MOBILE_AUTH_REQUIRED" 
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    const { productId } = params;
    const { quantity } = await req.json();
    
    if (!productId) {
      return new Response(JSON.stringify({ 
        error: "Product ID is required",
        code: "MISSING_PRODUCT_ID"
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    if (typeof quantity !== "number" || quantity < 0) {
      return new Response(JSON.stringify({ 
        error: "Valid quantity is required",
        code: "INVALID_QUANTITY"
      }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const db = await getDb();
    const userEmail = mobileAuth.user.email;

    // الحصول على السلة الحالية
    const currentCart = await db.collection("carts").findOne({ userEmail });
    
    if (!currentCart || !currentCart.items) {
      return new Response(JSON.stringify({
        error: "Cart not found or empty",
        code: "CART_NOT_FOUND"
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const currentItems = currentCart.items || [];
    
    // البحث عن المنتج في السلة
    const itemIndex = currentItems.findIndex(
      (item) => String(item.id) === String(productId)
    );

    if (itemIndex === -1) {
      return new Response(JSON.stringify({
        error: "Product not found in cart",
        code: "PRODUCT_NOT_IN_CART"
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // إذا كانت الكمية صفر، حذف المنتج
    if (quantity === 0) {
      const removedItem = currentItems[itemIndex];
      // إرجاع الكمية للمخزون
      try {
        await db.collection("products").updateOne(
          { _id: new ObjectId(productId) },
          { $inc: { quantity: removedItem.quantity } }
        );
      } catch (err) {
        console.warn('Could not restore product quantity:', err);
      }
      
      currentItems.splice(itemIndex, 1);
    } else {
      // تحديث الكمية
      const oldQuantity = currentItems[itemIndex].quantity;
      const quantityDiff = quantity - oldQuantity;
      
      // التحقق من المخزون إذا كانت الكمية تزيد
      if (quantityDiff > 0) {
        const product = await db.collection("products").findOne({ 
          _id: new ObjectId(productId) 
        });
        
        if (product && quantityDiff > Number(product.quantity)) {
          return new Response(JSON.stringify({
            error: "Not enough stock available",
            code: "INSUFFICIENT_STOCK",
            available: Number(product.quantity),
            requested: quantityDiff
          }), { 
            status: 400,
            headers: { 'Content-Type': 'application/json' }
          });
        }
        
        // خصم من المخزون
        await db.collection("products").updateOne(
          { _id: new ObjectId(productId) },
          { $inc: { quantity: -quantityDiff } }
        );
      } else if (quantityDiff < 0) {
        // إرجاع للمخزون
        await db.collection("products").updateOne(
          { _id: new ObjectId(productId) },
          { $inc: { quantity: Math.abs(quantityDiff) } }
        );
      }
      
      currentItems[itemIndex].quantity = quantity;
    }

    // تحديث السلة في قاعدة البيانات
    const updatedCart = await db.collection("carts").findOneAndUpdate(
      { userEmail },
      {
        $set: {
          items: currentItems,
          updatedAt: new Date(),
          platform: 'mobile',
          lastAction: 'update_cart'
        }
      },
      { returnDocument: "after" }
    );

    const responseData = {
      success: true,
      message: "Cart updated successfully",
      items: currentItems,
      cart: updatedCart.value,
      platform: 'mobile'
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Mobile cart update error:', error);
    
    return new Response(JSON.stringify({
      error: "Failed to update cart",
      code: "INTERNAL_ERROR",
      details: error.message,
      platform: 'mobile'
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### 5️⃣ **إنشاء app/api/mobile/cart/clear/route.js**
```javascript
import { verifyMobileToken } from "@/utils/mobileAuth";
import { getDb } from "@/utils/mongodb";
import { ObjectId } from "mongodb";

export async function DELETE(req) {
  try {
    const mobileAuth = await verifyMobileToken(req);
    
    if (!mobileAuth) {
      return new Response(JSON.stringify({ 
        error: "Mobile authentication required",
        code: "MOBILE_AUTH_REQUIRED" 
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const db = await getDb();
    const userEmail = mobileAuth.user.email;

    // الحصول على السلة الحالية لإرجاع المنتجات للمخزون
    const currentCart = await db.collection("carts").findOne({ userEmail });
    
    if (currentCart && currentCart.items && currentCart.items.length > 0) {
      // إرجاع جميع المنتجات للمخزون
      for (const item of currentCart.items) {
        try {
          await db.collection("products").updateOne(
            { _id: new ObjectId(item.id) },
            { $inc: { quantity: item.quantity } }
          );
        } catch (err) {
          console.warn(`Could not restore quantity for product ${item.id}:`, err);
        }
      }
    }

    // مسح السلة
    await db.collection("carts").updateOne(
      { userEmail },
      {
        $set: {
          items: [],
          updatedAt: new Date(),
          platform: 'mobile',
          lastAction: 'clear_cart'
        }
      },
      { upsert: true }
    );

    const responseData = {
      success: true,
      message: "Cart cleared successfully",
      items: [],
      platform: 'mobile'
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Mobile cart clear error:', error);
    
    return new Response(JSON.stringify({
      error: "Failed to clear cart",
      code: "INTERNAL_ERROR",
      details: error.message,
      platform: 'mobile'
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

## 🎯 **تسلسل الإنشاء**
1. إنشاء `utils/mobileAuth.js` أولاً
2. إنشاء `app/api/mobile/cart/route.js` 
3. إنشاء `app/api/mobile/cart/remove/[productId]/route.js`
4. إنشاء `app/api/mobile/cart/update/[productId]/route.js`
5. إنشاء `app/api/mobile/cart/clear/route.js`

## ✅ **بعد إنشاء هذه الملفات:**
- ستختفي أخطاء 401 و 405
- ستعمل جميع عمليات السلة بشكل صحيح
- ستُحفظ البيانات في جدول `carts` في قاعدة البيانات
- ستُدار المخزون تلقائياً

## 🚀 **النتيجة النهائية:**
تطبيق متكامل يدعم:
- ✅ تسجيل الدخول والمصادقة
- ✅ إدارة السلة بالكامل (إضافة، حذف، تحديث، مسح)
- ✅ الوضع الليلي والنهاري
- ✅ تغيير اللغة (عربي/إنجليزي)
- ✅ حفظ البيانات في قاعدة البيانات
- ✅ إدارة المخزون تلقائياً

## 📱 **الاستخدام:**
بعد إضافة هذه الملفات للسيرفر، التطبيق سيعمل بدون مشاكل ويمكن:
- إضافة منتجات للسلة
- عرض السلة
- تحديث الكميات
- حذف المنتجات
- مسح السلة
- تغيير الثيم واللغة

🎉 **جاهز للاستخدام!**
