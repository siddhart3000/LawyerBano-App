import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../core/app_theme.dart';

class FindLawyerScreen extends StatefulWidget {
  const FindLawyerScreen({super.key});

  @override
  State<FindLawyerScreen> createState() => _FindLawyerScreenState();
}

class _FindLawyerScreenState extends State<FindLawyerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _searchQuery = "";
  String _selectedState = "All";
  String _currentUserRole = "";
  bool _isLoading = true;

  final List<String> _states = [
    "All", "Delhi", "Maharashtra", "Rajasthan", "Karnataka", "Uttar Pradesh", "Tamil Nadu", "Gujarat", "Bihar", "Punjab", "Haryana"
  ];

  @override
  void initState() {
    super.initState();
    _determineUserRole();
  }

  Future<void> _determineUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _currentUserRole = doc.data()?['role'] ?? 'client';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final targetRole = _currentUserRole == 'lawyer' ? 'client' : 'lawyer';
    final screenTitle = _currentUserRole == 'lawyer' ? "Find Clients" : "Find a Lawyer";

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.obsidianBlack,
        body: Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(screenTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search by name, state or district...",
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  dropdownColor: isDark ? AppTheme.charcoalDeep : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: "Filter by State",
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedState = val!);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').where('role', isEqualTo: targetRole).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.goldenDawn));

                final docs = snapshot.data?.docs ?? [];
                
                // Client-side filtering for search query and state
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final state = (data['state'] ?? "").toString().toLowerCase();
                  final district = (data['district'] ?? "").toString().toLowerCase();
                  
                  bool matchesSearch = name.contains(_searchQuery) || 
                                     state.contains(_searchQuery) || 
                                     district.contains(_searchQuery);
                  
                  bool matchesState = _selectedState == "All" || 
                                     (data['state'] ?? "").toString().toLowerCase() == _selectedState.toLowerCase();
                  
                  return matchesSearch && matchesState;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${targetRole}s found nearby.", 
                      style: const TextStyle(color: Colors.white54)
                    )
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    return _buildUserCard(data, isDark, targetRole);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> data, bool isDark, String role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30, 
                  backgroundColor: AppTheme.goldenDawn, 
                  child: Text(
                    (data['name'] ?? "U")[0].toUpperCase(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "Unknown User", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87)
                      ),
                      Text(
                        role == 'lawyer' ? (data['bio'] ?? "Legal Expert") : "Seeking Legal Assistance", 
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.location_on, "${data['district'] ?? 'District'}, ${data['state'] ?? 'State'}", isDark),
            if (data['subDistrict'] != null && data['subDistrict'].toString().isNotEmpty)
              _buildInfoRow(Icons.map, data['subDistrict'], isDark),
            _buildInfoRow(Icons.email, data['email'] ?? "No email provided", isDark),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text("Message"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldenDawn, 
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.goldenDawn), 
                      foregroundColor: AppTheme.goldenDawn,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.goldenDawn),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
