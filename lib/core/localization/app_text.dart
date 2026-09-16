// lib/core/localization/app_text.dart

import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

abstract class AppTextReader {
  String get(String key, {required String fallback});
  String get commonBack => get('common_back', fallback: 'Back');
  String get appTitle => get('app_title', fallback: 'Posture Reset');
  String get navDashboard => get('nav_dashboard', fallback: 'Dashboard');
  String get navSessions => get('nav_sessions', fallback: 'Sessions');
  String get navQuickFix => get('nav_quick_fix', fallback: 'Quick Fix');
  String get navInsights => get('nav_insights', fallback: 'Insights');
  String get navProfile => get('nav_profile', fallback: 'Profile');
  String get commonRetry => get('common_retry', fallback: 'Retry');
  String get commonBackHome =>
      get('common_back_home', fallback: 'Back to dashboard');
  String get startupLoadingTitle =>
      get('startup_loading_title', fallback: 'Starting app');
  String get startupLoadingSubtitle => get(
        'startup_loading_subtitle',
        fallback: 'Preparing app services and loading startup configuration.',
      );
  String get startupErrorTitle =>
      get('startup_error_title', fallback: 'Startup failed');
  String get startupErrorSubtitle => get(
        'startup_error_subtitle',
        fallback:
            'The app could not finish startup. Check configuration and try again.',
      );
  String get routeNotFoundTitle =>
      get('route_not_found_title', fallback: 'Page not found');
  String get routeNotFoundSubtitle => get(
        'route_not_found_subtitle',
        fallback:
            'The requested page does not exist or is no longer available.',
      );
}

class _GeneratedAppTextReader extends AppTextReader {
  _GeneratedAppTextReader(this._t);

  final AppLocalizations _t;

