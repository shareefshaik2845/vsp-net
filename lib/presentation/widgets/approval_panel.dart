import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../domain/entities.dart';
import '../providers/state_provider.dart';

class ApprovalPanel extends ConsumerWidget {
  final List<Map<String, dynamic>> remoteApprovals;
  final void Function(String id, String status, {String? reason})? onResolve;

  const ApprovalPanel({
    super.key,
    required this.remoteApprovals,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvals = remoteApprovals
        .map((m) => ApprovalRequest(
              id: m['id']?.toString() ?? '',
              resourceType: m['resourceType'] as String? ?? '',
              resourceId: m['resourceId'] as String? ?? '',
              action: m['action'] as String? ?? '',
              payload: (m['payload'] as Map<String, dynamic>?) ?? {},
              requestedBy: m['requestedBy'] as String? ?? '',
              approvedBy: m['approvedBy'] as String?,
              status: m['status'] == 'approved'
                  ? ApprovalStatus.approved
                  : m['status'] == 'rejected'
                      ? ApprovalStatus.rejected
                      : ApprovalStatus.pending,
              createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
              resolvedAt: DateTime.tryParse(m['resolvedAt'] as String? ?? ''),
              rejectionReason: m['rejectionReason'] as String?,
            ))
        .toList();
    final pending = approvals.where((a) => a.status == ApprovalStatus.pending).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.approval_outlined, color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pending Approvals',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal,
                  ),
                ),
              ),
              if (pending.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${pending.length} pending',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: Colors.green.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'No pending approvals',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ResortTheme.charcoal.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pending.map((req) => _buildApprovalTile(req, ref)),
        ],
      ),
    );
  }

  Widget _buildApprovalTile(ApprovalRequest req, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResortTheme.softCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pending_outlined, size: 16, color: Colors.orange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${req.action} ${req.resourceType}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ResortTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested by ${req.requestedBy}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ResortTheme.charcoal.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  onResolve?.call(req.id, 'rejected', reason: 'Rejected by admin');
                  ref.read(notificationsProvider.notifier).addNotification(
                    'Approval Rejected',
                    '${req.action} on ${req.resourceType} was rejected.',
                    'system',
                  );
                },
                icon: const Icon(Icons.close, size: 14),
                label: Text('Reject', style: GoogleFonts.inter(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  onResolve?.call(req.id, 'approved');
                  ref.read(notificationsProvider.notifier).addNotification(
                    'Approval Granted',
                    '${req.action} on ${req.resourceType} was approved.',
                    'system',
                  );
                },
                icon: const Icon(Icons.check, size: 14),
                label: Text('Approve', style: GoogleFonts.inter(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResortTheme.mossGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
