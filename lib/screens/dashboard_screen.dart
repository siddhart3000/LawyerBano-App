import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/auth_service.dart';
import '../services/grok_service.dart';
import '../services/translation_service.dart';
import '../core/app_theme.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'find_lawyer_screen.dart';
import 'legal_info_screen.dart';
import 'upcoming_trials_screen.dart';
import 'hire_lawyer_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isLawyer;
  final bool isGuest;
  const DashboardScreen({super.key, required this.isLawyer, this.isGuest = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final GrokService _grokService = GrokService();
  String _userName = "Guest User"; 
  List<Map<String, String>> _verdicts = [];
  bool _isLoadingVerdicts = true;
  int _totalTrials = 0;
  List<Map<String, dynamic>> _todaysTrials = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(); // Auto-refresh when app comes to foreground
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoadingVerdicts = true);
    if (!widget.isGuest) {
      await _fetchUserName();
      await _fetchTrialAnalytics();
    } else {
      setState(() {
        _userName = "Guest";
        _totalTrials = 0;
        _todaysTrials = [];
      });
    }
    await _fetchVerdicts();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _authService.getUserData(user.uid);
      if (doc != null && doc.exists) {
        setState(() => _userName = doc.get('name') ?? "User");
      }
    }
  }

  Future<void> _fetchTrialAnalytics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('trials')
          .get();

      final now = DateTime.now();
      final todayStr = DateFormat('dd MMM yyyy').format(now);

      List<Map<String, dynamic>> todayList = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['date'] == todayStr) {
          todayList.add(data);
        }
      }

      setState(() {
        _totalTrials = querySnapshot.docs.length;
        _todaysTrials = todayList;
      });
    } catch (e) {
      print("Error fetching analytics: $e");
    }
  }

  Future<void> _fetchVerdicts() async {
    final data = await _grokService.getLatestVerdicts();
    setState(() {
      _verdicts = data;
      _isLoadingVerdicts = false;
    });
  }

  void _handleSearch(String query, String langCode) async {
    if (widget.isGuest) {
      _showGuestLoginPrompt();
      return;
    }
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
            Text("Analysis: $query", style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 20, fontWeight: FontWeight.bold)),
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

  void _showGuestLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.charcoalDeep,
        title: const Text("Login Required", style: TextStyle(color: AppTheme.goldenDawn)),
        content: const Text("Please login to access all categories and features.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldenDawn),
            child: const Text("Login", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.currentLocale.languageCode;
    final isHinglish = langProvider.isHinglish;
    final effectiveLang = isHinglish ? 'hinglish' : lang;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.obsidianBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.midnightBlue, AppTheme.obsidianBlack, AppTheme.charcoalDeep],
          ),
        ),
        child: RefreshIndicator(
          color: AppTheme.goldenDawn,
          backgroundColor: AppTheme.charcoalDeep,
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(TranslationService.translate('hello', effectiveLang), style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 18, fontWeight: FontWeight.w300)),
                              Text(
                                _userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildLanguageToggle(langProvider),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                              icon: const Icon(Icons.menu_rounded, color: AppTheme.goldenDawn, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(TranslationService.translate('search', effectiveLang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.goldenDawn)),
                      const SizedBox(height: 16),
                      _buildSearchField(effectiveLang),
                      const SizedBox(height: 32),

                      Text(TranslationService.translate('categories', effectiveLang), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.goldenDawn)),
                      const SizedBox(height: 16),
                      if (widget.isGuest)
                        _buildLockedCategories(effectiveLang)
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildLuxuryCategoryCard(
                                widget.isLawyer ? TranslationService.translate('find_client', effectiveLang) : TranslationService.translate('find_lawyer', effectiveLang),
                                "Connect with top profiles...",
                                Icons.gavel_rounded,
                                0.7,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindLawyerScreen())),
                              ),
                              _buildLuxuryCategoryCard(
                                TranslationService.translate('legal_info', effectiveLang),
                                "Comprehensive guides...",
                                Icons.menu_book_rounded,
                                0.4,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalInfoScreen())),
                              ),
                              _buildLuxuryCategoryCard(
                                TranslationService.translate('upcoming_trials', effectiveLang),
                                "Manage court dates...",
                                Icons.event_note_rounded,
                                0.2,
                                () async {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingTrialsScreen()));
                                  if (result == true) _refreshData();
                                }),
                              _buildLuxuryCategoryCard(
                                TranslationService.translate('hire_lawyer', effectiveLang),
                                "Secure top legal counsel...",
                                Icons.person_add_rounded,
                                0.1,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HireLawyerScreen())),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      if (!widget.isGuest) _buildAnalyticalDashboard(effectiveLang),
                      const SizedBox(height: 32),

                      Text("Legal Updates", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.goldenDawn)),
                      const SizedBox(height: 16),
                      if (_isLoadingVerdicts)
                        const Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn))
                      else
                        ..._verdicts.map((v) => _buildVerdictCard(v)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context, effectiveLang),
    );
  }

  Widget _buildLockedCategories(String langCode) {
    return GestureDetector(
      onTap: _showGuestLoginPrompt,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.charcoalDeep,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.goldenDawn.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppTheme.goldenDawn, size: 48),
            const SizedBox(height: 16),
            const Text("Categories Locked", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              "Please login to access our professional services.", 
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldenDawn),
              child: const Text("Login Now", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(LanguageProvider langProvider) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate_rounded, color: AppTheme.goldenDawn, size: 28),
      color: AppTheme.charcoalDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
      onSelected: (val) {
        if (val == 'hinglish') {
          langProvider.setHinglish(true);
        } else {
          langProvider.setHinglish(false);
          langProvider.setLanguage(val);
        }
      },
      itemBuilder: (context) => [
        _buildLangItem('en', 'English'),
        _buildLangItem('hi', 'Hindi'),
        _buildLangItem('hinglish', 'Hinglish'),
      ],
    );
  }

  PopupMenuItem<String> _buildLangItem(String val, String label) {
    return PopupMenuItem(
      value: val,
      child: Text(label, style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildSearchField(String langCode) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.charcoalDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldenDawn.withOpacity(0.2)),
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

  Widget _buildLuxuryCategoryCard(String title, String desc, IconData icon, double progress, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        height: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.goldenDawn.withOpacity(0.2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 40, color: AppTheme.goldenDawn),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldenDawn),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticalDashboard(String langCode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.charcoalDeep,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.goldenDawn.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: AppTheme.goldenDawn),
              SizedBox(width: 12),
              Text("Legal Analytics Console", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(_totalTrials.toString(), "Total Trials"),
              _buildMetric(_todaysTrials.length.toString(), "Due Today"),
              _buildMetric("Active", "Case Status"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppTheme.goldenDawn, fontWeight: FontWeight.bold, fontSize: 22)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildVerdictCard(Map<String, String> v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.charcoalDeep.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.goldenDawn, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${v['lawyer']} • ${v['time']}', style: const TextStyle(color: AppTheme.goldenDawn, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String langCode) {
    return Drawer(
      backgroundColor: AppTheme.obsidianBlack,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.midnightBlue, AppTheme.obsidianBlack],
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldenDawn)),
              accountEmail: Text(widget.isGuest ? "Guest Access" : "Premium Member", style: const TextStyle(color: Colors.white70)),
              currentAccountPicture: const Icon(Icons.account_circle_rounded, color: AppTheme.goldenDawn, size: 80),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppTheme.goldenDawn),
              title: Text(TranslationService.translate('profile', langCode), style: const TextStyle(color: Colors.white)),
              onTap: () async {
                if (widget.isGuest) {
                  Navigator.pop(context);
                  _showGuestLoginPrompt();
                  return;
                }
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(isLawyer: widget.isLawyer)));
                if (result == true) {
                  _refreshData();
                }
              },
            ),
            if (!widget.isGuest)
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: Text(TranslationService.translate('delete_account', langCode), style: const TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog();
                },
              ),
            const Spacer(),
            ListTile(
              leading: Icon(widget.isGuest ? Icons.login : Icons.logout, color: widget.isGuest ? AppTheme.goldenDawn : Colors.redAccent),
              title: Text(widget.isGuest ? "Sign In" : TranslationService.translate('sign_out', langCode), style: TextStyle(color: widget.isGuest ? AppTheme.goldenDawn : Colors.redAccent)),
              onTap: () {
                _authService.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.charcoalDeep,
        title: const Text("Delete Account permanently?", style: TextStyle(color: Colors.redAccent)),
        content: const Text("This action cannot be undone. All your data will be wiped.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async {
            Navigator.pop(context);
            setState(() => _isLoadingVerdicts = true);
            final success = await _authService.deleteUserAccount();
            if (success) {
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            } else {
              setState(() => _isLoadingVerdicts = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed. Please re-authenticate.")));
            }
          }, child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}
