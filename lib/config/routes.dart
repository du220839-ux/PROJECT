import 'package:go_router/go_router.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/screens/splash/splash_screen.dart';
import 'package:secondhand_app/screens/auth/login_screen.dart';
import 'package:secondhand_app/screens/auth/register_screen.dart';
import 'package:secondhand_app/screens/auth/verify_email_screen.dart';
import 'package:secondhand_app/screens/home/home_screen.dart';
import 'package:secondhand_app/screens/product/product_detail_screen.dart';
import 'package:secondhand_app/screens/product/add_product_screen.dart';
import 'package:secondhand_app/screens/product/edit_product_screen.dart';
import 'package:secondhand_app/screens/product/my_products_screen.dart';
import 'package:secondhand_app/screens/chat/chat_list_screen.dart';
import 'package:secondhand_app/screens/chat/chat_detail_screen.dart';
import 'package:secondhand_app/screens/profile/profile_screen.dart';
import 'package:secondhand_app/screens/profile/edit_profile_screen.dart';
import 'package:secondhand_app/screens/profile/notifications_screen.dart';
import 'package:secondhand_app/screens/profile/transactions_screen.dart';
import 'package:secondhand_app/screens/profile/bank_account_screen.dart';
import 'package:secondhand_app/screens/payment/payment_screen.dart';
import 'package:secondhand_app/screens/admin/admin_reports_screen.dart';
import 'package:secondhand_app/screens/admin/admin_pending_products_screen.dart';
import 'package:secondhand_app/screens/admin/admin_dashboard_screen.dart';
import 'package:secondhand_app/screens/wallet/wallet_screen.dart';
import 'package:secondhand_app/screens/favorites/favorites_screen.dart';
import 'package:secondhand_app/screens/ai_search_screen.dart';
import 'package:secondhand_app/screens/help/help_screen.dart';
import 'package:secondhand_app/widgets/layout/main_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const home = '/home';
  static const productDetail = '/product/:id';
  static const addProduct = '/product/add';
  static const editProduct = '/product/edit/:id';
  static const myProducts = '/my-products';
  static const chatList = '/chats';
  static const chatDetail = '/chat/:userId/:productId';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const notifications = '/notifications';
  static const transactions = '/transactions';
  static const bankAccount = '/bank-account';
  static const payment = '/payment/:productId';
  static const help = '/help';
  static const adminReports = '/admin/reports';
  static const adminPendingProducts = '/admin/products/pending';
  static const adminDashboard = '/admin/dashboard';
  static const wallet = '/wallet';
  static const favorites = '/favorites';
  static const search = '/search';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splash,
      routes: [
        GoRoute(path: splash, builder: (ctx, state) => const SplashScreen()),
        GoRoute(
          path: login,
          builder: (ctx, state) => LoginScreen(initialEmail: state.queryParams['email']),
        ),
        GoRoute(path: register, builder: (ctx, state) => const RegisterScreen()),
        GoRoute(
          path: verifyEmail,
          builder: (ctx, state) => VerifyEmailScreen(email: state.queryParams['email']),
        ),
        ShellRoute(
          builder: (ctx, state, child) => MainShell(
            location: state.location,
            child: child,
          ),
          routes: [
            GoRoute(path: home, builder: (ctx, state) => const HomeScreen()),
            GoRoute(path: chatList, builder: (ctx, state) => const ChatListScreen()),
            GoRoute(path: profile, builder: (ctx, state) => const ProfileScreen()),
            GoRoute(path: favorites, builder: (ctx, state) => const FavoritesScreen()),
          ],
        ),
        GoRoute(path: addProduct, builder: (ctx, state) => const AddProductScreen()),
        GoRoute(
          path: editProduct,
          builder: (ctx, state) => EditProductScreen(
            productId: int.parse(state.params['id']!),
          ),
        ),
        GoRoute(
          path: productDetail,
          builder: (ctx, state) => ProductDetailScreen(
            productId: int.parse(state.params['id']!),
          ),
        ),
        GoRoute(path: myProducts, builder: (ctx, state) => const MyProductsScreen()),
        GoRoute(
          path: chatDetail,
          builder: (ctx, state) => ChatDetailScreen(
            receiverId: int.parse(state.params['userId']!),
            productId: int.parse(state.params['productId']!),
          ),
        ),
        GoRoute(path: editProfile, builder: (ctx, state) => const EditProfileScreen()),
        GoRoute(path: notifications, builder: (ctx, state) => const NotificationsScreen()),
        GoRoute(path: transactions, builder: (ctx, state) => const TransactionsScreen()),
        GoRoute(path: bankAccount, builder: (ctx, state) => const BankAccountScreen()),
        GoRoute(
          path: payment,
          builder: (ctx, state) => PaymentScreen(
            productId: int.parse(state.params['productId']!),
          ),
        ),
        GoRoute(path: adminReports, builder: (ctx, state) => const AdminReportsScreen()),
        GoRoute(path: adminPendingProducts, builder: (ctx, state) => const AdminPendingProductsScreen()),
        GoRoute(path: adminDashboard, builder: (ctx, state) => const AdminDashboardScreen()),
        GoRoute(path: wallet, builder: (ctx, state) => const WalletScreen()),
        GoRoute(path: help, builder: (ctx, state) => const HelpScreen()),
        GoRoute(
          path: search,
          builder: (ctx, state) => const AISearchScreen(),
        ),
      ],
    );
  }
}
