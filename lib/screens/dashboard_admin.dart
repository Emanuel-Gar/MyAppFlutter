import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importamos el paquete de gráficas

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final List<Widget> pages = [
      _buildClientManagementTab(primaryColor), // Clientes
      _buildWorkersTab(primaryColor),          // Trabajadores
      _buildFinanceTab(primaryColor),          // Finanzas
      _buildReportsTab(primaryColor),          // Reportes con Gráficas Reales
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Panel Administrativo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: 'Trabajadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_rounded),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }

  // --- SECCIÓN 1: CLIENTES ---
  Widget _buildClientManagementTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSectionHeader('Gestión de Clientes', 'Administra el estado de los usuarios'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Usuarios Activos', '1,420', Icons.check_circle_outline, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Bloqueados', '35', Icons.block_rounded, Colors.red)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Listado de Clientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildClientTile(name: 'Carlos Mendoza', email: 'carlos@email.com', isActive: true),
        _buildClientTile(name: 'Ana Sofía Ruiz', email: 'ana.ruiz@email.com', isActive: false),
        _buildClientTile(name: 'Jorge Luis Pérez', email: 'jorge@email.com', isActive: true),
      ],
    );
  }

  // --- SECCIÓN 2: TRABAJADORES ---
  Widget _buildWorkersTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSectionHeader('Control de Trabajadores', 'Revisa documentación y desempeño'),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.folder_shared_rounded,
          title: 'Documentación Pendiente',
          subtitle: '4 trabajadores requieren revisión de documentos',
          color: Colors.orange,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.work_history_rounded,
          title: 'Servicios Realizados',
          subtitle: 'Historial completo de trabajos por técnico',
          color: Colors.blue,
          onTap: () {},
        ),
      ],
    );
  }

  // --- SECCIÓN 3: FINANZAS ---
  Widget _buildFinanceTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSectionHeader('Resumen Financiero', 'Control de ingresos y comisiones'),
        const SizedBox(height: 16),
        _buildFinanceCard('Ganancias Mensuales (Netas)', '\$24,500.00 MXN', primaryColor),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Comisiones', '\$6,120.00', Icons.pie_chart, Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Pagos Realizados', '\$18,380.00', Icons.payments, Colors.teal)),
          ],
        ),
      ],
    );
  }

  // --- SECCIÓN 4: REPORTES CON GRÁFICAS REALES ---
  Widget _buildReportsTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSectionHeader('Reportes y Estadísticas', 'Métricas gráficas de la plataforma'),
        const SizedBox(height: 16),

        // 1. Gráfica de Barras: Trabajos Realizados por Día / Semana
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Trabajos Realizados (Semana)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Text(days[value.toInt()], style: const TextStyle(fontSize: 11, color: Colors.grey));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBarGroup(0, 8, primaryColor),
                      _makeBarGroup(1, 12, primaryColor),
                      _makeBarGroup(2, 6, primaryColor),
                      _makeBarGroup(3, 15, primaryColor),
                      _makeBarGroup(4, 10, primaryColor),
                      _makeBarGroup(5, 18, primaryColor),
                      _makeBarGroup(6, 14, primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Gráfica de Líneas: Crecimiento de Comisiones Generadas
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comisiones Generadas (Últimos Meses)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct'];
                            if (value.toInt() >= 0 && value.toInt() < months.length) {
                              return Text(months[value.toInt()], style: const TextStyle(fontSize: 11, color: Colors.grey));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 5),
                          FlSpot(2, 4),
                          FlSpot(3, 8),
                          FlSpot(4, 11),
                          FlSpot(5, 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método auxiliar para generar barras limpias
  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildClientTile({required String name, required String email, required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isActive ? 'Activo' : 'Bloqueado',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Switch(
                value: isActive,
                onChanged: (val) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceCard(String title, String amount, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}