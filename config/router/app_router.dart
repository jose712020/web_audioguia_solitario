import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:audioguia_web/provider/auth_provider.dart';
import 'package:audioguia_web/presentation/screens/login_screen.dart';
import 'package:audioguia_web/presentation/screens/dashboard_screen.dart';
import 'package:audioguia_web/presentation/screens/noticias_screen.dart';
import 'package:audioguia_web/presentation/screens/config_screen.dart';
import 'package:audioguia_web/presentation/screens/agrega_monumento_screen.dart';
import 'package:audioguia_web/presentation/screens/rendimiento_screen.dart';
import 'package:audioguia_web/presentation/screens/edita_monumento_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isAuthenticated = auth.autenticado;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoggingIn) {
      return '/login';
    }

    if (isAuthenticated && isLoggingIn) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/noticias',
      name: 'noticias',
      builder: (context, state) => const NoticiasPage(),
    ),
    GoRoute(
      path: '/configuracion',
      name: 'configuracion',
      builder: (context, state) => const ConfiguracionPage(),
    ),
    GoRoute(
      path: '/monumentos/agregar',
      name: 'agregar_monumento',
      builder: (context, state) => const AgregaMonumentoPage(),
    ),
    GoRoute(
      path: '/rendimiento',
      name: 'rendimiento',
      builder: (context, state) => const RendimientoPage(),
    ),
    GoRoute(
      path: '/monumentos/editar/:id',
      name: 'editar_monumento',
      builder: (context, state) {
        final monumento = state.pathParameters['id'] ?? '';
        return EditaMonumentoScreen(monumentoId: monumento);
      },
    ),
  ],
);
