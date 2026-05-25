import 'package:go_router/go_router.dart';
import 'package:audioguia_web/presentation/screens/login_screen.dart';
import 'package:audioguia_web/presentation/screens/dashboard_screen.dart';
import 'package:audioguia_web/presentation/screens/noticias_screen.dart';
import 'package:audioguia_web/presentation/screens/config_screen.dart';
import 'package:audioguia_web/presentation/screens/agrega_monumento_screen.dart';
import 'package:audioguia_web/presentation/screens/rendimiento_screen.dart';
import 'package:audioguia_web/presentation/screens/edita_monumento_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
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
