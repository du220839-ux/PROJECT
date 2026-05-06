import 'package:flutter/material.dart';
import 'package:secondhand_app/config/theme.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'bug_report_screen.dart';
import 'terms_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
            Tab(text: 'Liên hệ', icon: Icon(Icons.mail_outline)),
            Tab(text: 'Báo lỗi', icon: Icon(Icons.bug_report_outlined)),
            Tab(text: 'Điều khoản', icon: Icon(Icons.description_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FAQScreen(),
          ContactSupportScreen(),
          BugReportScreen(),
          TermsScreen(),
        ],
      ),
    );
  }
}
