# مخطط المشروع (Blueprint)

## نظرة عامة على المشروع

هذا المشروع عبارة عن نظام لإدارة الطلاب تم تطويره باستخدام Flutter ويهدف إلى توفير واجهة سهلة الاستخدام لإدارة معلومات الطلاب، الفصول الدراسية، الدرجات، الحضور، والجداول الزمنية. يتضمن التطبيق ميزات لتسجيل الدخول، لوحة تحكم شاملة، ونظام تبويب لتنظيم البيانات.

## التصميم والميزات المنفذة

*   **تطبيق Material Design 3 المتكامل:**
    *   **الألوان:** استخدام `ColorScheme.fromSeed` لإنشاء لوحة ألوان متناسقة، وتطبيقها بشكل منهجي على جميع المكونات.
    *   **الخطوط (Typography):** دمج `google_fonts` لتحديد خطوط مخصصة وواضحة، مع تطبيق `TextTheme` لضمان اتساق أنماط النصوص (مثل `displayLarge`, `titleMedium`, `bodySmall`).
    *   **تخصيص المكونات:** استخدام `ThemeData` لتخصيص مظهر الأزرار (`ElevatedButtonThemeData`)، أشرطة التطبيق (`AppBarTheme`)، وغيرها من مكونات Material لإنشاء هوية بصرية فريدة.
    *   **الاستجابة والتكيف (Responsiveness):**
    *   تكييف تخطيطات الشاشات المختلفة (خاصة لوحات القيادة والجداول) لتبدو جيدة على أحجام الشاشات المختلفة (الهواتف المحمولة، الأجهزة اللوحية، الويب).
    *   استخدام `MediaQuery` و `LayoutBuilder` لتصميم واجهات مرنة.
*   **الحركات الانتقالية والجاذبية:**
    *   إضافة حركات انتقالية مخصصة بين الشاشات لتحسين التجربة البصرية.
*   **إدارة الحالة (State Management):**
    *   استخدام `provider` لإدارة الحالة على مستوى التطبيق.
    *   فئات `ChangeNotifier` مخصصة (مثل `StudentProvider`, `ClassProvider`, `SubjectProvider`, `TeacherProvider`, `AttendanceProvider`, `GradeProvider`, `TimetableProvider`, `ThemeProvider`) لإدارة البيانات والمنطق الخاص بكل جزء).
*   **شاشات رئيسية:**
    *   `LoginScreen`: شاشة تسجيل الدخول للمستخدمين.
    *   `RegisterScreen`: شاشة تسجيل مستخدمين جدد (تم تعيينها كالشاشة الافتراضية عند عدم تسجيل الدخول).
    *   `DashboardScreen`: لوحة تحكم رئيسية مع نظام تبويبات (`BottomNavigationBar`) للتنقل بين الأقسام.
    *   `ParentPortalScreen`: شاشة خاصة بأولياء الأمور لعرض معلومات الطلاب.
    *   `StudentDetailForParentScreen`: تفاصيل الطالب لولي الأمر.
*   **علامات التبويب في لوحة التحكم (Dashboard Tabs):**
    *   `StudentsTab`: عرض وإدارة الطلاب.
    *   `ClassesTab`: عرض وإدارة الفصول الدراسية.
    *   `SubjectsTab`: عرض وإدارة المواد.
    *   `TeachersTab`: عرض وإدارة المعلمين.
    *   `GradesOverviewTab`: نظرة عامة على الدرجات.
    *   `GradesBulkEntryTab`: إدخال الدرجات بشكل مجمع.
    *   `ReportsTab`: عرض التقارير.
    *   `SettingsTab`: إعدادات التطبيق (يتضمن معلومات حول التطبيق).
*   **شاشات الإضافة والتعديل:**
    *   `AddEditStudentScreen`
    *   `AddEditClassScreen`
    *   `AddEditSubjectScreen`
    *   `AddEditTeacherScreen`
    *   `AddEditTimetableScreen`
    *   `AddEditGradeDialog` (كحوار ضمن شاشة الدرجات).
*   **ميزات أخرى:**
    *   `AttendanceScreen`: شاشة لتسجيل الحضور.
    *   `GradesScreen`: شاشة تفاصيل الدرجات.
    *   `TimetableScreen`: شاشة عرض الجدول الزمني.
    *   `LocalAuthService`: لخدمات المصادقة المحلية (مثل بصمة الإصبع/الوجه).
    *   تكامل قاعدة البيانات المحلية (SQLite) باستخدام `database_helper.dart`.
    *   نماذج بيانات (Models) منفصلة لكل كيان (`StudentModel`, `ClassModel`, `SubjectModel`, `TeacherModel`, `AttendanceModel`, `GradeModel`, `TimetableModel`, `UserModel`).
    *   اختبارات الوحدة (Unit Tests) لبعض المزودين والشاشات.

## الحالة الحالية: المشكلات المحلولة

تم حل المشكلات المتعلقة بـ "معاينة الويب الفارغة وعدم التعرف على جهاز الويب" و "التطبيق ليس مثبت" على أندرويد. يبدو أن البيئة جاهزة الآن لمزيد من التطوير.

## الخطة الحالية: عرض واجهة التسجيل عند تشغيل التطبيق

**الهدف:** جعل `RegisterScreen` هي الشاشة الافتراضية التي تظهر عند بدء تشغيل التطبيق إذا لم يكن هناك مستخدم مسجل الدخول، وذلك لتمكين المستخدمين الجدد من التسجيل مباشرة.

**التغييرات المنفذة:**

*   تم تعديل `lib/main.dart` لإضافة استيراد `RegisterScreen`.
*   تم تعديل `AppInitializer` في `lib/main.dart` ليعرض `RegisterScreen` بدلاً من `LoginScreen` عندما يكون `authService.isAuthenticated` خاطئًا.

## مشكلة جديدة: معاينة الويب الفارغة بسبب MissingPluginException

**الهدف:** حل مشكلة `MissingPluginException` التي تمنع التطبيق من التهيئة والعمل على الويب، والتي تحدث لأن مكون `sqflite` الإضافي لا يحتوي على تطبيق ويب.

**الخطوات التي تم اتخاذها:**

*   تم تشغيل `flutter doctor -v` لتشخيص بيئة Flutter.
*   تم قبول جميع تراخيص Android المطلوبة باستخدام `flutter doctor --android-licenses`.
*   تم إضافة حزمة دعم الويب `sqflite_common_ffi_web`.
*   تم تعديل `lib/database_helper.dart` لتهيئة قاعدة البيانات بشكل صحيح على الويب.
*   تم حل مشكلة `No space left on device` عن طريق تشغيل `flutter clean`.

## إنجازات حديثة:

*   **بناء ملف APK بنجاح!** تم إنشاء ملف التثبيت: `build/app/outputs/flutter-apk/app-release.apk`.
*   **تم حل مشكلة تضارب إصدار Android NDK!** تم تحديث `ndkVersion` في `android/app/build.gradle.kts` إلى `27.0.12077973`.

**الخطة الحالية:**

1.  **تنظيف المشروع:**
    *   الأمر: `flutter clean`
    *   الهدف: إزالة ملفات البناء المؤقتة بعد تعديل إعدادات NDK.
2.  **بناء ملف APK:**
    *   الأمر: `flutter build apk`
    *   الهدف: إنشاء ملف APK جديد بعد تطبيق إصلاح NDK والتأكد من عدم وجود تحذيرات.

سأقوم الآن بتنفيذ الأمر `flutter clean`.
