import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/translation_service.dart';
import '../services/grok_service.dart';
import '../core/app_theme.dart';

class LegalInfoScreen extends StatefulWidget {
  const LegalInfoScreen({super.key});

  @override
  State<LegalInfoScreen> createState() => _LegalInfoScreenState();
}

class _LegalInfoScreenState extends State<LegalInfoScreen> {
  List<dynamic> _allLegalInfo = [];
  final GrokService _grokService = GrokService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLegalInfo();
  }

  Future<void> _loadLegalInfo() async {
    final String response = await rootBundle.loadString('assets/data/legal_info.json');
    final data = await json.decode(response);
    setState(() {
      _allLegalInfo = data;
    });
  }

  void _handleSearch(String query, String langCode) async {
    if (query.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.obsidianBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("AI Analysis: $query", style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white10),
            Expanded(
              child: FutureBuilder<String>(
                future: _grokService.getLegalAdvice(query, langCode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn));
                  }
                  return SingleChildScrollView(
                    child: Text(snapshot.data ?? "Error fetching analysis", style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final effectiveLang = langProvider.isHinglish ? 'hinglish' : langProvider.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.obsidianBlack : Colors.white,
      appBar: AppBar(
        title: Text(TranslationService.translate('legal_info', effectiveLang), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.midnightBlue,
        foregroundColor: AppTheme.goldenDawn,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.midnightBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationService.translate('types_of_law', effectiveLang),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchField(effectiveLang),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _allLegalInfo.length,
                itemBuilder: (context, index) {
                  final info = _allLegalInfo[index];
                  return _buildLegalCard(info, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String langCode) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.charcoalDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldenDawn.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (val) => _handleSearch(val, langCode),
        decoration: InputDecoration(
          hintText: '${TranslationService.translate('search', langCode)}...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: AppTheme.goldenDawn),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLegalCard(dynamic info, bool isDark) {
    Color cardColor;
    switch(info['color']) {
      case 'blue': cardColor = Colors.blue.shade100; break;
      case 'orange': cardColor = Colors.orange.shade100; break;
      case 'green': cardColor = Colors.green.shade100; break;
      case 'yellow': cardColor = Colors.yellow.shade100; break;
      case 'deepPurple': cardColor = Colors.deepPurple.shade100; break;
      case 'pink': cardColor = Colors.pink.shade100; break;
      case 'teal': cardColor = Colors.teal.shade100; break;
      case 'blueGrey': cardColor = Colors.blueGrey.shade100; break;
      case 'brown': cardColor = Colors.brown.shade100; break;
      case 'indigo': cardColor = Colors.indigo.shade100; break;
      default: cardColor = Colors.grey.shade100;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.charcoalDeep : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: cardColor.withOpacity(0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconData(info['icon']), color: isDark ? cardColor : Colors.black87, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (info['points'] as List).length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(color: isDark ? cardColor : Colors.black54)),
                      Expanded(
                        child: Text(
                          info['points'][i],
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch(name) {
      case 'gavel': return Icons.gavel;
      case 'eco': return Icons.eco;
      case 'account_balance': return Icons.account_balance;
      case 'family_restroom': return Icons.family_restroom;
      case 'business': return Icons.business;
      case 'work': return Icons.work;
      case 'history_edu': return Icons.history_edu;
      case 'monetization_on': return Icons.monetization_on;
      case 'copyright': return Icons.copyright;
      case 'public': return Icons.public;
      default: return Icons.info;
    }
  }
}
