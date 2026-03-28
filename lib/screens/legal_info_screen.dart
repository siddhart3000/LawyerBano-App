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
  List<dynamic> _filteredInfo = [];
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
      _allLegalInfo = data['types_of_law'];
      _filteredInfo = data['types_of_law'];
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredInfo = _allLegalInfo
          .where((info) => info['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleAISearch(String query, String langCode) async {
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
      backgroundColor: AppTheme.obsidianBlack,
      appBar: AppBar(
        title: const Text("Legal Info", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldenDawn)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.goldenDawn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: const BoxDecoration(
              color: AppTheme.midnightBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Types of Law",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                _buildSearchField(effectiveLang),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredInfo.length,
              itemBuilder: (context, index) {
                return _buildLegalCard(_filteredInfo[index]);
              },
            ),
          ),
        ],
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
        onChanged: _filterSearch,
        onSubmitted: (val) => _handleAISearch(val, langCode),
        decoration: const InputDecoration(
          hintText: 'Search or ask AI...',
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search, color: AppTheme.goldenDawn),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLegalCard(dynamic info) {
    // Parse color from JSON (e.g., "0xFF7B91B0")
    Color bgColor = Color(int.parse(info['color']));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconData(info['icon']), color: Colors.black.withOpacity(0.7), size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  info['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (info['points'] as List).map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.black54, fontSize: 10)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 9.5,
                          height: 1.2,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch(name) {
      case 'gavel': return Icons.gavel_rounded;
      case 'eco': return Icons.eco_rounded;
      case 'balance': return Icons.account_balance_rounded;
      case 'family_restroom': return Icons.family_restroom_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'work': return Icons.work_rounded;
      case 'account_balance': return Icons.museum_rounded;
      case 'receipt_long': return Icons.receipt_long_rounded;
      case 'copyright': return Icons.copyright_rounded;
      case 'public': return Icons.public_rounded;
      default: return Icons.info_rounded;
    }
  }
}
