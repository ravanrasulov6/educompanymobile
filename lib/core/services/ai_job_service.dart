import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/openai_config.dart';

/// Service for tracking async AI jobs (polling + realtime).
class AiJobService {
  AiJobService._();
  static final AiJobService instance = AiJobService._();

  SupabaseClient get _sb => Supabase.instance.client;
  String get _userId => _sb.auth.currentUser!.id;

  /// Get job status by ID.
  Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      return await _sb
          .from('ai_jobs')
          .select()
          .eq('id', jobId)
          .eq('user_id', _userId)
          .single();
    } catch (_) {
      return null;
    }
  }

  /// Get all jobs for current user.
  Future<List<Map<String, dynamic>>> getJobs({String? jobType}) async {
    var query = _sb
        .from('ai_jobs')
        .select()
        .eq('user_id', _userId);

    if (jobType != null) {
      query = query.eq('job_type', jobType);
    }

    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Get job events (observability log).
  Future<List<Map<String, dynamic>>> getJobEvents(String jobId) async {
    final data = await _sb
        .from('ai_job_events')
        .select()
        .eq('job_id', jobId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Poll job status with callback. Returns a timer that can be cancelled.
  Timer pollJobStatus({
    required String jobId,
    required void Function(Map<String, dynamic> job) onUpdate,
    required void Function() onComplete,
    required void Function(String error) onError,
    Duration interval = const Duration(seconds: 2),
  }) {
    return Timer.periodic(interval, (timer) async {
      try {
        final job = await getJob(jobId);
        if (job == null) {
          timer.cancel();
          onError('Job not found');
          return;
        }

        onUpdate(job);

        final status = job['status'] as String;
        if (status == 'completed') {
          timer.cancel();
          onComplete();
        } else if (status == 'failed' || status == 'cancelled') {
          timer.cancel();
          onError(job['error_message'] as String? ?? 'Job failed');
        }
      } catch (e) {
        debugPrint('[AiJobService] Poll error: $e');
      }
    });
  }

  /// Subscribe to real-time job updates via Supabase Realtime.
  RealtimeChannel subscribeToJob({
    required String jobId,
    required void Function(Map<String, dynamic> payload) onUpdate,
  }) {
    return _sb.channel('job-$jobId').onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'ai_jobs',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: jobId,
      ),
      callback: (payload) {
        onUpdate(payload.newRecord);
      },
    ).subscribe();
  }

  /// Unsubscribe from job channel.
  Future<void> unsubscribeFromJob(RealtimeChannel channel) async {
    await _sb.removeChannel(channel);
  }
}
