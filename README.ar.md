# cursor-rp

[简体中文](README.md) | [English](README.en.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Español](README.es.md)

## مقدمة
أداة وكيل عكسي محلية. المقدمة موجزة، عن قصد.

## التثبيت
1. قم بزيارة https://github.com/wisdgod/cursor-rp/releases لتنزيل dbwriter و modifier و ccursor
2. أعد تسميتهما بالأسماء القياسية وضعهما في نفس الدليل

## الإعداد والاستخدام

### 1. إدارة الحسابات (dbwriter)

dbwriter هي أداة إدارة حسابات لتبديل معلومات حساب Cursor بسرعة. تدعم التطبيق المباشر، وإدارة مجموعة الحسابات، واستيراد الحساب الحالي، وأوضاع أخرى متعددة.

#### الاستخدام الأساسي

```bash
# التطبيق المباشر (بدون حفظ)
dbwriter apply -a <TOKEN> -m pro -s google
dbwriter apply -a <ACCESS_TOKEN> -r <REFRESH_TOKEN> -e user@example.com -m pro_plus -s auth0

# حفظ الحساب في المجموعة
dbwriter save -a <TOKEN> -e user@example.com -m pro -s google
dbwriter save -a <TOKEN> -e user@example.com -m free_trial -s github --apply

# تبديل الحساب من المجموعة
dbwriter use -e user@example.com
dbwriter use -m pro
dbwriter use -m pro --interactive
dbwriter use --interactive

# عرض حساب Cursor الحالي
dbwriter cursor show
dbwriter cursor import

# عرض مجموعة الحسابات
dbwriter list
dbwriter list -m pro
dbwriter list --verbose

# إدارة مجموعة الحسابات
dbwriter manage remove user@example.com
dbwriter manage disable user@example.com
dbwriter manage stats

# الوضع الصامت العام
dbwriter -q list
dbwriter --quiet cursor import
```

#### وصف معلمات الأمر

**المعلمات العامة**

| المعلمة | الاختصار | الوصف | القيمة الافتراضية |
|---------|----------|-------|-------------------|
| `--pool-db` | | مسار قاعدة بيانات مجموعة الحسابات | `./accounts.db` |
| `--quiet` | `-q` | الوضع الصامت (تقليل الإخراج) | - |

**الأمر الفرعي: apply** (التطبيق المباشر بدون حفظ)

| المعلمة | الاختصار | الوصف | مطلوب |
|---------|----------|-------|-------|
| `--access-token` | `-a` | رمز الوصول | ✅ |
| `--refresh-token` | `-r` | رمز التحديث | ❌ |
| `--email` | `-e` | البريد الإلكتروني للحساب | ❌ |
| `--membership` | `-m` | نوع العضوية | ✅ |
| `--signup-type` | `-s` | طريقة التسجيل | ✅ |

**الأمر الفرعي: save** (حفظ في مجموعة الحسابات)

| المعلمة | الاختصار | الوصف | مطلوب |
|---------|----------|-------|-------|
| `--access-token` | `-a` | رمز الوصول | ✅ |
| `--refresh-token` | `-r` | رمز التحديث | ❌ |
| `--email` | `-e` | البريد الإلكتروني للحساب | ❌ |
| `--membership` | `-m` | نوع العضوية | ✅ |
| `--signup-type` | `-s` | طريقة التسجيل | ✅ |
| `--apply` | | تطبيق فوراً بعد الحفظ | ❌ |

**الأمر الفرعي: use** (اختيار وتطبيق من مجموعة الحسابات)

| المعلمة | الاختصار | الوصف | ملاحظات |
|---------|----------|-------|---------|
| `--email` | `-e` | اختيار عن طريق البريد الإلكتروني | حصري متبادل مع `-m` |
| `--membership` | `-m` | اختيار عن طريق نوع العضوية | حصري متبادل مع `-e` |
| `--interactive` | `-i` | اختيار تفاعلي | - |

**الأمر الفرعي: cursor** (عمليات الحساب الحالي)

| الأمر الفرعي | الوصف |
|--------------|-------|
| `show` | عرض معلومات حساب Cursor الحالي |
| `import` | استيراد الحساب الحالي إلى مجموعة الحسابات |

**الأمر الفرعي: list** (عرض مجموعة الحسابات)