  @override
  String get(String key, {required String fallback}) {
    switch (key) {
      // Core app
      case 'app_title':
        return _t.appTitle;
      case 'nav_dashboard':
        return _t.navDashboard;
      case 'nav_sessions':
        return _t.navSessions;
      case 'nav_quick_fix':
        return _t.navQuickFix;
      case 'nav_insights':
        return _t.navInsights;
      case 'nav_profile':
        return _t.navProfile;
      case 'common_retry':
        return _t.commonRetry;
      case 'common_back_home':
        return _t.commonBackHome;
      case 'startup_loading_title':
        return _t.startupLoadingTitle;
      case 'startup_loading_subtitle':
        return _t.startupLoadingSubtitle;
      case 'startup_error_title':
        return _t.startupErrorTitle;
      case 'startup_error_subtitle':
        return _t.startupErrorSubtitle;
      case 'route_not_found_title':
        return _t.routeNotFoundTitle;
      case 'route_not_found_subtitle':
        return _t.routeNotFoundSubtitle;
      case 'common_back':
        return _t.common_back;

      case 'saved_sessions_title':
        return _t.saved_sessions_title;
      case 'saved_sessions_empty_title':
        return _t.saved_sessions_empty_title;
      case 'saved_sessions_empty_body':
        return _t.saved_sessions_empty_body;
      case 'saved_sessions_browse_cta':
        return _t.saved_sessions_browse_cta;
      case 'saved_sessions_error':
        return _t.saved_sessions_error;

      case 'session_history_title':
        return _t.session_history_title;
      case 'session_history_empty_title':
        return _t.session_history_empty_title;
      case 'session_history_empty_body':
        return _t.session_history_empty_body;
      case 'session_history_error':
        return _t.session_history_error;

      case 'continuity_continue_title':
        return _t.continuity_continue_title;
      case 'continuity_resume_title':
        return _t.continuity_resume_title;
      case 'continuity_repeat_title':
        return _t.continuity_repeat_title;
      case 'continuity_start_title':
        return _t.continuity_start_title;
      case 'continuity_continue_cta':
        return _t.continuity_continue_cta;
      case 'continuity_resume_cta':
        return _t.continuity_resume_cta;
      case 'continuity_repeat_cta':
        return _t.continuity_repeat_cta;
      case 'continuity_start_cta':
        return _t.continuity_start_cta;
      case 'continuity_open_detail':
        return _t.continuity_open_detail;
      case 'continuity_reason_active':
        return _t.continuity_reason_active;
      case 'continuity_reason_resumable':
        return _t.continuity_reason_resumable;
      case 'continuity_reason_saved':
        return _t.continuity_reason_saved;
      case 'continuity_reason_repeat':
        return _t.continuity_reason_repeat;
      case 'continuity_resume_available':
        return _t.continuity_resume_available;
      case 'continuity_status_started':
        return _t.continuity_status_started;
      case 'continuity_status_completed':
        return _t.continuity_status_completed;
      case 'continuity_status_abandoned':
        return _t.continuity_status_abandoned;
      case 'continuity_label_active':
        return _t.continuity_label_active;
      case 'continuity_label_resumable':
        return _t.continuity_label_resumable;
      case 'continuity_label_repeatable':
        return _t.continuity_label_repeatable;
      case 'continuity_label_saved':
        return _t.continuity_label_saved;
      case 'continuity_strip_title':
        return _t.continuity_strip_title;
      // Player
      case 'session_detail_back_tooltip':
        return _t.session_detail_back_tooltip;
      case 'player_completion_body_impact_title':
        return _t.player_completion_body_impact_title;
      case 'player_completion_effect_release':
        return _t.player_completion_effect_release;
      case 'player_completion_effect_reset':
        return _t.player_completion_effect_reset;
      case 'player_completion_close':
        return _t.player_completion_close;
      case 'player_media_placeholder_body_short':
        return _t.player_media_placeholder_body_short;
      case 'player_media_placeholder_chip':
        return _t.player_media_placeholder_chip;
      case 'player_media_placeholder_body':
        return _t.player_media_placeholder_body;
      case 'session_player_title':
        return _t.session_player_title;
      case 'player_close_tooltip':
        return _t.player_close_tooltip;
      case 'player_progress_title':
        return _t.player_progress_title;
      case 'player_step_label_prefix':
        return _t.player_step_label_prefix;
      case 'player_step_label_empty':
        return _t.player_step_label_empty;
      case 'player_current_step_label':
        return _t.player_current_step_label;
      case 'player_step_type_label':
        return _t.player_step_type_label;
      case 'player_step_duration_label':
        return _t.player_step_duration_label;
      case 'player_step_skippable_label':
        return _t.player_step_skippable_label;
      case 'player_target_label':
        return _t.player_target_label;
      case 'player_terminal_title':
        return _t.player_terminal_title;
      case 'player_pause_cta':
        return _t.player_pause_cta;
      case 'player_resume_cta':
        return _t.player_resume_cta;
      case 'player_previous_cta':
        return _t.player_previous_cta;
      case 'player_next_cta':
        return _t.player_next_cta;
      case 'player_skip_cta':
        return _t.player_skip_cta;
      case 'player_replay_cta':
        return _t.player_replay_cta;
      case 'player_finish_cta':
        return _t.player_finish_cta;
      case 'player_exit_title':
        return _t.player_exit_title;
      case 'player_exit_message':
        return _t.player_exit_message;
      case 'player_exit_cancel_cta':
        return _t.player_exit_cancel_cta;
      case 'player_exit_confirm_cta':
        return _t.player_exit_confirm_cta;
      case 'player_not_found_title':
        return _t.player_not_found_title;
      case 'player_not_found_message':
        return _t.player_not_found_message;
      case 'player_no_steps_title':
        return _t.player_no_steps_title;
      case 'player_no_steps_message':
        return _t.player_no_steps_message;
      case 'player_error_title':
        return _t.player_error_title;
      case 'player_error_subtitle':
        return _t.player_error_subtitle;
      case 'player_back_cta':
        return _t.player_back_cta;
      case 'player_loading_title':
        return _t.player_loading_title;
      case 'player_auth_required_title':
        return _t.player_auth_required_title;
      case 'player_auth_required_message':
        return _t.player_auth_required_message;
      case 'player_auth_required_cta':
        return _t.player_auth_required_cta;
      case 'player_status_completed':
        return _t.player_status_completed;
      case 'player_status_running_log':
        return _t.player_status_running_log;
      case 'player_status_paused_log':
        return _t.player_status_paused_log;
      case 'player_status_completed_log':
        return _t.player_status_completed_log;
      case 'player_next_step_log_prefix':
        return _t.player_next_step_log_prefix;
      case 'player_runtime_summary_title':
        return _t.player_runtime_summary_title;
      case 'player_runtime_elapsed':
        return _t.player_runtime_elapsed;
      case 'player_runtime_remaining':
        return _t.player_runtime_remaining;
      case 'player_runtime_step_remaining':
        return _t.player_runtime_step_remaining;
      case 'player_breath_cue_title':
        return _t.player_breath_cue_title;
      case 'player_safety_note_title':
        return _t.player_safety_note_title;
      case 'player_completion_title':
        return _t.player_completion_title;
      case 'player_completion_subtitle':
        return _t.player_completion_subtitle;
      case 'player_completion_steps':
        return _t.player_completion_steps;
      case 'player_completion_total_time':
        return _t.player_completion_total_time;
      case 'player_completion_back_to_detail':
        return _t.player_completion_back_to_detail;

      // Sessions library
      case 'sessions_featured_title':
        return _t.sessions_featured_title;
      case 'sessions_all_results_title':
        return _t.sessions_all_results_title;
      case 'sessions_all_results_subtitle':
        return _t.sessions_all_results_subtitle;
      case 'sessions_error_title':
        return _t.sessions_error_title;
      case 'sessions_error_body':
        return _t.sessions_error_body;
      case 'sessions_empty_title':
        return _t.sessions_empty_title;
      case 'sessions_empty_body':
        return _t.sessions_empty_body;
      case 'sessions_no_results_title':
        return _t.sessions_no_results_title;
      case 'sessions_no_results_body':
        return _t.sessions_no_results_body;
      case 'sessions_clear_filters_cta':
        return _t.sessions_clear_filters_cta;
      case 'sessions_search_hint':
        return _t.sessions_search_hint;
      case 'sessions_category_all':
        return _t.sessions_category_all;
      case 'sessions_category_neck_shoulders':
        return _t.sessions_category_neck_shoulders;
      case 'sessions_category_upper_back':
        return _t.sessions_category_upper_back;
      case 'sessions_category_lower_back':
        return _t.sessions_category_lower_back;
      case 'sessions_category_wrists_forearms':
        return _t.sessions_category_wrists_forearms;
      case 'sessions_category_focus':
        return _t.sessions_category_focus;
      case 'sessions_category_recovery':
        return _t.sessions_category_recovery;
      case 'sessions_category_quiet_desk':
        return _t.sessions_category_quiet_desk;
      case 'sessions_sort_recommended':
        return _t.sessions_sort_recommended;
      case 'sessions_sort_duration_shortest':
        return _t.sessions_sort_duration_shortest;
      case 'sessions_sort_duration_longest':
        return _t.sessions_sort_duration_longest;
      case 'sessions_sort_intensity_lowest':
        return _t.sessions_sort_intensity_lowest;
      case 'sessions_sort_intensity_highest':
        return _t.sessions_sort_intensity_highest;
      case 'sessions_sort_alphabetical':
        return _t.sessions_sort_alphabetical;
      case 'sessions_filter_silent_only':
        return _t.sessions_filter_silent_only;
      case 'sessions_filter_beginner_only':
        return _t.sessions_filter_beginner_only;
      case 'sessions_intro_title':
        return _t.sessions_intro_title;
      case 'sessions_intro_body':
        return _t.sessions_intro_body;
      case 'sessions_intensity_gentle':
        return _t.sessions_intensity_gentle;
      case 'sessions_intensity_light':
        return _t.sessions_intensity_light;
      case 'sessions_intensity_moderate':
        return _t.sessions_intensity_moderate;
      case 'sessions_intensity_strong':
        return _t.sessions_intensity_strong;
      case 'sessions_tag_silent':
        return _t.sessions_tag_silent;
      case 'sessions_tag_beginner':
        return _t.sessions_tag_beginner;

      // Session detail
      case 'session_detail_start_button':
      case 'session_detail_start_cta':
        return _t.session_detail_start_button;
      case 'session_detail_save_button':
      case 'session_detail_save_cta':
        return _t.session_detail_save_button;
      case 'session_detail_saved_button':
      case 'session_detail_saved_cta':
        return _t.session_detail_saved_button;
      case 'session_detail_saved_success':
        return _t.session_detail_saved_success;
      case 'session_detail_unsaved_success':
        return _t.session_detail_unsaved_success;
      case 'session_detail_sign_in_to_save':
        return _t.session_detail_sign_in_to_save;
      case 'session_detail_go_to_profile':
        return _t.session_detail_go_to_profile;
      case 'session_detail_save_requires_account_hint':
        return _t.session_detail_save_requires_account_hint;
      case 'session_detail_silent_friendly':
        return _t.session_detail_silent_friendly;
      case 'session_detail_beginner_friendly':
        return _t.session_detail_beginner_friendly;
      case 'session_detail_goals_title':
        return _t.session_detail_goals_title;
      case 'session_detail_compatibility_title':
        return _t.session_detail_compatibility_title;
      case 'session_detail_modes_title':
        return _t.session_detail_modes_title;
      case 'session_detail_environment_title':
        return _t.session_detail_environment_title;
      case 'session_detail_related_title':
        return _t.session_detail_related_title;
      case 'session_detail_related_empty':
        return _t.session_detail_related_empty;
      case 'session_detail_related_error':
        return _t.session_detail_related_error;
      case 'session_detail_equipment_title':
        return _t.session_detail_equipment_title;
      case 'session_detail_saving_cta':
        return _t.session_detail_saving_cta;
      case 'session_detail_steps_empty':
        return _t.session_detail_steps_empty;
      case 'session_detail_step_skippable':
        return _t.session_detail_step_skippable;
      case 'session_detail_save_failed':
        return _t.session_detail_save_failed;

      // Session enums/labels
      case 'session_intensity_gentle':
        return _t.session_intensity_gentle;
      case 'session_intensity_light':
        return _t.session_intensity_light;
      case 'session_intensity_moderate':
        return _t.session_intensity_moderate;
      case 'session_intensity_strong':
        return _t.session_intensity_strong;
      case 'session_goal_pain_relief':
        return _t.session_goal_pain_relief;
      case 'session_goal_posture_reset':
        return _t.session_goal_posture_reset;
      case 'session_goal_focus_prep':
        return _t.session_goal_focus_prep;
      case 'session_goal_recovery':
        return _t.session_goal_recovery;
      case 'session_goal_mobility':
        return _t.session_goal_mobility;
      case 'session_goal_decompression':
        return _t.session_goal_decompression;
      case 'session_mode_dad':
        return _t.session_mode_dad;
      case 'session_mode_night':
        return _t.session_mode_night;
      case 'session_mode_focus':
        return _t.session_mode_focus;
      case 'session_mode_pain_relief':
        return _t.session_mode_pain_relief;
      case 'session_env_desk_friendly':
        return _t.session_env_desk_friendly;
      case 'session_env_office_friendly':
        return _t.session_env_office_friendly;
      case 'session_env_home_friendly':
        return _t.session_env_home_friendly;
      case 'session_env_no_mat':
        return _t.session_env_no_mat;
      case 'session_env_low_space':
        return _t.session_env_low_space;
      case 'session_env_quiet':
        return _t.session_env_quiet;
      case 'session_step_type_setup':
        return _t.session_step_type_setup;
      case 'session_step_type_movement':
        return _t.session_step_type_movement;
      case 'session_step_type_hold':
        return _t.session_step_type_hold;
      case 'session_step_type_breath':
        return _t.session_step_type_breath;
      case 'session_step_type_transition':
        return _t.session_step_type_transition;
      case 'session_step_type_cooldown':
        return _t.session_step_type_cooldown;

      // Auth
      case 'auth_page_title':
        return _t.auth_page_title;
      case 'auth_sign_in_title':
        return _t.auth_sign_in_title;
      case 'auth_sign_up_title':
        return _t.auth_sign_up_title;
      case 'auth_sign_in_subtitle':
        return _t.auth_sign_in_subtitle;
      case 'auth_sign_up_subtitle':
        return _t.auth_sign_up_subtitle;
      case 'auth_sign_in_tab':
        return _t.auth_sign_in_tab;
      case 'auth_sign_up_tab':
        return _t.auth_sign_up_tab;
      case 'auth_email_label':
        return _t.auth_email_label;
      case 'auth_password_label':
        return _t.auth_password_label;
      case 'auth_confirm_password_label':
        return _t.auth_confirm_password_label;
      case 'auth_email_required':
        return _t.auth_email_required;
      case 'auth_email_invalid':
        return _t.auth_email_invalid;
      case 'auth_password_required':
        return _t.auth_password_required;
      case 'auth_password_too_short':
        return _t.auth_password_too_short;
      case 'auth_confirm_password_required':
        return _t.auth_confirm_password_required;
      case 'auth_confirm_password_mismatch':
        return _t.auth_confirm_password_mismatch;
      case 'auth_submitting':
        return _t.auth_submitting;
      case 'auth_sign_in_button':
        return _t.auth_sign_in_button;
      case 'auth_sign_up_button':
        return _t.auth_sign_up_button;
      case 'auth_sign_in_success':
        return _t.auth_sign_in_success;
      case 'auth_sign_up_success_signed_in':
        return _t.auth_sign_up_success_signed_in;
      case 'auth_sign_up_check_email':
        return _t.auth_sign_up_check_email;
      case 'auth_unknown_error':
        return _t.auth_unknown_error;
      case 'auth_signed_out_success':
        return _t.auth_signed_out_success;

      // Profile
      case 'profile_sign_out_tooltip':
        return _t.profile_sign_out_tooltip;
      case 'profile_account_access_section_title':
        return _t.profile_account_access_section_title;
      case 'profile_account_access_section_subtitle':
        return _t.profile_account_access_section_subtitle;
      case 'profile_account_sign_in_title':
        return _t.profile_account_sign_in_title;
      case 'profile_account_sign_in_subtitle':
        return _t.profile_account_sign_in_subtitle;
      case 'profile_account_manage_title':
        return _t.profile_account_manage_title;
      case 'profile_account_signed_in_subtitle':
        return _t.profile_account_signed_in_subtitle;
      case 'profile_status_plan_signed_in_value':
        return _t.profile_status_plan_signed_in_value;
      case 'profile_status_plan_signed_in_subtitle':
        return _t.profile_status_plan_signed_in_subtitle;
      case 'profile_account_guest_name':
        return _t.profile_account_guest_name;
      case 'profile_account_guest_subtitle':
        return _t.profile_account_guest_subtitle;
      case 'profile_account_guest_initial':
        return _t.profile_account_guest_initial;
      case 'profile_account_signed_in_name':
        return _t.profile_account_signed_in_name;
      case 'profile_account_tag_signed_in':
        return _t.profile_account_tag_signed_in;
      case 'profile_account_tag_session_save':
        return _t.profile_account_tag_session_save;
      case 'profile_account_tag_guest':
        return _t.profile_account_tag_guest;
      case 'profile_account_tag_sign_in_needed':
        return _t.profile_account_tag_sign_in_needed;
      case 'profile_account_sign_in_button':
        return _t.profile_account_sign_in_button;
      case 'profile_account_create_button':
        return _t.profile_account_create_button;
      case 'profile_account_sign_out_button':
        return _t.profile_account_sign_out_button;
      case 'profile_preferences_section_subtitle':
        return _t.profile_preferences_section_subtitle;
      case 'profile_status_section_subtitle':
        return _t.profile_status_section_subtitle;
      case 'profile_status_account_title':
        return _t.profile_status_account_title;
      case 'profile_status_account_signed_in':
        return _t.profile_status_account_signed_in;
      case 'profile_status_account_guest':
        return _t.profile_status_account_guest;
      case 'profile_status_account_signed_in_subtitle':
        return _t.profile_status_account_signed_in_subtitle;
      case 'profile_status_account_guest_subtitle':
        return _t.profile_status_account_guest_subtitle;
      case 'profile_status_session_save_title':
        return _t.profile_status_session_save_title;
      case 'profile_status_session_save_enabled':
        return _t.profile_status_session_save_enabled;
      case 'profile_status_session_save_disabled':
        return _t.profile_status_session_save_disabled;
      case 'profile_status_session_save_enabled_subtitle':
        return _t.profile_status_session_save_enabled_subtitle;
      case 'profile_status_session_save_disabled_subtitle':
        return _t.profile_status_session_save_disabled_subtitle;
      case 'profile_status_plan_subtitle':
        return _t.profile_status_plan_subtitle;
              // Quick Fix
      case 'quick_fix_title':
        return _t.quick_fix_title;
      case 'quick_fix_history_tooltip':
        return _t.quick_fix_history_tooltip;
      case 'quick_fix_loading_title':
        return _t.quick_fix_loading_title;
      case 'quick_fix_error_title':
        return _t.quick_fix_error_title;
      case 'quick_fix_error_body':
        return _t.quick_fix_error_body;
      case 'quick_fix_empty_title':
        return _t.quick_fix_empty_title;
      case 'quick_fix_empty_body':
        return _t.quick_fix_empty_body;
      case 'quick_fix_hero_eyebrow':
        return _t.quick_fix_hero_eyebrow;
      case 'quick_fix_hero_title':
        return _t.quick_fix_hero_title;
      case 'quick_fix_hero_body':
        return _t.quick_fix_hero_body;
      case 'quick_fix_hero_stat_fast':
        return _t.quick_fix_hero_stat_fast;
      case 'quick_fix_hero_stat_silent':
        return _t.quick_fix_hero_stat_silent;
      case 'quick_fix_hero_stat_personalized':
        return _t.quick_fix_hero_stat_personalized;
      case 'quick_fix_problem_section_title':
        return _t.quick_fix_problem_section_title;
      case 'quick_fix_problem_section_subtitle':
        return _t.quick_fix_problem_section_subtitle;
      case 'quick_fix_context_section_title':
        return _t.quick_fix_context_section_title;
      case 'quick_fix_context_section_subtitle':
        return _t.quick_fix_context_section_subtitle;
      case 'quick_fix_state_section_title':
        return _t.quick_fix_state_section_title;
      case 'quick_fix_state_section_subtitle':
        return _t.quick_fix_state_section_subtitle;
      case 'quick_fix_recommendation_section_title':
        return _t.quick_fix_recommendation_section_title;
      case 'quick_fix_recommendation_section_subtitle':
        return _t.quick_fix_recommendation_section_subtitle;
      case 'quick_fix_recommendation_missing':
        return _t.quick_fix_recommendation_missing;
      case 'quick_fix_primary_match_label':
        return _t.quick_fix_primary_match_label;
      case 'quick_fix_reasoning_default':
        return _t.quick_fix_reasoning_default;
      case 'quick_fix_more_matches_title':
        return _t.quick_fix_more_matches_title;
      case 'quick_fix_start_now_cta':
        return _t.quick_fix_start_now_cta;
      case 'quick_fix_view_details_cta':
        return _t.quick_fix_view_details_cta;
      case 'quick_fix_silent_mode_title':
        return _t.quick_fix_silent_mode_title;
      case 'quick_fix_problem_neck':
        return _t.quick_fix_problem_neck;
      case 'quick_fix_problem_shoulder':
        return _t.quick_fix_problem_shoulder;
      case 'quick_fix_problem_wrist':
        return _t.quick_fix_problem_wrist;
      case 'quick_fix_problem_back':
        return _t.quick_fix_problem_back;
      case 'quick_fix_problem_eye':
        return _t.quick_fix_problem_eye;
      case 'quick_fix_problem_stress':
        return _t.quick_fix_problem_stress;
      case 'quick_fix_time_2':
        return _t.quick_fix_time_2;
      case 'quick_fix_time_4':
        return _t.quick_fix_time_4;
      case 'quick_fix_time_6':
        return _t.quick_fix_time_6;
      case 'quick_fix_time_10':
        return _t.quick_fix_time_10;
      case 'quick_fix_location_desk':
        return _t.quick_fix_location_desk;
      case 'quick_fix_location_chair':
        return _t.quick_fix_location_chair;
      case 'quick_fix_location_standing':
        return _t.quick_fix_location_standing;
      case 'quick_fix_location_floor':
        return _t.quick_fix_location_floor;
      case 'quick_fix_location_bedside':
        return _t.quick_fix_location_bedside;
      case 'quick_fix_energy_low':
        return _t.quick_fix_energy_low;
      case 'quick_fix_energy_medium':
        return _t.quick_fix_energy_medium;
      case 'quick_fix_energy_high':
        return _t.quick_fix_energy_high;
      case 'quick_fix_mode_dad':
        return _t.quick_fix_mode_dad;
      case 'quick_fix_mode_night':
        return _t.quick_fix_mode_night;
      case 'quick_fix_mode_focus':
        return _t.quick_fix_mode_focus;
      case 'quick_fix_mode_pain_relief':
        return _t.quick_fix_mode_pain_relief;
      case 'player_pre_state_title':
        return _t.player_pre_state_title;
      case 'player_pre_state_subtitle':
        return _t.player_pre_state_subtitle;
      case 'player_pre_state_energy_title':
        return _t.player_pre_state_energy_title;
      case 'player_pre_state_stress_title':
        return _t.player_pre_state_stress_title;
      case 'player_pre_state_focus_title':
        return _t.player_pre_state_focus_title;
      case 'player_pre_state_intent_title':
        return _t.player_pre_state_intent_title;
      case 'player_pre_state_pain_areas_title':
        return _t.player_pre_state_pain_areas_title;
      case 'player_pre_state_skip':
        return _t.player_pre_state_skip;
      case 'player_pre_state_start_cta':
        return _t.player_pre_state_start_cta;

      case 'player_feedback_title':
        return _t.player_feedback_title;
      case 'player_feedback_abandoned_title':
        return _t.player_feedback_abandoned_title;
      case 'player_feedback_summary_title':
        return _t.player_feedback_summary_title;
      case 'player_feedback_abandoned_summary_title':
        return _t.player_feedback_abandoned_summary_title;
      case 'player_feedback_helped_title':
        return _t.player_feedback_helped_title;
      case 'player_feedback_tension_title':
        return _t.player_feedback_tension_title;
      case 'player_feedback_pain_title':
        return _t.player_feedback_pain_title;
      case 'player_feedback_energy_title':
        return _t.player_feedback_energy_title;
      case 'player_feedback_fit_title':
        return _t.player_feedback_fit_title;
      case 'player_feedback_repeat_title':
        return _t.player_feedback_repeat_title;
      case 'player_feedback_yes':
        return _t.player_feedback_yes;
      case 'player_feedback_no':
        return _t.player_feedback_no;
      case 'player_feedback_repeat_yes':
        return _t.player_feedback_repeat_yes;
      case 'player_feedback_repeat_no':
        return _t.player_feedback_repeat_no;
      case 'player_feedback_submit':
        return _t.player_feedback_submit;
      case 'player_feedback_close':
        return _t.player_feedback_close;
      // Dashboard
      case 'dashboard_title':
        return _t.dashboard_title;
      case 'dashboard_error_title':
        return _t.dashboard_error_title;
      case 'dashboard_error_body':
        return _t.dashboard_error_body;
      case 'dashboard_error_retry':
        return _t.dashboard_error_retry;
      case 'dashboard_empty_title':
        return _t.dashboard_empty_title;
      case 'dashboard_empty_body':
        return _t.dashboard_empty_body;
      case 'dashboard_empty_refresh':
        return _t.dashboard_empty_refresh;

      case 'dashboard_hero_overline':
        return _t.dashboard_hero_overline;
      case 'dashboard_hero_title':
        return _t.dashboard_hero_title;
      case 'dashboard_hero_body':
        return _t.dashboard_hero_body;
      case 'dashboard_hero_body_with_next':
        return _t.dashboard_hero_body_with_next;
      case 'dashboard_hero_start_next':
        return _t.dashboard_hero_start_next;
      case 'dashboard_hero_quick_fix':
        return _t.dashboard_hero_quick_fix;
      case 'dashboard_hero_body_map':
        return _t.dashboard_hero_body_map;

      case 'dashboard_readiness_title':
        return _t.dashboard_readiness_title;
      case 'dashboard_state_energy':
        return _t.dashboard_state_energy;
      case 'dashboard_state_stress':
        return _t.dashboard_state_stress;
      case 'dashboard_state_focus':
        return _t.dashboard_state_focus;
      case 'dashboard_state_unknown':
        return _t.dashboard_state_unknown;

      case 'dashboard_minutes_week':
        return _t.dashboard_minutes_week;
      case 'dashboard_completed_week':
        return _t.dashboard_completed_week;
      case 'dashboard_quickfix_week':
        return _t.dashboard_quickfix_week;

      case 'dashboard_body_intelligence_title':
        return _t.dashboard_body_intelligence_title;
      case 'dashboard_body_intelligence_subtitle':
        return _t.dashboard_body_intelligence_subtitle;
      case 'dashboard_help_rate':
        return _t.dashboard_help_rate;
      case 'dashboard_consistency':
        return _t.dashboard_consistency;
      case 'dashboard_dominant_zone':
        return _t.dashboard_dominant_zone;
      case 'dashboard_zone_unknown':
        return _t.dashboard_zone_unknown;
      case 'dashboard_empty_body_zones':
        return _t.dashboard_empty_body_zones;

      case 'dashboard_trends_title':
        return _t.dashboard_trends_title;
      case 'dashboard_trends_subtitle':
        return _t.dashboard_trends_subtitle;
      case 'dashboard_chart_minutes_title':
        return _t.dashboard_chart_minutes_title;
      case 'dashboard_chart_relief_title':
        return _t.dashboard_chart_relief_title;

      case 'dashboard_heatmap_title':
        return _t.dashboard_heatmap_title;
      case 'dashboard_heatmap_subtitle':
        return _t.dashboard_heatmap_subtitle;

      case 'dashboard_recent_runs_title':
        return _t.dashboard_recent_runs_title;
      case 'dashboard_recent_runs_subtitle':
        return _t.dashboard_recent_runs_subtitle;
      case 'dashboard_empty_recent_runs':
        return _t.dashboard_empty_recent_runs;

      case 'dashboard_body_map_cta_title':
        return _t.dashboard_body_map_cta_title;
      case 'dashboard_body_map_cta_body':
        return _t.dashboard_body_map_cta_body;
      case 'dashboard_open_body_map':
        return _t.dashboard_open_body_map;

      case 'dashboard_next_session_reason_quick_fix':
        return _t.dashboard_next_session_reason_quick_fix;
      case 'dashboard_next_session_reason_resume':
        return _t.dashboard_next_session_reason_resume;
      case 'common_level_low':
        return _t.common_level_low;
      case 'common_level_medium':
        return _t.common_level_medium;
      case 'common_level_high':
        return _t.common_level_high;

      case 'common_delta_worse':
        return _t.common_delta_worse;
      case 'common_delta_same':
        return _t.common_delta_same;
      case 'common_delta_better':
        return _t.common_delta_better;

      case 'common_fit_poor':
        return _t.common_fit_poor;
      case 'common_fit_okay':
        return _t.common_fit_okay;
      case 'common_fit_great':
        return _t.common_fit_great;

      case 'intent_relief':
        return _t.intent_relief;
      case 'intent_reset':
        return _t.intent_reset;
      case 'intent_focus':
        return _t.intent_focus;
      case 'intent_unwind':
        return _t.intent_unwind;

      case 'pain_neck':
        return _t.pain_neck;
      case 'pain_shoulders':
        return _t.pain_shoulders;
      case 'pain_upper_back':
        return _t.pain_upper_back;
      case 'pain_lower_back':
        return _t.pain_lower_back;
      case 'pain_wrists':
        return _t.pain_wrists;
      // Settings / language
      case 'settings_language_sheet_title':
        return _t.settings_language_sheet_title;
      case 'settings_language_sheet_subtitle':
        return _t.settings_language_sheet_subtitle;
      case 'settings_language_english':
        return _t.settings_language_english;
      case 'settings_language_german':
        return _t.settings_language_german;

      case 'update_later_cta':
        return _t.update_later_cta;
      case 'update_now_cta':
        return _t.update_now_cta;
      case 'notification_permission_prompt_title':
        return _t.notification_permission_prompt_title;
      case 'notification_permission_prompt_body':
        return _t.notification_permission_prompt_body;
      case 'common_not_now':
        return _t.common_not_now;
      case 'notification_enable_cta':
        return _t.notification_enable_cta;
      case 'guide_skip_cta':
        return _t.guide_skip_cta;
      case 'guide_got_it_cta':
        return _t.guide_got_it_cta;
      case 'guide_next_cta':
        return _t.guide_next_cta;
      case 'startup_error_body':
        return _t.startup_error_body;
      case 'startup_error_retry_cta':
        return _t.startup_error_retry_cta;
      case 'nav_training':
        return _t.nav_training;
      case 'nav_programs':
        return _t.nav_programs;
      case 'notification_center_title':
        return _t.notification_center_title;
      case 'notification_center_refresh':
        return _t.notification_center_refresh;
      case 'notification_center_mark_all_read':
        return _t.notification_center_mark_all_read;
      case 'notification_center_error_title':
        return _t.notification_center_error_title;
      case 'notification_center_empty_title':
        return _t.notification_center_empty_title;
      case 'notification_center_empty_body':
        return _t.notification_center_empty_body;
      case 'notification_center_header_title':
        return _t.notification_center_header_title;
      case 'notification_center_status_upcoming':
        return _t.notification_center_status_upcoming;
      case 'notification_center_status_opened':
        return _t.notification_center_status_opened;
      case 'notification_center_status_new':
        return _t.notification_center_status_new;
      case 'notification_center_status_scheduled':
        return _t.notification_center_status_scheduled;
      case 'quick_fix_page_step_hint':
        return _t.quick_fix_page_step_hint;
      case 'guide_quick_fix_body_title':
        return _t.guide_quick_fix_body_title;
      case 'guide_quick_fix_body_body':
        return _t.guide_quick_fix_body_body;
      case 'guide_quick_fix_filters_title':
        return _t.guide_quick_fix_filters_title;
      case 'guide_quick_fix_filters_body':
        return _t.guide_quick_fix_filters_body;
      case 'guide_quick_fix_match_title':
        return _t.guide_quick_fix_match_title;
      case 'guide_quick_fix_match_body':
        return _t.guide_quick_fix_match_body;
      case 'quick_fix_match_session_cta':
        return _t.quick_fix_match_session_cta;
      case 'quick_fix_selected_target_empty':
        return _t.quick_fix_selected_target_empty;
      case 'quick_fix_matched_title':
        return _t.quick_fix_matched_title;
      case 'quick_fix_matching_title':
        return _t.quick_fix_matching_title;
      case 'quick_fix_selected_count_suffix':
        return _t.quick_fix_selected_count_suffix;
      case 'quick_fix_equipment_title':
        return _t.quick_fix_equipment_title;
      case 'common_apply':
        return _t.common_apply;
      case 'quick_fix_body_map_hint_step':
        return _t.quick_fix_body_map_hint_step;
      case 'body_map_front':
        return _t.body_map_front;
      case 'body_map_back':
        return _t.body_map_back;
      case 'quick_fix_recommended_badge':
        return _t.quick_fix_recommended_badge;
      case 'quick_fix_start_session':
        return _t.quick_fix_start_session;
      case 'quick_fix_alternatives_title':
        return _t.quick_fix_alternatives_title;
      case 'quick_fix_none_selected':
        return _t.quick_fix_none_selected;
      case 'common_close':
        return _t.common_close;
      case 'common_cancel':
        return _t.common_cancel;
      case 'profile_title':
        return _t.profile_title;
      case 'profile_settings_tooltip':
        return _t.profile_settings_tooltip;
      case 'profile_primary_continue':
        return _t.profile_primary_continue;
      case 'profile_primary_open_sessions':
        return _t.profile_primary_open_sessions;
      case 'profile_sign_in_cta':
        return _t.profile_sign_in_cta;
      case 'profile_sync_connected':
        return _t.profile_sync_connected;
      case 'profile_sync_local':
        return _t.profile_sync_local;
      case 'profile_guest_subtitle':
        return _t.profile_guest_subtitle;
      case 'profile_metric_saved':
        return _t.profile_metric_saved;
      case 'profile_metric_runs':
        return _t.profile_metric_runs;
      case 'profile_metric_status':
        return _t.profile_metric_status;
      case 'profile_action_premium':
        return _t.profile_action_premium;
      case 'profile_action_premium_subtitle_large':
        return _t.profile_action_premium_subtitle_large;
      case 'profile_action_saved_short':
        return _t.profile_action_saved_short;
      case 'profile_action_saved_subtitle_short':
        return _t.profile_action_saved_subtitle_short;
      case 'session_history_title_compact':
        return _t.session_history_title_compact;
      case 'profile_action_history_subtitle_short':
        return _t.profile_action_history_subtitle_short;
      case 'profile_action_programs':
        return _t.profile_action_programs;
      case 'profile_action_programs_subtitle_short':
        return _t.profile_action_programs_subtitle_short;
      case 'profile_account_section_title':
        return _t.profile_account_section_title;
      case 'profile_account_section_subtitle':
        return _t.profile_account_section_subtitle;
      case 'profile_edit_title':
        return _t.profile_edit_title;
      case 'profile_edit_subtitle':
        return _t.profile_edit_subtitle;
      case 'profile_action_settings':
        return _t.profile_action_settings;
      case 'profile_action_settings_subtitle_compact':
        return _t.profile_action_settings_subtitle_compact;
      case 'profile_sign_out_cta':
        return _t.profile_sign_out_cta;
      case 'profile_create_account_cta':
        return _t.profile_create_account_cta;
      case 'profile_sign_out_subtitle':
        return _t.profile_sign_out_subtitle;
      case 'profile_create_account_subtitle':
        return _t.profile_create_account_subtitle;
      case 'profile_danger_zone_title':
        return _t.profile_danger_zone_title;
      case 'profile_danger_zone_subtitle':
        return _t.profile_danger_zone_subtitle;
      case 'settings_reset_app_data_title':
        return _t.settings_reset_app_data_title;
      case 'settings_reset_app_data_loading':
        return _t.settings_reset_app_data_loading;
      case 'settings_reset_app_data_subtitle_short':
        return _t.settings_reset_app_data_subtitle_short;
      case 'settings_delete_account_section_title':
        return _t.settings_delete_account_section_title;
      case 'settings_delete_account_loading':
        return _t.settings_delete_account_loading;
      case 'settings_delete_account_section_subtitle':
        return _t.settings_delete_account_section_subtitle;
      case 'settings_reset_app_data_dialog_title':
        return _t.settings_reset_app_data_dialog_title;
      case 'settings_reset_app_data_dialog_body':
        return _t.settings_reset_app_data_dialog_body;
      case 'settings_reset_app_data_confirm':
        return _t.settings_reset_app_data_confirm;
      case 'settings_reset_app_data_sign_in_required':
        return _t.settings_reset_app_data_sign_in_required;
      case 'settings_reset_app_data_success':
        return _t.settings_reset_app_data_success;
      case 'settings_reset_app_data_failed':
        return _t.settings_reset_app_data_failed;
      case 'settings_delete_account_dialog_title':
        return _t.settings_delete_account_dialog_title;
      case 'settings_delete_account_dialog_body':
        return _t.settings_delete_account_dialog_body;
      case 'settings_delete_account_confirm':
        return _t.settings_delete_account_confirm;
      case 'settings_delete_account_sign_in_required':
        return _t.settings_delete_account_sign_in_required;
      case 'settings_delete_account_success':
        return _t.settings_delete_account_success;
      case 'settings_delete_account_failed':
        return _t.settings_delete_account_failed;
      case 'profile_core_access_badge':
        return _t.profile_core_access_badge;
      case 'profile_core_access_cta_short':
        return _t.profile_core_access_cta_short;
      case 'profile_edit_saved':
        return _t.profile_edit_saved;
      case 'profile_avatar_updated':
        return _t.profile_avatar_updated;
      case 'profile_edit_error':
        return _t.profile_edit_error;
      case 'profile_change_photo_cta':
        return _t.profile_change_photo_cta;
      case 'profile_remove_photo_cta':
        return _t.profile_remove_photo_cta;
      case 'profile_display_name_label':
        return _t.profile_display_name_label;
      case 'profile_save_cta':
        return _t.profile_save_cta;
      case 'settings_title':
        return _t.settings_title;
      case 'settings_hero_title':
        return _t.settings_hero_title;
      case 'settings_hero_subtitle':
        return _t.settings_hero_subtitle;
      case 'settings_preferences_compact_title':
        return _t.settings_preferences_compact_title;
      case 'settings_preferences_compact_subtitle':
        return _t.settings_preferences_compact_subtitle;
      case 'settings_language_section_title':
        return _t.settings_language_section_title;
      case 'settings_appearance_section_title':
        return _t.settings_appearance_section_title;
      case 'notification_settings_title_compact':
        return _t.notification_settings_title_compact;
      case 'notification_settings_inline_subtitle':
        return _t.notification_settings_inline_subtitle;
      case 'notification_settings_error':
        return _t.notification_settings_error;
      case 'notification_settings_guest_hint':
        return _t.notification_settings_guest_hint;
      case 'notification_settings_enable_title':
        return _t.notification_settings_enable_title;
      case 'notification_settings_enabled_short':
        return _t.notification_settings_enabled_short;
      case 'notification_settings_disabled_short':
        return _t.notification_settings_disabled_short;
      case 'notification_permission_denied':
        return _t.notification_permission_denied;
      case 'notification_settings_time_title':
        return _t.notification_settings_time_title;
      case 'notification_settings_time_error':
        return _t.notification_settings_time_error;
      case 'notification_settings_haptics_title':
        return _t.notification_settings_haptics_title;
      case 'notification_settings_haptics_short':
        return _t.notification_settings_haptics_short;
      case 'notification_time_morning':
        return _t.notification_time_morning;
      case 'notification_time_afternoon':
        return _t.notification_time_afternoon;
      case 'notification_time_evening':
        return _t.notification_time_evening;
      case 'settings_support_legal_title':
        return _t.settings_support_legal_title;
      case 'settings_support_legal_subtitle':
        return _t.settings_support_legal_subtitle;
      case 'settings_contact_email_label':
        return _t.settings_contact_email_label;
      case 'settings_privacy_policy_title':
        return _t.settings_privacy_policy_title;
      case 'settings_external_link_subtitle':
        return _t.settings_external_link_subtitle;
      case 'settings_terms_title':
        return _t.settings_terms_title;
      case 'settings_account_data_deletion_info_title':
        return _t.settings_account_data_deletion_info_title;
      case 'settings_app_version_loading':
        return _t.settings_app_version_loading;
      case 'settings_app_version_title':
        return _t.settings_app_version_title;
      case 'settings_theme_system_title':
        return _t.settings_theme_system_title;
      case 'settings_theme_system_short':
        return _t.settings_theme_system_short;
      case 'settings_theme_light_title':
        return _t.settings_theme_light_title;
      case 'settings_theme_light_short':
        return _t.settings_theme_light_short;
      case 'settings_theme_dark_title':
        return _t.settings_theme_dark_title;
      case 'settings_theme_dark_short':
        return _t.settings_theme_dark_short;
      case 'settings_preferences_error_short':
        return _t.settings_preferences_error_short;
      case 'settings_preferences_guest_hint':
        return _t.settings_preferences_guest_hint;
      case 'settings_preferences_synced_short':
        return _t.settings_preferences_synced_short;
      case 'settings_link_open_failed':
        return _t.settings_link_open_failed;
      case 'settings_email_open_failed':
        return _t.settings_email_open_failed;
      case 'premium_purchase_cancelled':
        return _t.premium_purchase_cancelled;
      case 'premium_restore_no_purchase_found':
        return _t.premium_restore_no_purchase_found;
      case 'premium_purchase_failed':
        return _t.premium_purchase_failed;
      case 'premium_page_title':
        return _t.premium_page_title;
      case 'premium_status_core_active':
        return _t.premium_status_core_active;
      case 'premium_visual_pill':
        return _t.premium_visual_pill;
      case 'premium_hero_unlocked_title':
        return _t.premium_hero_unlocked_title;
      case 'premium_visual_title_v2':
        return _t.premium_visual_title_v2;
      case 'premium_hero_unlocked_body_v2':
        return _t.premium_hero_unlocked_body_v2;
      case 'premium_visual_body_v2':
        return _t.premium_visual_body_v2;
      case 'premium_programs_badge':
        return _t.premium_programs_badge;
      case 'premium_value_programs_title':
        return _t.premium_value_programs_title;
      case 'premium_value_sessions_title':
        return _t.premium_value_sessions_title;
      case 'premium_value_quick_fix_title':
        return _t.premium_value_quick_fix_title;
      case 'premium_value_insights_title':
        return _t.premium_value_insights_title;
      case 'premium_value_active_title':
        return _t.premium_value_active_title;
      case 'premium_value_title':
        return _t.premium_value_title;
      case 'premium_value_subtitle_v2':
        return _t.premium_value_subtitle_v2;
      case 'premium_product_price_unavailable':
        return _t.premium_product_price_unavailable;
      case 'premium_plan_unlocked_subtitle':
        return _t.premium_plan_unlocked_subtitle;
      case 'premium_plan_subtitle_v2':
        return _t.premium_plan_subtitle_v2;
      case 'premium_sign_in_hint':
        return _t.premium_sign_in_hint;
      case 'premium_plan_title':
        return _t.premium_plan_title;
      case 'premium_plan_lifetime_badge':
        return _t.premium_plan_lifetime_badge;
      case 'premium_signal_lifetime':
        return _t.premium_signal_lifetime;
      case 'premium_signal_restore':
        return _t.premium_signal_restore;
      case 'premium_signal_no_subscription':
        return _t.premium_signal_no_subscription;
      case 'premium_already_unlocked_cta':
        return _t.premium_already_unlocked_cta;
      case 'premium_restore_cta':
        return _t.premium_restore_cta;
      case 'premium_loading_products_cta':
        return _t.premium_loading_products_cta;
      case 'premium_purchasing_cta':
        return _t.premium_purchasing_cta;
      case 'premium_verifying_cta':
        return _t.premium_verifying_cta;
      case 'premium_product_unavailable_cta':
        return _t.premium_product_unavailable_cta;
      case 'access_unlock_core_cta':
        return _t.access_unlock_core_cta;
      case 'premium_error_purchase_linked_to_another_account':
        return _t.premium_error_purchase_linked_to_another_account;
      case 'premium_error_not_authenticated':
        return _t.premium_error_not_authenticated;
      case 'premium_error_missing_purchase_payload':
        return _t.premium_error_missing_purchase_payload;
      case 'premium_error_product_mismatch':
        return _t.premium_error_product_mismatch;
      case 'premium_error_purchase_not_completed':
        return _t.premium_error_purchase_not_completed;
      case 'premium_error_unsupported_platform':
        return _t.premium_error_unsupported_platform;
      case 'premium_error_store_unavailable':
        return _t.premium_error_store_unavailable;
      case 'premium_error_product_unavailable':
        return _t.premium_error_product_unavailable;
      case 'premium_error_purchase_failed':
        return _t.premium_error_purchase_failed;
      case 'premium_error_verification_failed':
        return _t.premium_error_verification_failed;
      case 'premium_billing_error_body':
        return _t.premium_billing_error_body;
      case 'logs_page_title':
        return _t.logs_page_title;
      case 'logs_locked_title':
        return _t.logs_locked_title;
      case 'logs_locked_message':
        return _t.logs_locked_message;
      case 'logs_hero_title':
        return _t.logs_hero_title;
      case 'logs_hero_body_short':
        return _t.logs_hero_body_short;
      case 'logs_positive_label':
        return _t.logs_positive_label;
      case 'logs_warning_label':
        return _t.logs_warning_label;
      case 'logs_neutral_label':
        return _t.logs_neutral_label;
      case 'logs_recent_title':
        return _t.logs_recent_title;
      case 'insights_logs_empty':
        return _t.insights_logs_empty;
      case 'logs_error_title':
        return _t.logs_error_title;
      case 'insights_title':
        return _t.insights_title;
      case 'guide_insights_signal_title':
        return _t.guide_insights_signal_title;
      case 'guide_insights_signal_body':
        return _t.guide_insights_signal_body;
      case 'guide_insights_metrics_title':
        return _t.guide_insights_metrics_title;
      case 'guide_insights_metrics_body':
        return _t.guide_insights_metrics_body;
      case 'guide_insights_patterns_title':
        return _t.guide_insights_patterns_title;
      case 'guide_insights_patterns_body':
        return _t.guide_insights_patterns_body;
      case 'insights_journey_intelligence_title':
        return _t.insights_journey_intelligence_title;
      case 'insights_journey_intelligence_empty_title':
        return _t.insights_journey_intelligence_empty_title;
      case 'insights_journey_intelligence_body':
        return _t.insights_journey_intelligence_body;
      case 'insights_journey_intelligence_empty_body':
        return _t.insights_journey_intelligence_empty_body;
      case 'insights_focus_completion_title':
        return _t.insights_focus_completion_title;
      case 'insights_focus_helpful_title':
        return _t.insights_focus_helpful_title;
      case 'insights_summary_consistency_title':
        return _t.insights_summary_consistency_title;
      case 'insights_locked_preview_title':
        return _t.insights_locked_preview_title;
      case 'insights_locked_preview_body':
        return _t.insights_locked_preview_body;
      case 'insights_range_7_short':
        return _t.insights_range_7_short;
      case 'insights_range_14_short':
        return _t.insights_range_14_short;
      case 'insights_range_28_short':
        return _t.insights_range_28_short;
      case 'insights_intro_title':
        return _t.insights_intro_title;
      case 'insights_intro_body_short':
        return _t.insights_intro_body_short;
      case 'insights_focus_zone_title':
        return _t.insights_focus_zone_title;
      case 'insights_range_compact':
        return _t.insights_range_compact;
      case 'insights_streak_compact':
        return _t.insights_streak_compact;
      case 'insights_summary_minutes_title':
        return _t.insights_summary_minutes_title;
      case 'insights_summary_minutes_subtitle':
        return _t.insights_summary_minutes_subtitle;
      case 'insights_active_days_title':
        return _t.insights_active_days_title;
      case 'insights_helpful_title':
        return _t.insights_helpful_title;
      case 'insights_helpful_subtitle':
        return _t.insights_helpful_subtitle;
      case 'insights_relief_title':
        return _t.insights_relief_title;
      case 'insights_relief_subtitle':
        return _t.insights_relief_subtitle;
      case 'insights_recovery_minutes_title':
        return _t.insights_recovery_minutes_title;
      case 'insights_recovery_minutes_subtitle_short':
        return _t.insights_recovery_minutes_subtitle_short;
      case 'insights_chart_peak':
        return _t.insights_chart_peak;
      case 'insights_chart_average':
        return _t.insights_chart_average;
      case 'insights_rhythm_title':
        return _t.insights_rhythm_title;
      case 'insights_rhythm_subtitle_short':
        return _t.insights_rhythm_subtitle_short;
      case 'insights_rhythm_active_days':
        return _t.insights_rhythm_active_days;
      case 'insights_rhythm_minutes':
        return _t.insights_rhythm_minutes;
      case 'insights_patterns_title':
        return _t.insights_patterns_title;
      case 'insights_patterns_subtitle_short':
        return _t.insights_patterns_subtitle_short;
      case 'insights_logs_action':
        return _t.insights_logs_action;
      case 'insights_error_title':
        return _t.insights_error_title;
      case 'pain_forearms':
        return _t.pain_forearms;
      case 'pain_hands':
        return _t.pain_hands;
      case 'pain_hips_glutes':
        return _t.pain_hips_glutes;
      case 'pain_eyes':
        return _t.pain_eyes;
      case 'session_history_locked_title':
        return _t.session_history_locked_title;
      case 'session_history_locked_message':
        return _t.session_history_locked_message;
      case 'player_access_locked_title':
        return _t.player_access_locked_title;
      case 'player_access_locked_message':
        return _t.player_access_locked_message;
      case 'guide_player_header_title':
        return _t.guide_player_header_title;
      case 'guide_player_header_body':
        return _t.guide_player_header_body;
      case 'guide_player_video_title':
        return _t.guide_player_video_title;
      case 'guide_player_video_body':
        return _t.guide_player_video_body;
      case 'guide_player_timer_title':
        return _t.guide_player_timer_title;
      case 'guide_player_timer_body':
        return _t.guide_player_timer_body;
      case 'guide_player_instruction_title':
        return _t.guide_player_instruction_title;
      case 'guide_player_instruction_body':
        return _t.guide_player_instruction_body;
      case 'guide_player_controls_title':
        return _t.guide_player_controls_title;
      case 'guide_player_controls_body':
        return _t.guide_player_controls_body;
      case 'guide_done_cta':
        return _t.guide_done_cta;
      case 'movement_pattern_setup':
        return _t.movement_pattern_setup;
      case 'movement_pattern_assessment':
        return _t.movement_pattern_assessment;
      case 'movement_pattern_mobility':
        return _t.movement_pattern_mobility;
      case 'movement_pattern_stretch':
        return _t.movement_pattern_stretch;
      case 'movement_pattern_release':
        return _t.movement_pattern_release;
      case 'movement_pattern_activation':
        return _t.movement_pattern_activation;
      case 'movement_pattern_strength':
        return _t.movement_pattern_strength;
      case 'movement_pattern_endurance':
        return _t.movement_pattern_endurance;
      case 'movement_pattern_posture':
        return _t.movement_pattern_posture;
      case 'movement_pattern_breathing':
        return _t.movement_pattern_breathing;
      case 'movement_pattern_cooldown':
        return _t.movement_pattern_cooldown;
      case 'movement_pattern_habit':
        return _t.movement_pattern_habit;
      case 'continuity_preview_cta':
        return _t.continuity_preview_cta;
      case 'player_pre_state_subtitle_compact':
        return _t.player_pre_state_subtitle_compact;
      case 'player_feedback_subtitle_compact':
        return _t.player_feedback_subtitle_compact;
      case 'player_media_expand_tooltip':
        return _t.player_media_expand_tooltip;
      case 'player_media_unmute_tooltip':
        return _t.player_media_unmute_tooltip;
      case 'player_media_mute_tooltip':
        return _t.player_media_mute_tooltip;
      case 'guide_dashboard_topbar_title':
        return _t.guide_dashboard_topbar_title;
      case 'guide_dashboard_topbar_body':
        return _t.guide_dashboard_topbar_body;
      case 'guide_dashboard_home_title':
        return _t.guide_dashboard_home_title;
      case 'guide_dashboard_home_body':
        return _t.guide_dashboard_home_body;
      case 'guide_dashboard_bottom_nav_title':
        return _t.guide_dashboard_bottom_nav_title;
      case 'guide_dashboard_bottom_nav_body':
        return _t.guide_dashboard_bottom_nav_body;
      case 'dashboard_greeting':
        return _t.dashboard_greeting;
      case 'dashboard_new_quick_fix_title':
        return _t.dashboard_new_quick_fix_title;
      case 'dashboard_new_quick_fix_body':
        return _t.dashboard_new_quick_fix_body;
      case 'dashboard_quick_fix_title':
        return _t.dashboard_quick_fix_title;
      case 'dashboard_for_you_now':
        return _t.dashboard_for_you_now;
      case 'session_duration_unit_min':
        return _t.session_duration_unit_min;
      case 'dashboard_continue_session':
        return _t.dashboard_continue_session;
      case 'dashboard_start_session':
        return _t.dashboard_start_session;
      case 'dashboard_active_program_title':
        return _t.dashboard_active_program_title;
      case 'dashboard_continue_program':
        return _t.dashboard_continue_program;
      case 'dashboard_day_label':
        return _t.dashboard_day_label;
      case 'profile_action_notifications':
        return _t.profile_action_notifications;
      case 'dashboard_command_title':
        return _t.dashboard_command_title;
      case 'dashboard_command_active_body':
        return _t.dashboard_command_active_body;
      case 'dashboard_command_empty_body':
        return _t.dashboard_command_empty_body;
      case 'dashboard_readiness_label':
        return _t.dashboard_readiness_label;
      case 'dashboard_helpful_label':
        return _t.dashboard_helpful_label;
      case 'dashboard_rhythm_label':
        return _t.dashboard_rhythm_label;
      case 'dashboard_snapshot_error_title':
        return _t.dashboard_snapshot_error_title;
      case 'dashboard_weekly_minutes_label':
        return _t.dashboard_weekly_minutes_label;
      case 'dashboard_completed_week_label':
        return _t.dashboard_completed_week_label;
      case 'dashboard_run_completed':
        return _t.dashboard_run_completed;
      case 'dashboard_run_abandoned':
        return _t.dashboard_run_abandoned;
      case 'dashboard_run_started':
        return _t.dashboard_run_started;
      case 'dashboard_programs_active_title':
        return _t.dashboard_programs_active_title;
      case 'dashboard_programs_title':
        return _t.dashboard_programs_title;
      case 'common_view_all':
        return _t.common_view_all;
      case 'dashboard_program_discovery_pill_guided':
        return _t.dashboard_program_discovery_pill_guided;
      case 'dashboard_program_discovery_title':
        return _t.dashboard_program_discovery_title;
      case 'dashboard_program_discovery_cta':
        return _t.dashboard_program_discovery_cta;
      case 'program_active_badge':
        return _t.program_active_badge;
      case 'dashboard_programs_continue_cta':
        return _t.dashboard_programs_continue_cta;
      case 'program_day_unit':
        return _t.program_day_unit;
      case 'program_start_cta':
        return _t.program_start_cta;
      case 'dashboard_saved_title':
        return _t.dashboard_saved_title;
      case 'dashboard_recommended_title':
        return _t.dashboard_recommended_title;
      case 'dashboard_see_all':
        return _t.dashboard_see_all;
      case 'sessions_title':
        return _t.sessions_title;
      case 'dashboard_momentum_title':
        return _t.dashboard_momentum_title;
      case 'dashboard_program_days_label':
        return _t.dashboard_program_days_label;
      case 'dashboard_streak_label':
        return _t.dashboard_streak_label;
      case 'dashboard_saved_count_label':
        return _t.dashboard_saved_count_label;
      case 'dashboard_body_focus_title':
        return _t.dashboard_body_focus_title;
      case 'dashboard_body_focus_body':
        return _t.dashboard_body_focus_body;
      case 'dashboard_premium_title':
        return _t.dashboard_premium_title;
      case 'dashboard_premium_body':
        return _t.dashboard_premium_body;
      case 'dashboard_premium_cta_short':
        return _t.dashboard_premium_cta_short;
      case 'programs_title':
        return _t.programs_title;
      case 'programs_browse_all_title':
        return _t.programs_browse_all_title;
      case 'programs_more_journeys_title':
        return _t.programs_more_journeys_title;
      case 'programs_section_subtitle':
        return _t.programs_section_subtitle;
      case 'programs_header_active':
        return _t.programs_header_active;
      case 'programs_header_new':
        return _t.programs_header_new;
      case 'programs_header_body':
        return _t.programs_header_body;
      case 'program_premium_badge':
        return _t.program_premium_badge;
      case 'programs_error_title':
        return _t.programs_error_title;
      case 'programs_error_body':
        return _t.programs_error_body;
      case 'programs_empty_title':
        return _t.programs_empty_title;
      case 'programs_empty_body':
        return _t.programs_empty_body;
      case 'common_refresh':
        return _t.common_refresh;
      case 'program_detail_title':
        return _t.program_detail_title;
      case 'program_switch_title':
        return _t.program_switch_title;
      case 'program_start_title':
        return _t.program_start_title;
      case 'program_switch_body':
        return _t.program_switch_body;
      case 'program_start_body':
        return _t.program_start_body;
      case 'program_switch_cta':
        return _t.program_switch_cta;
      case 'program_begin_cta':
        return _t.program_begin_cta;
      case 'program_phase_recovery':
        return _t.program_phase_recovery;
      case 'program_completed_label':
        return _t.program_completed_label;
      case 'program_continue_recovery_cta':
        return _t.program_continue_recovery_cta;
      case 'program_about_journey_label':
        return _t.program_about_journey_label;
      case 'program_path_label':
        return _t.program_path_label;
      case 'program_unlocked_label':
        return _t.program_unlocked_label;
      case 'program_no_days_title':
        return _t.program_no_days_title;
      case 'program_view_full_plan_title':
        return _t.program_view_full_plan_title;
      case 'program_sequential_hint':
        return _t.program_sequential_hint;
      case 'program_day_missing_session':
        return _t.program_day_missing_session;
      case 'program_phase_start_label':
        return _t.program_phase_start_label;
      case 'program_phase_end_label':
        return _t.program_phase_end_label;
      case 'program_assessment_label':
        return _t.program_assessment_label;
      case 'program_repeat_label':
        return _t.program_repeat_label;
      case 'program_today_badge':
        return _t.program_today_badge;
      case 'program_expected_label':
        return _t.program_expected_label;
      case 'program_detail_error_title':
        return _t.program_detail_error_title;
      case 'program_detail_error_body':
        return _t.program_detail_error_body;
      case 'program_progress_sync_warning':
        return _t.program_progress_sync_warning;
      case 'program_not_found_title':
        return _t.program_not_found_title;
      case 'program_not_found_body':
        return _t.program_not_found_body;
      case 'access_core_badge':
        return _t.access_core_badge;
      case 'sessions_load_error_title':
        return _t.sessions_load_error_title;
      case 'guide_training_sessions_title':
        return _t.guide_training_sessions_title;
      case 'guide_training_sessions_body':
        return _t.guide_training_sessions_body;
      case 'guide_training_filter_title':
        return _t.guide_training_filter_title;
      case 'guide_training_filter_body':
        return _t.guide_training_filter_body;
      case 'common_clear':
        return _t.common_clear;
      case 'training_programs_title':
        return _t.training_programs_title;
      case 'training_programs_subtitle':
        return _t.training_programs_subtitle;
      case 'training_sessions_section_title':
        return _t.training_sessions_section_title;
      case 'training_sessions_section_subtitle':
        return _t.training_sessions_section_subtitle;
      case 'sessions_search_hint_compact':
        return _t.sessions_search_hint_compact;
      case 'sessions_category_lower_back_hips':
        return _t.sessions_category_lower_back_hips;
      case 'sessions_category_wrists_hands':
        return _t.sessions_category_wrists_hands;
      case 'sessions_sort_shortest':
        return _t.sessions_sort_shortest;
      case 'sessions_sort_alpha':
        return _t.sessions_sort_alpha;
      case 'sessions_sort_short_recommended':
        return _t.sessions_sort_short_recommended;
      case 'sessions_sort_short_shortest':
        return _t.sessions_sort_short_shortest;
      case 'sessions_sort_short_az':
        return _t.sessions_sort_short_az;
      case 'session_detail_nav_title':
        return _t.session_detail_nav_title;
      case 'premium_title':
        return _t.premium_title;
      case 'session_detail_label':
        return _t.session_detail_label;
      case 'session_detail_body_target_general':
        return _t.session_detail_body_target_general;
      case 'session_detail_body_targets_title':
        return _t.session_detail_body_targets_title;
      case 'session_detail_equipment_none':
        return _t.session_detail_equipment_none;
      case 'session_detail_steps_title_compact':
        return _t.session_detail_steps_title_compact;
      case 'session_detail_safety_title':
        return _t.session_detail_safety_title;
      case 'session_detail_safety_compact_subtitle':
        return _t.session_detail_safety_compact_subtitle;
      case 'session_detail_warning_title':
        return _t.session_detail_warning_title;
      case 'session_detail_avoid_title':
        return _t.session_detail_avoid_title;
      case 'session_detail_error_title':
        return _t.session_detail_error_title;
      case 'session_detail_error_subtitle':
        return _t.session_detail_error_subtitle;
      case 'equipment_chair':
        return _t.equipment_chair;
      case 'equipment_desk':
        return _t.equipment_desk;
      case 'equipment_wall':
        return _t.equipment_wall;
      case 'equipment_towel':
        return _t.equipment_towel;
      case 'equipment_small_cushion':
        return _t.equipment_small_cushion;
      case 'equipment_lumbar_roll':
        return _t.equipment_lumbar_roll;
      case 'equipment_mini_band':
        return _t.equipment_mini_band;
      case 'equipment_long_band':
        return _t.equipment_long_band;
      case 'equipment_massage_ball':
        return _t.equipment_massage_ball;
      case 'equipment_soft_ball':
        return _t.equipment_soft_ball;
      case 'equipment_water_bottle':
        return _t.equipment_water_bottle;
      case 'equipment_dowel':
        return _t.equipment_dowel;
      case 'equipment_yoga_mat':
        return _t.equipment_yoga_mat;
      case 'equipment_foam_roller':
        return _t.equipment_foam_roller;
      case 'session_level_free_starter':
        return _t.session_level_free_starter;
      case 'session_level_therapy':
        return _t.session_level_therapy;
      case 'session_level_advanced_therapy':
        return _t.session_level_advanced_therapy;
      case 'session_level_flagship':
        return _t.session_level_flagship;
      case 'saved_sessions_locked_title':
        return _t.saved_sessions_locked_title;
      case 'saved_sessions_locked_message':
        return _t.saved_sessions_locked_message;
      case 'auth_callback_title':
        return _t.auth_callback_title;
      case 'auth_callback_subtitle':
        return _t.auth_callback_subtitle;
      case 'auth_terms_required':
        return _t.auth_terms_required;
      case 'auth_google_not_started':
        return _t.auth_google_not_started;
      case 'auth_google_unknown_error':
        return _t.auth_google_unknown_error;
      case 'auth_apple_coming_soon':
        return _t.auth_apple_coming_soon;
      case 'auth_reset_email_required':
        return _t.auth_reset_email_required;
      case 'auth_reset_email_sent':
        return _t.auth_reset_email_sent;
      case 'auth_link_open_failed':
        return _t.auth_link_open_failed;
      case 'auth_invalid_credentials':
        return _t.auth_invalid_credentials;
      case 'auth_email_not_confirmed':
        return _t.auth_email_not_confirmed;
      case 'auth_user_already_registered':
        return _t.auth_user_already_registered;
      case 'auth_or_email_short':
        return _t.auth_or_email_short;
      case 'auth_app_badge':
        return _t.auth_app_badge;
      case 'auth_sign_up_tab_short':
        return _t.auth_sign_up_tab_short;
      case 'auth_google_short':
        return _t.auth_google_short;
      case 'auth_apple_short':
        return _t.auth_apple_short;
      case 'auth_toggle_password_visibility':
        return _t.auth_toggle_password_visibility;
      case 'auth_forgot_password':
        return _t.auth_forgot_password;
      case 'auth_accept_terms_text':
        return _t.auth_accept_terms_text;
      case 'auth_legal_note_sign_in_compact':
        return _t.auth_legal_note_sign_in_compact;
      case 'auth_legal_note_sign_up_compact':
        return _t.auth_legal_note_sign_up_compact;
      case 'auth_privacy_policy_link':
        return _t.auth_privacy_policy_link;
      case 'auth_terms_of_use_link':
        return _t.auth_terms_of_use_link;

      case 'update_available_body':
        return _t.update_available_body;
      case 'quick_fix_equipment_none':
        return _t.quick_fix_equipment_none;
      case 'quick_fix_equipment_towel':
        return _t.quick_fix_equipment_towel;
      case 'quick_fix_equipment_long_band':
        return _t.quick_fix_equipment_long_band;
      case 'quick_fix_equipment_mini_band':
        return _t.quick_fix_equipment_mini_band;
      case 'quick_fix_equipment_foam_roller':
        return _t.quick_fix_equipment_foam_roller;
      case 'quick_fix_equipment_massage_ball':
        return _t.quick_fix_equipment_massage_ball;
      case 'quick_fix_equipment_soft_ball':
        return _t.quick_fix_equipment_soft_ball;
      case 'quick_fix_equipment_water_bottle':
        return _t.quick_fix_equipment_water_bottle;
      case 'quick_fix_equipment_dowel':
        return _t.quick_fix_equipment_dowel;
      case 'quick_fix_problem_forearms':
        return _t.quick_fix_problem_forearms;
      case 'quick_fix_problem_hands':
        return _t.quick_fix_problem_hands;
      case 'quick_fix_problem_hips_glutes':
        return _t.quick_fix_problem_hips_glutes;
      case 'quick_fix_problem_upper_back':
        return _t.quick_fix_problem_upper_back;
      case 'quick_fix_signal_equipment_based':
        return _t.quick_fix_signal_equipment_based;
      case 'player_left':
        return _t.player_left;
      case 'player_more_guidance':
        return _t.player_more_guidance;
      case 'player_voice_on':
        return _t.player_voice_on;
      case 'player_voice_off':
        return _t.player_voice_off;

      case 'program_days_suffix':
        return _t.program_days_suffix;
      case 'program_difficulty_beginner':
        return _t.program_difficulty_beginner;
      case 'program_difficulty_intermediate':
        return _t.program_difficulty_intermediate;
      case 'program_difficulty_advanced':
        return _t.program_difficulty_advanced;
      case 'program_recovery_route':
        return _t.program_recovery_route;
      case 'insights_active_suffix':
        return _t.insights_active_suffix;
      case 'player_reps_suffix':
        return _t.player_reps_suffix;

      default:
        return _translateDynamicFallback(fallback);
    }
  }

