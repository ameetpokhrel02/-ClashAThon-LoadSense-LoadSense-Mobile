import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/workload_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_model.dart';


import '../../widgets/screen_header.dart';

class CalendarScreen extends StatefulWidget {
  final bool showBackButton;
  const CalendarScreen({super.key, this.showBackButton = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkloadProvider>().fetchAll();
      context.read<DeadlineProvider>().fetchDeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workload = context.watch<WorkloadProvider>();
    final deadlineProvider = context.watch<DeadlineProvider>();
    final stats = workload.calendarStats?.dailyHours ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ScreenHeader(
            title: 'Calendar',
            subtitle: 'Schedule & Deadlines',
            showNotification: false,
            showBackButton: widget.showBackButton,
            action: IconButton(
              icon: const Icon(Icons.today, color: Colors.white),
              onPressed: () => setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              }),
            ),
          ),
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return deadlineProvider.deadlines.where((d) => isSameDay(d.dueDate, day)).toList();
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    right: 1,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${events.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final hours = stats[dateKey] ?? 0;
                  return _buildDayCell(day, hours, false);
                },
                selectedBuilder: (context, day, focusedDay) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final hours = stats[dateKey] ?? 0;
                  return _buildDayCell(day, hours, true);
                },
                todayBuilder: (context, day, focusedDay) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final hours = stats[dateKey] ?? 0;
                  return _buildDayCell(day, hours, false, isToday: true);
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildDetailsForDay(_selectedDay!),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsForDay(DateTime day) {
    final deadlineProvider = context.watch<DeadlineProvider>();
    final dayDeadlines = deadlineProvider.deadlines.where((d) => isSameDay(d.dueDate, day)).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(day),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (dayDeadlines.isNotEmpty)
              Chip(
                label: Text('${dayDeadlines.length} tasks'),
                backgroundColor: AppColors.primaryLight,
                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (dayDeadlines.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.event_available_outlined, size: 64, color: AppColors.textDisabled),
                SizedBox(height: 16),
                Text('No deadlines for this day', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...dayDeadlines.map((d) => _buildDeadlineCard(d)),
      ],
    );
  }

  Widget _buildDeadlineCard(Deadline deadline) {
    final status = deadline.isCompleted ? 'COMPLETED' : 'PENDING';
    final statusColor = deadline.isCompleted ? AppColors.success : AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: _getPriorityColor(deadline.priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(deadline.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(deadline.moduleName ?? 'No Module'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, double hours, bool isSelected, {bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
          ? AppColors.primary 
          : (isToday ? AppColors.primaryLight : Colors.transparent),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected ? Colors.white : (isToday ? AppColors.primary : AppColors.textPrimary),
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hours > 0)
            Text(
              '${hours.toInt()}h',
              style: TextStyle(
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                fontSize: 8,
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }
}
