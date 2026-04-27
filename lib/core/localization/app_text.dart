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
      case 'settings_language_persian':
        return _t.settings_language_persian;

      default:
        return fallback;
    }
  }
}

class AppText {
  const AppText._();

  static const String staticAppTitle = 'Posture Reset';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('fa'),
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