import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../student_model.dart';
import '../class_model.dart';
import '../subject_model.dart';
import '../teacher_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/class_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';
import '../services/local_auth_service.dart';
import '../attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  static const routeName = '/attendance-screen';
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  int? _selectedLessonNumber;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

      await classProvider.fetchClasses();
      if (!mounted) return;
      await subjectProvider.fetchSubjects();
      if (!mounted) return;
      await teacherProvider.fetchTeachers();
      if (!mounted) return;

      if (classProvider.classes.isNotEmpty) {
        _selectedClass = classProvider.classes.first;
      }
      if (subjectProvider.subjects.isNotEmpty) {
        _selectedSubject = subjectProvider.subjects.first;
      }
      if (teacherProvider.teachers.isNotEmpty) {
        _selectedTeacher = teacherProvider.teachers.first;
      }

      await _loadAttendanceData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل البيانات الأولية: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;
    // Only set loading if not already loading from _fetchInitialData to avoid flickering
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await Provider.of<AttendanceProvider>(context, listen: false).fetchAttendances(
        date: _selectedDate,
        classId: _selectedClass!.id,
        subjectId: _selectedSubject!.id,
        teacherId: _selectedTeacher!.id,
        lessonNumber: _selectedLessonNumber,
      );
      if (!mounted) return;
      await Provider.of<StudentProvider>(context, listen: false)
          .searchStudents('', classId: _selectedClass!.classId);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل بيانات الحضور: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        DateFormat('yyyy-MM-dd').format(picked) != _selectedDate) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _loadAttendanceData();
    }
  }

  void _setStudentAttendance(Student student, String status) async {
    if (!mounted) return;
    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد التاريخ والفصل والمادة ورقم الحصة أولاً.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int classId = _selectedClass!.id!;
    final int subjectId = _selectedSubject!.id!;
    final int teacherId = _selectedTeacher!.id!;
    int? lateMinutes;

    if (status == 'late') {
      lateMinutes = await _showLateMinutesDialog(context);
      if (lateMinutes == null) {
        return;
      }
    }

    if (!mounted) return;
    try {
      await Provider.of<AttendanceProvider>(context, listen: false).setAttendanceStatus(
        student.id!,
        classId,
        subjectId,
        teacherId,
        _selectedDate,
        _selectedLessonNumber!,
        status,
        lateMinutes: lateMinutes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم تحديث حضور ${student.name} إلى $status'),
            backgroundColor: Colors.green),
      );
      _loadAttendanceData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('فشل تحديث حالة الحضور: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<int?> _showLateMinutesDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أدخل دقائق التأخير'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'دقائق',
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final int? minutes = int.tryParse(controller.text);
              Navigator.of(context).pop(minutes);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showQrCodeDialog() {
    if (!mounted) return;
    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء تحديد جميع الفلاتر (الفصل, المادة, المعلم, رقم الحصة) لعرض رمز QR.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qrData = {
      'date': _selectedDate,
      'classId': _selectedClass!.id,
      'subjectId': _selectedSubject!.id,
      'teacherId': _selectedTeacher!.id,
      'lessonNumber': _selectedLessonNumber,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Center(
              child: Text('رمز الحضور', style: Theme.of(context).textTheme.titleLarge)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: jsonEncode(qrData),
                version: QrVersions.auto,
                size: 250.0,
                gapless: false,
                dataModuleStyle: QrDataModuleStyle( // Corrected API
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                eyeStyle: QrEyeStyle( // Corrected API
                  eyeShape: QrEyeShape.square,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20),
              Text('تاريخ: $_selectedDate',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('الفصل: ${_selectedClass!.name}',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('المادة: ${_selectedSubject!.name}',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('المعلم: ${_selectedTeacher!.name}',
                  style: Theme.of(context).textTheme.bodyLarge),
              Text('الحصة: $_selectedLessonNumber',
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startScan() async {
    if (!mounted) return;
    final screenContext = context; // Capture the screen's BuildContext

    showDialog(
      context: screenContext, // Use screenContext to show the dialog
      builder: (BuildContext dialogContext) { // dialogContext is the BuildContext of the AlertDialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Center(
              child: Text('مسح رمز الحضور', style: Theme.of(dialogContext).textTheme.titleLarge)),
          content: SizedBox(
            width: 300,
            height: 300,
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
              ),
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                final String? scannedCode = barcodes.first.rawValue;

                if (scannedCode != null) {
                  try {
                    final Map<String, dynamic> scannedData = jsonDecode(scannedCode);

                    final String? scannedDate = scannedData['date'] as String?;
                    final int? scannedClassId = scannedData['classId'] as int?;
                    final int? scannedSubjectId = scannedData['subjectId'] as int?;
                    final int? scannedTeacherId = scannedData['teacherId'] as int?;
                    final int? scannedLessonNumber = scannedData['lessonNumber'] as int?;

                    final currentClass = _selectedClass;
                    final currentSubject = _selectedSubject;
                    final currentTeacher = _selectedTeacher;
                    final currentLessonNumber = _selectedLessonNumber;
                    final currentDate = _selectedDate;

                    if (scannedDate == currentDate &&
                        scannedClassId == currentClass?.id &&
                        scannedSubjectId == currentSubject?.id &&
                        scannedTeacherId == currentTeacher?.id &&
                        scannedLessonNumber == currentLessonNumber) {
                      final authService = Provider.of<LocalAuthService>(dialogContext, listen: false); // Use dialogContext
                      final currentUser = authService.currentUser;

                      if (currentUser != null && currentUser.id != null) {
                        final studentId = currentUser.id!;

                        await Provider.of<AttendanceProvider>(dialogContext, listen: false) // Use dialogContext
                            .setAttendanceStatus(
                          studentId,
                          currentClass!.id!,
                          currentSubject!.id!,
                          currentTeacher!.id!,
                          currentDate,
                          currentLessonNumber!,
                          'present',
                        );

                        if (!screenContext.mounted) return; // Check screenContext.mounted
                        ScaffoldMessenger.of(screenContext).showSnackBar( // Use screenContext
                          const SnackBar(
                            content: Text('تم تسجيل الحضور بنجاح!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        if (!screenContext.mounted) return; // Check screenContext.mounted
                        ScaffoldMessenger.of(screenContext).showSnackBar( // Use screenContext
                          const SnackBar(
                            content: Text('لا يمكن تسجيل الحضور. يرجى تسجيل الدخول كطالب.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      if (!screenContext.mounted) return; // Check screenContext.mounted
                      ScaffoldMessenger.of(screenContext).showSnackBar( // Use screenContext
                        const SnackBar(
                          content: Text('بيانات رمز الحضور غير متطابقة مع الجلسة الحالية.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!screenContext.mounted) return; // Check screenContext.mounted
                    ScaffoldMessenger.of(screenContext).showSnackBar( // Use screenContext
                      const SnackBar(
                        content: Text('خطأ في قراءة رمز الحضور.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Do not print in production code
                    // print("Error processing QR code: $e");
                  } finally {
                    if (dialogContext.mounted) { // Check dialogContext.mounted before popping the dialog
                      Navigator.of(dialogContext).pop(); // Use dialogContext
                    }
                  }
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                if (dialogContext.mounted) { // Check dialogContext.mounted
                  Navigator.of(dialogContext).pop(); // Use dialogContext
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final authService = Provider.of<LocalAuthService>(context);

    final bool isTeacherOrAdmin =
        authService.currentUser?.role == 'teacher' || authService.currentUser?.role == 'admin';
    final bool isStudent = authService.currentUser?.role == 'student';

    bool allFiltersSelected = _selectedClass != null &&
        _selectedSubject != null &&
        _selectedTeacher != null &&
        _selectedLessonNumber != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تسجيل الحضور والغياب',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
        actions: [
          if (isTeacherOrAdmin)
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              onPressed: _showQrCodeDialog,
              tooltip: 'عرض رمز الحضور للطلاب',
            ),
          if (isStudent)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _startScan,
              tooltip: 'مسح رمز الحضور',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTeacherOrAdmin) ...[
                  ListTile(
                    title: Text('تاريخ الحصة', style: Theme.of(context).textTheme.titleMedium),
                    trailing: TextButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_selectedDate),
                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const Divider(),
                  _buildFilterDropdown<SchoolClass>(
                    context,
                    'الفصل',
                    _selectedClass,
                    classProvider.classes,
                    (newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _selectedSubject = null;
                      });
                      _loadAttendanceData();
                    },
                    (c) => c.name,
                    classProvider.classes.isEmpty ? 'لا توجد فصول' : null,
                  ),
                  _buildFilterDropdown<Subject>(
                    context,
                    'المادة',
                    _selectedSubject,
                    subjectProvider.subjects,
                    (newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                      _loadAttendanceData();
                    },
                    (s) => s.name,
                    subjectProvider.subjects.isEmpty ? 'لا توجد مواد' : null,
                  ),
                  _buildFilterDropdown<Teacher>(
                    context,
                    'المعلم',
                    _selectedTeacher,
                    teacherProvider.teachers,
                    (newValue) {
                      setState(() {
                        _selectedTeacher = newValue;
                      });
                      _loadAttendanceData();
                    },
                    (t) => t.name,
                    teacherProvider.teachers.isEmpty ? 'لا يوجد معلمون' : null,
                  ),
                  _buildFilterDropdown<int>(
                    context,
                    'رقم الحصة',
                    _selectedLessonNumber,
                    List.generate(6, (index) => index + 1),
                    (newValue) {
                      setState(() {
                        _selectedLessonNumber = newValue;
                      });
                      _loadAttendanceData();
                    },
                    (lessonNum) => 'الحصة $lessonNum',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'الطلاب في الفصل ${_selectedClass?.name ?? 'المحدد'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (_isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (classProvider.classes.isEmpty) {
                          return _buildEmptyState(
                              context, 'لا توجد فصول متاحة. الرجاء إضافة فصول أولاً.', Icons.school_outlined);
                        }
                        if (subjectProvider.subjects.isEmpty) {
                          return _buildEmptyState(
                              context, 'لا توجد مواد متاحة. الرجاء إضافة مواد أولاً.', Icons.menu_book);
                        }
                        if (teacherProvider.teachers.isEmpty) {
                          return _buildEmptyState(
                              context, 'لا يوجد معلمون متاحون. الرجاء إضافة معلمين أولاً.', Icons.person_add);
                        }
                        if (!allFiltersSelected) {
                          return _buildEmptyState(context,
                              'الرجاء تحديد جميع الفلاتر (الفصل, المادة, المعلم, رقم الحصة) لعرض قائمة الطلاب.', Icons.filter_alt);
                        }
                        if (studentProvider.students.isEmpty) {
                          return _buildEmptyState(context,
                              'لا يوجد طلاب في هذا الفصل أو لم يتم العثور على طلاب مطابقين.', Icons.person_off);
                        }
                        return ListView.builder(
                          itemCount: studentProvider.students.length,
                          itemBuilder: (context, index) {
                            final student = studentProvider.students[index];
                            final currentAttendanceRecord = attendanceProvider.attendances.firstWhere(
                              (att) =>
                                  att.studentId == student.id! &&
                                  att.date == _selectedDate &&
                                  att.lessonNumber == (_selectedLessonNumber ?? -1),
                              orElse: () => Attendance(
                                studentId: student.id!,
                                classId: _selectedClass!.id!,
                                subjectId: _selectedSubject!.id!,
                                teacherId: _selectedTeacher!.id!,
                                date: _selectedDate,
                                lessonNumber: _selectedLessonNumber!,
                                status: 'unknown',
                                lateMinutes: 0,
                              ),
                            );
                            final currentStatus = currentAttendanceRecord.status;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        student.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: currentStatus == 'unknown' ? null : currentStatus,
                                        hint: const Text('الحالة'),
                                        onChanged: allFiltersSelected
                                            ? (newValue) {
                                                if (newValue != null) {
                                                  _setStudentAttendance(student, newValue);
                                                }
                                              }
                                            : null,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'present',
                                            child: Text('حاضر'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'absent',
                                            child: Text('غائب'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'late',
                                            child: Text('متأخر'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'excused',
                                            child: Text('معتذر'),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12.0),
                                        elevation: 2,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                    if (currentStatus == 'late')
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '(${currentAttendanceRecord.lateMinutes ?? 0} دقيقة)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.orange.shade700),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ] else if (isStudent) ...[
                  _buildEmptyState(context,
                      'يرجى استخدام زر مسح رمز الحضور لتسجيل حضورك.', Icons.qr_code_scanner),
                ] else ...[
                  _buildEmptyState(context,
                      'يرجى تسجيل الدخول كمعلم أو مسؤول لإدارة الحضور والغياب.',
                      Icons.person_off_outlined),
                ],
              ],
            ),
          ),
          if (_isLoading && allFiltersSelected)
            Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Color.fromRGBO(0, 0, 0, 0.5)),
            ),
          if (_isLoading && allFiltersSelected)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    BuildContext context,
    String label,
    T? selectedValue,
    List<T> items,
    ValueChanged<T?> onChanged,
    String Function(T) itemText, [
    String? emptyMessage,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha((0.7 * 255).round())),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.2 * 255).round()),
        ),
        isEmpty: selectedValue == null,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: selectedValue,
            hint: emptyMessage != null ? Text(emptyMessage) : Text('اختر $label'),
            isExpanded: true,
            onChanged: items.isEmpty || _isLoading ? null : onChanged,
            items: items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(itemText(value)),
              );
            }).toList(),
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 2,
            style: Theme.of(context).textTheme.bodyLarge,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, [IconData? icon]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