| المعلمة | الاختصار | الوصف |
|---------|----------|-------|
| `--membership` | `-m` | تصفية حسب نوع العضوية |
| `--verbose` | `-v` | عرض معلومات مفصلة |

**الأمر الفرعي: manage** (إدارة مجموعة الحسابات)

| الأمر الفرعي | الوصف |
|--------------|-------|
| `remove <EMAIL>` | إزالة حساب |
| `disable <EMAIL>` | تعطيل حساب |
| `stats` | عرض الإحصائيات |

**أنواع القيم المدعومة**

- **أنواع العضوية**: `free`, `pro`, `pro_plus`, `enterprise`, `free_trial`, `ultra`
- **طرق التسجيل**: `unknown`, `auth0`, `google`, `github`

#### سيناريوهات الاستخدام

**السيناريو 1: الاستخدام الأول - استيراد حساب موجود**

```bash
# 1. قم بتسجيل الدخول بشكل طبيعي في Cursor
# 2. استورد الحساب الحالي إلى مجموعة الحسابات
dbwriter cursor import

# 3. اعرض مجموعة الحسابات
dbwriter list
```

**السيناريو 2: إضافة حسابات متعددة**

```bash
# الطريقة 1: الإضافة اليدوية
dbwriter save -a <TOKEN1> -e work@company.com -m enterprise -s auth0
dbwriter save -a <TOKEN2> -e personal@gmail.com -m pro -s google

# الطريقة 2: تبديل تسجيل الدخول في Cursor، ثم الاستيراد
dbwriter cursor import  # تنفيذ بعد تسجيل الدخول للحساب 1
# التبديل إلى الحساب 2 في Cursor
dbwriter cursor import  # تنفيذ بعد تسجيل الدخول للحساب 2
```

**السيناريو 3: التبديل السريع بين الحسابات**

```bash
# التبديل عن طريق البريد الإلكتروني
dbwriter use -e work@company.com

# التبديل عن طريق نوع العضوية
dbwriter use -m pro

# الاختيار التفاعلي
dbwriter use --interactive
```

**السيناريو 4: عرض الحساب الحالي**

```bash
dbwriter cursor show
```

**السيناريو 5: استخدام حساب مؤقت (بدون حفظ)**

```bash
dbwriter apply -a <TOKEN> -m pro -s google
```

**السيناريو 6: الاستخدام في النصوص البرمجية**

```bash
# الوضع الصامت، تقليل الإخراج
dbwriter -q use -e user@example.com
```

#### ملاحظات

- **أغلق Cursor** قبل تعديل الحسابات
- يُوصى بتعيين بريد إلكتروني لكل حساب لتسهيل الإدارة
- يمكن أن تكون الرموز متطابقة (توفير `-a` فقط) أو مختلفة (توفير كل من `-a` و `-r`)
- الحسابات بدون بريد إلكتروني تُعرض كـ `<بدون بريد إلكتروني>` في القائمة
- لا يمكن استخدام `--quiet` مع `--interactive`
- الحسابات بنفس البريد الإلكتروني يتم تحديثها تلقائياً (بدون تكرار)

#### مرجع سريع

```bash
# مرجع سريع للأوامر الشائعة
dbwriter cursor import             # استيراد الحساب الحالي
dbwriter use -e <EMAIL>            # تبديل الحساب
dbwriter list                      # عرض جميع الحسابات
dbwriter cursor show               # عرض الحساب الحالي

# إدارة مجموعة الحسابات
dbwriter manage stats              # عرض الإحصائيات
dbwriter manage remove <EMAIL>     # إزالة حساب
```

### 2. تصحيح Cursor (modifier)
أغلق Cursor، طبق التصحيح (يجب إعادة التنفيذ بعد كل تحديث):
```bash
# الاستخدام الأساسي (الكشف التلقائي عن مسار Cursor)
/path/to/modifier --port 3000 --suffix .local

# تحديد مسار Cursor
/path/to/modifier --cursor-path /path/to/cursor --port 3000 --suffix .local

# إعدادات HTTPS
/path/to/modifier --scheme https --port 443 --suffix .example.com

# تخطي اكتشاف ملف hosts (إدارة hosts يدويًا)
/path/to/modifier --port 3000 --suffix .local --skip-hosts

# حفظ الأمر لإعادة الاستخدام
/path/to/modifier --port 3000 --suffix .local --save-command modifier.cmd

# مثال كامل
/path/to/modifier -C /path/to/cursor --scheme https -p 3000 --suffix .local --skip-hosts -s modifier.cmd --confirm --pass-token
```

