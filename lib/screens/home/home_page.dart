import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'widgets/home_sections.dart';
import 'widgets/side_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthenticationRepository>();

    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final sections = const [
            DashboardSection(),
            OrdersSection(),
            ProductsSection(),
            CustomersSection(),
            ReportsSection(),
            SettingsSection(),
          ];

          return Scaffold(
            body: Row(
              children: [
                SideNav(
                  selectedIndex: state.selectedIndex,
                  onSelect: (index) async {
                    if (index == -1) {
                      try {
                        await authRepo.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to logout: $e')),
                          );
                        }
                      }
                      return;
                    }
                    context.read<HomeCubit>().selectTab(index);
                  },
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF3F4F6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: sections[state.selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
