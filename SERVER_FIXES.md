# 🔧 إصلاحات مطلوبة للسيرفر

## ❌ **المشكلة الرئيسية:**
جميع الكود موضوع داخل تعليقات - لن يُنفذ!

## 🚨 **الأخطاء المكتشفة:**

### 1. **خطأ في منطق المخزون (في cart/add)**
```javascript
// ❌ خطأ في السطر 136
if (!isNaN(productQuantity) && newQuantity > productQuantity + currentCartQuantity) {
  // المنطق خاطئ - يجمع كمية المنتج مع كمية السلة!
}

// ✅ الصحيح:
if (!isNaN(productQuantity) && newQuantity > productQuantity) {
  return new Response(JSON.stringify({
    error: "Not enough stock available",
    code: "INSUFFICIENT_STOCK",
    available: productQuantity,
    requested: newQuantity
  }), { status: 400, headers: { 'Content-Type': 'application/json' } });
}
```

### 2. **عدم توافق نوع البيانات للمخزون**
```javascript
// ❌ مشكلة: يحفظ المخزون كـ string ثم يتعامل معه كـ number

// في الإضافة (صحيح):
{ $set: { quantity: newStockQuantity.toString() } }

// في الحذف (خطأ):
{ $inc: { quantity: removedItem.quantity } } // يتوقع number لكن الحقل string!

// ✅ الحل الموحد - استخدم numbers في كل مكان:
{ $inc: { quantity: Number(removedItem.quantity) } }
```

### 3. **منطق خاطئ في التحقق من المخزون**
```javascript
// ❌ في السطر 136 - منطق معقد وخاطئ
if (!isNaN(productQuantity) && newQuantity > productQuantity + currentCartQuantity) {
  
// ✅ يجب أن يكون:
const availableStock = productQuantity; // المخزون المتاح
const totalRequested = currentCartQuantity + quantity; // المطلوب إجمالي
if (totalRequested > availableStock) {
  // خطأ في المخزون
}
```

## 🔧 **الحلول:**

### الحل 1: إزالة التعليقات وإنشاء الملفات
انسخ كل كود من التعليقات وأنشئ الملفات الفعلية.

### الحل 2: إصلاح ملف cart/add/route.js
```javascript
import { verifyMobileToken } from "@/utils/mobileAuth";
import { getDb } from "@/utils/mongodb";
import { ObjectId } from "mongodb";

export async function POST(req) {
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
    
    const { productId, quantity = 1 } = await req.json();
    
    if (!productId) {
      return new Response(JSON.stringify({ 
        error: "Product ID is required",
        code: "MISSING_PRODUCT_ID"
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    if (typeof quantity !== "number" || quantity < 1) {
      return new Response(JSON.stringify({ 
        error: "Quantity must be at least 1",
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
    const currentItems = currentCart?.items || [];

    // التحقق من وجود المنتج في المتجر
    let product;
    try {
      product = await db.collection("products").findOne({ _id: new ObjectId(productId) });
    } catch (err) {
      return new Response(JSON.stringify({ 
        error: "Invalid product ID format",
        code: "INVALID_PRODUCT_ID"
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    if (!product) {
      return new Response(JSON.stringify({ 
        error: "Product not found",
        code: "PRODUCT_NOT_FOUND"
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // ✅ إصلاح: التحقق من المخزون بشكل صحيح
    const productQuantity = Number(product.quantity) || 0;
    const existingItemIndex = currentItems.findIndex(
      (item) => String(item.id) === String(productId)
    );

    let newQuantity;
    if (existingItemIndex !== -1) {
      // المنتج موجود بالفعل
      const currentCartQuantity = Number(currentItems[existingItemIndex].quantity) || 0;
      newQuantity = currentCartQuantity + Number(quantity);
      
      // ✅ إصلاح المنطق: التحقق من المخزون المتاح
      if (newQuantity > productQuantity) {
        return new Response(JSON.stringify({
          error: "Not enough stock available",
          code: "INSUFFICIENT_STOCK",
          available: Math.max(0, productQuantity - currentCartQuantity),
          requested: quantity,
          currentInCart: currentCartQuantity
        }), { 
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        });
      }

      // تحديث الكمية في السلة
      currentItems[existingItemIndex].quantity = newQuantity;
      
    } else {
      // منتج جديد
      newQuantity = Number(quantity);
      
      if (newQuantity > productQuantity) {
        return new Response(JSON.stringify({
          error: "Not enough stock available",
          code: "INSUFFICIENT_STOCK",
          available: productQuantity,
          requested: newQuantity
        }), { 
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        });
      }

      // إضافة منتج جديد للسلة
      currentItems.push({
        id: product._id.toString(),
        title: product.title,
        price: Number(product.price),
        quantity: newQuantity,
        image: product.photos && product.photos.length > 0 ? product.photos[0] : null,
        addedAt: new Date()
      });
    }

    // ✅ إصلاح: تحديث المخزون بشكل متسق (استخدام numbers)
    const newStockQuantity = productQuantity - Number(quantity);
    await db.collection("products").updateOne(
      { _id: new ObjectId(productId) },
      { $set: { quantity: newStockQuantity } } // حفظ كـ number بدلاً من string
    );

    // حفظ السلة في قاعدة البيانات
    const updatedCart = await db.collection("carts").findOneAndUpdate(
      { userEmail },
      {
        $set: {
          items: currentItems,
          updatedAt: new Date(),
          platform: 'mobile',
          lastAction: 'add_to_cart'
        }
      },
      { upsert: true, returnDocument: "after" }
    );

    const responseData = {
      success: true,
      message: "Product added to cart successfully",
      items: currentItems,
      cart: updatedCart.value,
      platform: 'mobile'
    };

    return new Response(JSON.stringify(responseData), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('Mobile cart add error:', error);
    
    return new Response(JSON.stringify({
      error: "Failed to add product to cart",
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

### الحل 3: إصلاح ملف cart/remove/[productId]/route.js
```javascript
// ✅ إصلاح إرجاع المخزون
const removedItem = currentItems[itemIndex];
try {
  await db.collection("products").updateOne(
    { _id: new ObjectId(productId) },
    { $inc: { quantity: Number(removedItem.quantity) } } // تأكد من النوع
  );
} catch (err) {
  console.warn('Could not restore product quantity:', err);
}
```

## 📋 **قائمة المهام:**

1. ✅ **إنشاء الملفات الفعلية** (إزالة التعليقات)
2. ✅ **إصلاح منطق المخزون في cart/add**
3. ✅ **توحيد نوع بيانات المخزون (numbers)**
4. ✅ **إصلاح منطق التحقق من المخزون**
5. ✅ **اختبار جميع العمليات**

## 🎯 **بعد التطبيق:**
- ستختفي أخطاء 401 و 405
- ستعمل جميع عمليات السلة
- سيُدار المخزون بشكل صحيح
- ستُحفظ البيانات في قاعدة البيانات

## ⚠️ **تحذير مهم:**
**لا تنس إزالة التعليقات `/* */` من حول جميع الكود!**
