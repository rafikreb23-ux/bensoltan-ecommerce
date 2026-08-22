# بنسولتان للتجارة الإلكترونية - موقع الشركة

موقع تعريفي احترافي لشركة **بنسولتان** مبني بـ HTML/CSS/JS نقي، جاهز للنشر على **Cloudflare Pages**.

## 🌐 النطاق
- **الرئيسي**: `bensoltandecommerce.tn`
- **البديل**: `www.bensoltandecommerce.tn`

## 📁 هيكل المشروع

```
bensoltan-ecommerce/
├── public/                 # مجلد النشر (Cloudflare Pages output)
│   ├── index.html          # الصفحة الرئيسية
│   ├── about.html          # من نحن
│   ├── services.html       # خدماتنا
│   ├── contact.html        # تواصل معنا
│   ├── styles.css          # جميع الأنماط
│   ├── app.js              # JavaScript التفاعلي
│   ├── _headers            # رؤوس الأمان والكاش
│   └── _redirects          # روابط نظيفة
├── wrangler.toml           # إعدادات Cloudflare
└── README.md               # هذا الملف
```

## ✨ المميزات

- **RTL كامل** - دعم ممتاز للغة العربية
- **متجاوب بالكامل** - يعمل على جميع أحجام الشاشات
- **أداء عالي** - لا مكتبات خارجية ثقيلة، كود نقي
- **إمكانية وصول (a11y)** - ARIA labels، semantic HTML، تباين ألوان
- **SEO محسّن** - Meta tags، Open Graph، هيكلية صحيحة
- **أمان** - Security headers عبر `_headers`
- **كاش ذكي** - Cache-Control محسّن للملفات الثابتة

## 🚀 النشر على Cloudflare Pages

### الطريقة الأولى: عبر GitHub (موصى بها)

1. **ارفع الكود لـ GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: bensoltan website"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/bensoltan-ecommerce.git
   git push -u origin main
   ```

2. **في Cloudflare Dashboard:**
   - اذهب إلى **Pages** → **Create a project**
   - اختر **Connect to Git** → اختر مستودعك
   - إعدادات البناء:
     - **Build command**: (اتركه فارغاً - لا يوجد build step)
     - **Build output directory**: `public`
     - **Root directory**: `/` (افتراضي)
   - اضغط **Save and Deploy**

3. **إعداد النطاق المخصص:**
   - في مشروع Pages → **Custom domains** → **Set up a custom domain**
   - أدخل: `bensoltandecommerce.tn`
   - اتبع تعليمات DNS (سيضيف Cloudflare السجلات تلقائياً إذا كان النطاق على Cloudflare)

### الطريقة الثانية: عبر Wrangler CLI

```bash
# تثبيت Wrangler
npm install -g wrangler

# تسجيل الدخول
wrangler login

# نشر للمعاينة
wrangler pages deploy public --project-name=bensoltan-ecommerce

# نشر للإنتاج
wrangler pages deploy public --project-name=bensoltan-ecommerce --branch=main
```

## 🔧 التخصيص

### تعديل معلومات الشركة
حرّر الملفات التالية:
- `public/index.html` - معلومات الهيرو، الإحصائيات
- `public/about.html` - قصة الشركة، الفريق، القيم
- `public/services.html` - تفاصيل الخدمات، المراحل
- `public/contact.html` - معلومات التواصل، النموذج
- `public/styles.css` - الألوان (متغيرات CSS في `:root`)

### تغيير الألوان
في `styles.css`، عدّل متغيرات `:root`:
```css
:root {
  --color-primary: #1e40af;      /* اللون الأساسي */
  --color-secondary: #059669;    /* اللون الثانوي */
  --color-accent: #f59e0b;       /* لون التمييز */
}
```

### إضافة صور
ضع الصور في `public/images/` وأشر إليها في HTML:
```html
<img src="images/team-photo.jpg" alt="فريق العمل" loading="lazy">
```

## 📋 قائمة التحقق قبل الإطلاق

- [ ] تحديث معلومات التواصل في جميع الصفحات
- [ ] إضافة الصور الحقيقية (الفريق، المكتب، المشاريع)
- [ ] مراجعة النصوص العربية وتصحيحها
- [ ] اختبار النموذج على صفحة التواصل
- [ ] التأكد من عمل الروابط الداخلية
- [ ] اختبار الموقع على الجوال والتابلت
- [ ] ربط Google Analytics / Matomo (اختياري)
- [ ] إضافة sitemap.xml و robots.txt

## 📊 الأداء

- **حجم الصفحة الرئيسية**: ~15 KB (HTML + CSS + JS مضغوط)
- **درجة Lighthouse المتوقعة**: 95+ في جميع المقاييس
- **First Contentful Paint**: < 1 ثانية على 3G
- **Time to Interactive**: < 2 ثانية

## 🛡️ الأمان

رؤوس HTTP المطبقة عبر `_headers`:
- `X-Frame-Options: DENY` - منع التضمين في iframe
- `X-Content-Type-Options: nosniff` - منع MIME sniffing
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` - تعطيل الكاميرا، الميكروفون، الموقع

## 📄 الترخيص

جميع الحقوق محفوظة © 2025 بنسولتان للتجارة الإلكترونية.

---

**هل تحتاج مساعدة؟** تواصل معنا على info@bensoltandecommerce.tn