### معلمات الأمر
| المعلمة | الاختصار | الوصف | مثال |
|---------|----------|-------|------|
| `--cursor-path` | `-C` | مسار تثبيت Cursor (اختياري، كشف تلقائي) | `/Applications/Cursor.app` |
| `--scheme` | | نوع البروتوكول (http/https) | `https` |
| `--port` | `-p` | منفذ الخدمة | `3000` |
| `--suffix` | | لاحقة النطاق | `.local` |
| `--skip-hosts` | | تخطي تعديل ملف hosts | - |
| `--save-command` | `-s` | حفظ الأمر في ملف | `modifier.cmd` |
| `--confirm` | | تأكيد التغييرات (عدم الاستعادة إذا كانت الحالة متطابقة) | - |
| `--pass-token` | | تجاوز التحقق من الرمز (موصى به) | - |
| `--debug` | | وضع التصحيح | - |

### ملاحظات خاصة بالمنصات
- **Windows**: تنفيذ مباشر
- **macOS**: التوقيع اليدوي مطلوب بسبب SIP (مثل التنفيذ المباشر إذا تم تعطيل SIP)
  - النص المرجعي: [macos.sh](macos.sh)
- **Linux**: يحتاج إلى التعامل مع تنسيق AppImage
  - النص المرجعي: [linux.sh](linux.sh)

مرحب بمساهمات PR لتحسين نصوص تكييف المنصات!

### 3. إعداد Hosts
إذا كنت تستخدم المعلمة `--skip-hosts`، أضف يدويًا سجلات المضيفين هذه:
```
127.0.0.1 api2.cursor.sh.local api3.cursor.sh.local repo42.cursor.sh.local api4.cursor.sh.local us-asia.gcpp.cursor.sh.local us-eu.gcpp.cursor.sh.local us-only.gcpp.cursor.sh.local
```

### 4. بدء الخدمة
```bash
/path/to/ccursor
```

بالنسبة لمطوري امتدادات أو إضافات بيئة التطوير المتكاملة، أضف المعلمة `--debug` بعد بدء ccursor لمشاهدة السجلات المفصلة.

## تفاصيل الإعداد
في `config.toml`، قم بتعليق أو حذف المعلمات غير المعروفة، **لا تتركها فارغة**.

### الإعداد الأساسي
| العنصر | الوصف | النوع | مطلوب | القيمة الافتراضية | الإصدار المدعوم |
|--------|--------|-------|--------|-------------------|-----------------|
| `check-updates` | التحقق من التحديثات عند بدء التشغيل | bool | ❌ | false | 0.2.0+ |
| `github-token` | رمز وصول GitHub | string | ❌ | "" | 0.2.0+ |
| ~~`usage-statistics`~~ | ~~إحصائيات استخدام النموذج~~ | ~~bool~~ | ❌ | true | 0.2.1-0.2.x، مهمل، تنفيذ مستقبلي في قاعدة البيانات |

### إعداد الخدمة (`service-config`)
| العنصر | الوصف | النوع | مطلوب | القيمة الافتراضية | الإصدار المدعوم |
|--------|--------|-------|--------|-------------------|-----------------|
| `tls` | إعداد شهادة TLS | object | ✅ | {cert_path="", key_path=""} | 0.3.0+ |
| `ip-addr` | عنوان IP استماع الخدمة | object | ✅ | {ipv4="", ipv6=""} | 0.3.1+ |
| `port` | منفذ استماع الخدمة | u16 | ✅ | - | جميع الإصدارات |
| `dns-resolver` | محلل DNS (gai/hickory) | string | ❌ | "gai" | 0.2.0+ |
| `lock-updates` | قفل التحديثات | bool | ✅ | false | جميع الإصدارات |
| `passthrough-unmatched` | تمرير الطلبات غير المطابقة | bool | ✅ | false | 0.3.3+ |
| `fake-email` | إعداد البريد الإلكتروني الوهمي | object | ❌ | {email="", sign-up-type="unknown", enable=false} | 0.2.0+ |
| `service-addr` | إعداد عنوان الخدمة | object | ❌ | {scheme="http", suffix="", port=0} | 0.2.0+ |
| ~~`proxy`~~ | ~~إعداد خادم الوكيل~~ | ~~string~~ | ❌ | - | 0.2.0-0.2.x، مهمل، انتقل إلى `proxies._` |