  String _translateDynamicFallback(String fallback) {
    if (!_t.localeName.toLowerCase().startsWith('de')) return fallback;

    const exact = <String, String>{
      'Recovery': 'Erholung',
      'Recovery signal needs consistency': 'Das Erholungssignal braucht mehr Regelmäßigkeit',
      'Strong recovery rhythm': 'Starker Erholungsrhythmus',
      'Recovery rhythm is building': 'Der Erholungsrhythmus entwickelt sich',
      'Early recovery signal': 'Frühes Erholungssignal',
      'No recovery score yet': 'Noch kein Erholungswert',
      'Most attention is landing on Neck': 'Der Schwerpunkt liegt derzeit auf dem Nacken',
      'A notable share of runs end early': 'Ein auffälliger Anteil der Sessions endet vorzeitig',
      'Recent feedback trend is positive': 'Der aktuelle Feedback-Trend ist positiv',
      'Recovery route': 'Erholungsweg',
      'Map the Workday': 'Arbeitsalltag erfassen',
      'Build the Support System': 'Stützsystem aufbauen',
      'Control Motion': 'Bewegung kontrollieren',
      'Full Desk Worker Therapy Journey': 'Ganzheitliches Therapieprogramm für Schreibtischarbeit',
      'Neck & Shoulder Therapy Journey': 'Therapieprogramm für Nacken & Schultern',
      '13 missions to calm tension, rebuild support, and transfer control to your workday.': '13 Missionen, um Spannung zu reduzieren, Stabilität aufzubauen und die Kontrolle in den Arbeitsalltag zu übertragen.',
      'A progressive full-body journey for neck, shoulders, hands, spine, and hips — built around real desk demands.': 'Ein schrittweises Ganzkörperprogramm für Nacken, Schultern, Hände, Wirbelsäule und Hüfte – abgestimmt auf den echten Büroalltag.',
      'Create a coordinated, resilient desk-worker system with better movement control, load tolerance, recovery, and self-management.': 'Baue ein koordiniertes und belastbares System für den Büroalltag auf – mit besserer Bewegungskontrolle, Belastbarkeit, Erholung und Selbstmanagement.',
      'Mission 1 — Map Head and Neck Control': 'Mission 1 — Kopf- und Nackenkontrolle erfassen',
      'Mission 2 — Map Hand and Nerve Motion': 'Mission 2 — Hand- und Nervenbewegung erfassen',
      'Mission 3 — Find Your Trunk Support': 'Mission 3 — Rumpfunterstützung finden',
      'Assess hand, finger, and median-nerve motion without provoking symptoms.': 'Beurteile die Bewegung von Hand, Fingern und Medianusnerv, ohne Beschwerden auszulösen.',
      'Assessment': 'Beurteilung',
      'Beginner': 'Einsteiger',
      'No extra equipment': 'Keine zusätzliche Ausrüstung',
      'Towel': 'Handtuch',
      'Resistance band': 'Widerstandsband',
      'Mini band': 'Mini-Band',
      'Foam roller': 'Faszienrolle',
      'Massage ball': 'Massageball',
      'Soft ball': 'Weicher Ball',
      'Water bottle': 'Wasserflasche',
      'Dowel / broomstick': 'Stab / Besenstiel',
      'More guidance': 'Mehr Anleitung',
      'Voice on': 'Stimme an',
      'Voice off': 'Stimme aus',
      'LEFT': 'VERBLEIBEND',
      'How did it feel?': 'Wie hat es sich angefühlt?',
      'Journey complete': 'Programm abgeschlossen',
      'Phase complete': 'Phase abgeschlossen',
      'Mission complete': 'Mission abgeschlossen',
      'You completed the full therapy journey.': 'Du hast das gesamte Therapieprogramm abgeschlossen.',
      'This phase is complete. Your next phase is now ready.': 'Diese Phase ist abgeschlossen. Die nächste Phase ist jetzt bereit.',
      'This mission is now part of your completed path.': 'Diese Mission ist jetzt Teil deines abgeschlossenen Fortschritts.',
      'Journey progress': 'Programmfortschritt',
      'Milestone reached': 'Meilenstein erreicht',
      'The next phase is unlocked': 'Die nächste Phase ist freigeschaltet',
      'Next mission unlocked': 'Nächste Mission freigeschaltet',
      'View completed journey': 'Abgeschlossenes Programm ansehen',
      'Back to journey': 'Zurück zum Programm',
      'How to do it': 'So führst du es aus',
      'Goal': 'Ziel',
      'What to notice': 'Worauf du achten solltest',
      'Coach cue': 'Trainerhinweis',
      'Breathing': 'Atmung',
      'Coach tip': 'Trainer-Tipp',
      'Safety': 'Sicherheit',
      'Avoid these mistakes': 'Diese Fehler vermeiden',
      'Mission': 'Mission',
      'Short session': 'Kurze Session',
      'Load': 'Belastung',
      'Today’s target': 'Heutiges Ziel',
      'Why this mission': 'Warum diese Mission',
      'What to notice after': 'Worauf du danach achten solltest',
      'Start mission': 'Mission starten',
      'Done': 'Fertig',
      'Back to current mission': 'Zurück zur aktuellen Mission',
      '{unread} unread, {upcoming} upcoming, {total} total reminders.': '{unread} ungelesen, {upcoming} bevorstehend, {total} Erinnerungen insgesamt.',
      'Today {time}': 'Heute {time}',
      'Tomorrow {time}': 'Morgen {time}',
      'Continue tomorrow': 'Morgen weitermachen',
      'Next program step tomorrow': 'Nächste Programm-Mission morgen',
      'Recovery reminder set for tomorrow': 'Recovery-Erinnerung für morgen geplant',
      'You already completed recovery work today. Your session reminder will wait until tomorrow.': 'Du hast deine Recovery für heute bereits abgeschlossen. Deine Session-Erinnerung wartet bis morgen.',
      'You already completed recovery work today. Your next program reminder will wait until tomorrow.': 'Du hast deine Recovery für heute bereits abgeschlossen. Die nächste Programm-Erinnerung wartet bis morgen.',
      'You already completed recovery work today. The next reminder will wait until tomorrow.': 'Du hast deine Recovery für heute bereits abgeschlossen. Die nächste Erinnerung kommt morgen.',
      'Finish your recovery session': 'Recovery-Session abschließen',
      'You started a session. Finish it with one clean reset.': 'Du hast eine Session begonnen. Schließe sie mit einem kurzen Reset ab.',
      'Continue your recovery program': 'Recovery-Programm fortsetzen',
      'Restart with a short reset': 'Mit einem kurzen Reset wieder einsteigen',
      'Unlock deeper recovery tools': 'Mehr Recovery-Funktionen freischalten',
      'Time for a quick reset': 'Zeit für einen kurzen Reset',
      'Take two focused minutes for your neck, back, or wrists.': 'Nimm dir zwei konzentrierte Minuten für Nacken, Rücken oder Handgelenke.',
    };
    final direct = exact[fallback];
    if (direct != null) return direct;

    var match = RegExp(r'^(\d+) days$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Tage';
    match = RegExp(r'^(\d+) min/day$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Min./Tag';
    match = RegExp(r'^(\d+) missions$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Missionen';
    match = RegExp(r'^Mission (\d+) of (\d+)$').firstMatch(fallback);
    if (match != null) return 'Mission ${match.group(1)} von ${match.group(2)}';
    match = RegExp(r'^(\d+)% of recent recovery work was concentrated in this zone\. Action: rotate one supporting session for a secondary zone\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} % der jüngsten Erholungsarbeit entfielen auf diesen Bereich. Ergänze eine unterstützende Session für einen zweiten Bereich.';
    match = RegExp(r'^(\d+) runs were abandoned in this window\. This may indicate session length mismatch or friction inside the player flow\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Sessions wurden in diesem Zeitraum vorzeitig beendet. Das kann auf eine unpassende Dauer oder Reibung im Ablauf hinweisen.';
    match = RegExp(r'^(\d+)% of recent feedback marked sessions as helpful, with an average relief score of (\d+)\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} % des aktuellen Feedbacks bewerteten Sessions als hilfreich; der durchschnittliche Entlastungswert lag bei ${match.group(2)}.';
    match = RegExp(r'^(\d+) minutes logged with strong helpful feedback\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Minuten wurden mit deutlich positivem Feedback erfasst.';

    match = RegExp(r'^(\d+) mission streak$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} Missionen in Folge';
    match = RegExp(r'^(.+) is complete\. Your next phase is now ready\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} ist abgeschlossen. Die nächste Phase ist jetzt bereit.';
    match = RegExp(r'^(.+) unlocked$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} freigeschaltet';
    match = RegExp(r'^Day (\d+) is ready\. Keep the recovery chain moving\.$').firstMatch(fallback);
    if (match != null) return 'Mission ${match.group(1)} ist bereit. Bleib in deinem Rhythmus.';
    match = RegExp(r'^(.+) — Day (\d+) is ready\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} — Mission ${match.group(2)} ist bereit.';
    match = RegExp(r'^It has been (\d+) days\. Start with one low-friction desk recovery session\.$').firstMatch(fallback);
    if (match != null) return 'Seit deiner letzten Session sind ${match.group(1)} Tage vergangen. Starte mit einer kurzen Recovery-Session am Schreibtisch.';
    match = RegExp(r'^Continue (.+) and complete today’s reset\.$').firstMatch(fallback);
    if (match != null) return '${match.group(1)} fortsetzen und den heutigen Reset abschließen.';

    return fallback;
  }

}

class AppText {
  const AppText._();

  static const String staticAppTitle = 'Posture Reset';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
  ];

  static AppTextReader of(BuildContext context) {
    return _GeneratedAppTextReader(AppLocalizations.of(context));
  }

  static LocalizationsDelegate<AppLocalizations> get delegate =>
      AppLocalizations.delegate;

  static String get(
    BuildContext context, {
    required String key,
    required String fallback,
  }) {
    return of(context).get(key, fallback: fallback);
  }
}