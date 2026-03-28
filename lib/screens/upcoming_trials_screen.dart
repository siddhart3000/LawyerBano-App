import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class UpcomingTrialsScreen extends StatefulWidget {
  const UpcomingTrialsScreen({super.key});

  @override
  State<UpcomingTrialsScreen> createState() => _UpcomingTrialsScreenState();
}

class _UpcomingTrialsScreenState extends State<UpcomingTrialsScreen> {
  final _caseNameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _addTrial(String lang) async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.charcoalDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
          title: Text(TranslationService.translate('schedule_trial', lang), style: const TextStyle(color: AppTheme.goldenDawn, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _caseNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: TranslationService.translate('case_name', lang),
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppTheme.goldenDawn),
                title: Text(
                  _selectedDate == null ? TranslationService.translate('select_date', lang) : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setDialogState(() => _selectedDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppTheme.goldenDawn),
                title: Text(
                  _selectedTime == null ? TranslationService.translate('select_time', lang) : _selectedTime!.format(context),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setDialogState(() => _selectedTime = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(TranslationService.translate('cancel', lang), style: const TextStyle(color: Colors.white38))),
            ElevatedButton(
              onPressed: () async {
                if (_caseNameController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('trials')
                        .add({
                      'title': _caseNameController.text.trim(),
                      'date': DateFormat('dd MMM yyyy').format(_selectedDate!),
                      'time': _selectedTime!.format(context),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      _caseNameController.clear();
                      _selectedDate = null;
                      _selectedTime = null;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(TranslationService.translate('trial_saved', lang)))
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldenDawn, foregroundColor: Colors.black),
              child: Text(TranslationService.translate('save_trial', lang)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final langProvider = Provider.of<LanguageProvider>(context);
    final effectiveLang = langProvider.isHinglish ? 'hinglish' : langProvider.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.obsidianBlack,
      appBar: AppBar(
        title: Text(TranslationService.translate('upcoming_trials', effectiveLang), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldenDawn)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.goldenDawn),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('trials')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(TranslationService.translate('no_trials', effectiveLang), 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white38))
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final trial = snapshot.data!.docs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.charcoalDeep,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.goldenDawn.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.event_available, color: AppTheme.goldenDawn),
                  ),
                  title: Text(trial['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("${trial['date']} • ${trial['time']}", style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 13)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => trial.reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTrial(effectiveLang),
        backgroundColor: AppTheme.goldenDawn,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