### إعداد مجمع الوكلاء (`proxies`) - جديد في 0.3.0
| العنصر | الوصف | النوع | مطلوب | القيمة الافتراضية |
|--------|--------|-------|--------|-------------------|
| `اسم_المفتاح` | معرف الإعداد، يتوافق مع `overrides.اسم_المفتاح` | string | ❌ | - |
| `_` | إعداد الوكيل الافتراضي | string | ❌ | "" |

### إعداد التعيين (`override-mapping`) - جديد في 0.3.0
| العنصر | الوصف | النوع | مطلوب | القيمة الافتراضية |
|--------|--------|-------|--------|-------------------|
| `بادئة رمز Bearer` | يعين إلى اسم الإعداد | string | ❌ | - |
| `_` | التعيين الافتراضي | string | ❌ | - |

### إعداد التجاوزات (`overrides.اسم_الإعداد`)
| العنصر | الوصف | النوع | مطلوب | القيمة الافتراضية | الإصدار المدعوم |
|--------|--------|-------|--------|-------------------|-----------------|
| `token` | رمز مصادقة JWT | string | ❌ | - | جميع الإصدارات |
| `traceparent` | الحفاظ على معرف التتبع | bool | ❌ | false | 0.2.0+ |
| `client-key` | تجزئة مفتاح العميل | string | ❌ | - | 0.2.0+ |
| `checksum` | مجموع التحقق المجمع | object | ❌ | - | 0.2.0+ |
| `client-version` | رقم إصدار العميل | string | ❌ | - | 0.2.0+ |
| `config-version` | إصدار الإعداد (UUID) | string | ❌ | - | 0.3.0+ |
| `timezone` | معرف المنطقة الزمنية IANA | string | ❌ | - | جميع الإصدارات |
| `privacy-mode` | إعدادات وضع الخصوصية | bool | ❌ | true | 0.3.0+ |
| `session-id` | معرف الجلسة الفريد (UUID) | string | ❌ | - | 0.2.0+ |

### ملاحظات ترحيل الإصدار
#### 0.2.x → 0.3.0
- **تغييرات رئيسية**:
  - إزالة `current-override`، استبدال بتعيين ديناميكي لرموز Bearer
  - ترحيل `service-config.proxy` إلى `proxies._`
  - إضافة أقسام إعداد جديدة `proxies` و `override-mapping`
  - إعادة تسمية `ghost-mode` إلى `privacy-mode`، مع وظائف محسنة
  - إضافة حقل جديد `config-version`
  - إضافة إعداد `tls` لدعم HTTPS

- **علاقات الإعداد**:
  1. يرسل العميل رمز Bearer (مثل `sk-test123`)
  2. يبحث `override-mapping` عن اسم الإعداد (مثل `sk-test` → `example`)
  3. يستخدم إعدادات الوكيل من `proxies.example`
  4. يستخدم إعدادات التجاوز من `overrides.example`

**ملاحظات خاصة**:
- السلسلة الفارغة `""` تعني عدم استخدام وكيل
- يستخدم المفتاح `_` كإعداد افتراضي/احتياطي
- يُوصى بتعليق عناصر الإعداد الاختيارية لتجنب المشكلات المحتملة
- سيتم دائمًا تحديث ملف التكوين عند إغلاق ccursor. إذا كنت بحاجة إلى تعديل ملف التكوين، يرجى اختيار GET /internal/ConfigUpdate أو الإغلاق ثم التحديث

## الواجهات الداخلية

**القيود**: لا يمكن تشغيلها عبر الوصول بالنطاق، تتطلب وصولاً خارجيًا مع وكيل عكسي مخصص

### ConfigUpdate
**الوظيفة**: تفعيل إعادة تحميل الخدمة بعد تحديث ملف الإعداد، بعض الإعدادات تتطلب إعادة تشغيل الخادم

### CppCount
**الوظيفة**: عداد بسيط لطلبات StreamCpp الناجحة والاستجابات الناجحة

---

*إخلاء المسؤولية مضمن في EULA. قد يتوقف المشروع عن الصيانة في أي وقت.*

Feel free!