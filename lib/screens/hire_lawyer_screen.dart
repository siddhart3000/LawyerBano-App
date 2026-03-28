import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class HireLawyerScreen extends StatefulWidget {
  const HireLawyerScreen({super.key});

  @override
  State<HireLawyerScreen> createState() => _HireLawyerScreenState();
}

class _HireLawyerScreenState extends State<HireLawyerScreen> {
  final List<Map<String, dynamic>> _lawyers = [
    {
      'name': 'Adv. Harish Salve', 
      'exp': '35+ Years', 
      'fees': '₹5,00,000 / Hearing', 
      'special': 'Supreme Court Expert', 
      'field': 'Constitutional Law',
      'isHired': false
    },
    {
      'name': 'Adv. Mukul Rohatgi', 
      'exp': '30+ Years', 
      'fees': '₹4,50,000 / Hearing', 
      'special': 'Criminal & Constitutional', 
      'field': 'Criminal Law',
      'isHired': false
    },
    {
      'name': 'Adv. Karuna Nundy', 
      'exp': '20+ Years', 
      'fees': '₹2,00,000 / Hearing', 
      'special': 'Civil Rights & Corporate', 
      'field': 'Civil Law',
      'isHired': false
    },
    {
      'name': 'Adv. Shanti Bhushan', 
      'exp': '40+ Years', 
      'fees': '₹3,00,000 / Hearing', 
      'special': 'Public Interest Litigation', 
      'field': 'PIL Specialist',
      'isHired': false
    },
    {
      'name': 'Adv. Pinky Anand', 
      'exp': '25+ Years', 
      'fees': '₹2,50,000 / Hearing', 
      'special': 'Family & Corporate Law', 
      'field': 'Family Law',
      'isHired': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final effectiveLang = langProvider.isHinglish ? 'hinglish' : langProvider.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.obsidianBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.midnightBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                TranslationService.translate('hire_luxury_counsel', effectiveLang),
                style: const TextStyle(color: AppTheme.goldenDawn, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppTheme.goldenDawn.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "LAWYERBANO",
                      style: TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final l = _lawyers[index];
                  bool isHired = l['isHired'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.charcoalDeep,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isHired ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.05), 
                        width: 1.5
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.goldenDawn.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      l['field'].toUpperCase(), 
                                      style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 10, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                isHired ? Icons.check_circle : Icons.verified_rounded, 
                                color: isHired ? Colors.green : AppTheme.goldenDawn, 
                                size: 22
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(l['special'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const Divider(height: 30, color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    TranslationService.translate('consultation_fee', effectiveLang), 
                                    style: const TextStyle(color: Colors.white38, fontSize: 12)
                                  ),
                                  Text(l['fees'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: isHired ? null : () {
                                  setState(() => _lawyers[index]['isHired'] = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${l['name']} ${TranslationService.translate('hired_msg', effectiveLang)}"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    )
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isHired ? Colors.green : AppTheme.goldenDawn, 
                                  foregroundColor: isHired ? Colors.white : Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isHired 
                                    ? TranslationService.translate('hired', effectiveLang) 
                                    : TranslationService.translate('hire_now', effectiveLang), 
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _lawyers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
