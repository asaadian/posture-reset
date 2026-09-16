// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Posture Reset';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSessions => 'Sessions';

  @override
  String get navQuickFix => 'Quick Fix';

  @override
  String get navInsights => 'Insights';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonBackHome => 'Back to dashboard';

  @override
  String get common_back => 'Back';

  @override
  String get saved_sessions_title => 'Saved Sessions';

  @override
  String get saved_sessions_empty_title => 'No saved sessions yet';

  @override
  String get saved_sessions_empty_body =>
      'Save sessions from the library or detail page to build your continuity list.';

  @override
  String get saved_sessions_browse_cta => 'Browse Sessions';

  @override
  String get saved_sessions_error => 'Could not load saved sessions.';

  @override
  String get session_history_title => 'Session History';

  @override
  String get session_history_empty_title => 'No session history yet';

  @override
  String get session_history_empty_body =>
      'Your completed and unfinished session runs will appear here.';

  @override
  String get session_history_error => 'Could not load session history.';

  @override
  String get continuity_continue_title => 'Continue Session';

  @override
  String get continuity_resume_title => 'Resume Session';

  @override
  String get continuity_repeat_title => 'Do It Again';

  @override
  String get continuity_start_title => 'Start Session';

  @override
  String get continuity_continue_cta => 'Continue';

  @override
  String get continuity_resume_cta => 'Resume';

  @override
  String get continuity_repeat_cta => 'Do Again';

  @override
  String get continuity_start_cta => 'Start';

  @override
  String get continuity_open_detail => 'Open Detail';

  @override
  String get continuity_reason_active =>
      'You still have an active recovery run.';

  @override
  String get continuity_reason_resumable =>
      'You left this session unfinished and can pick it up again.';

  @override
  String get continuity_reason_saved =>
      'This saved session is your best next continuity pick.';

  @override
  String get continuity_reason_repeat =>
      'This is the most recent session worth repeating.';

  @override
  String get continuity_resume_available => 'Resume available';

  @override
  String get continuity_status_started => 'Started';

  @override
  String get continuity_status_completed => 'Completed';

  @override
  String get continuity_status_abandoned => 'Ended early';

  @override
  String get continuity_label_active => 'Active run';

  @override
  String get continuity_label_resumable => 'Unfinished';

  @override
  String get continuity_label_repeatable => 'Played before';

  @override
  String get continuity_label_saved => 'Saved';

  @override
  String get continuity_strip_title => 'Pick up where you left off';

  @override
  String get startupLoadingTitle => 'Starting app';

  @override
  String get startupLoadingSubtitle =>
      'Preparing app services and loading startup configuration.';

  @override
  String get startupErrorTitle => 'Startup failed';

  @override
  String get startupErrorSubtitle =>
      'The app could not finish startup. Check configuration and try again.';

  @override
  String get routeNotFoundTitle => 'Page not found';

  @override
  String get dashboard_hero_body => 'Readiness first. Body signals next.';

  @override
  String get routeNotFoundSubtitle =>
      'The requested page does not exist or is no longer available.';

  @override
  String get sessions_featured_title => 'Featured Sessions';

  @override
  String get sessions_all_results_title => 'All Sessions';

  @override
  String get sessions_all_results_subtitle =>
      'Browse the complete session library with real filters and sorting.';

  @override
  String get sessions_error_title => 'Could not load sessions';

  @override
  String get sessions_error_body =>
      'The session library could not be loaded. Try again.';

  @override
  String get sessions_empty_title => 'No sessions available';

  @override
  String get sessions_empty_body =>
      'No active sessions are available in the catalog right now.';

  @override
  String get sessions_no_results_title => 'No matching sessions';

  @override
  String get sessions_no_results_body =>
      'Try a different search, category, or sort setting.';

  @override
  String get sessions_clear_filters_cta => 'Clear filters';

  @override
  String get sessions_search_hint =>
      'Search sessions, goals, pain points, and tags...';

  @override
  String get sessions_category_all => 'All';

  @override
  String get sessions_category_neck_shoulders => 'Neck & Shoulders';

  @override
  String get sessions_category_upper_back => 'Upper Back';

  @override
  String get sessions_category_lower_back => 'Lower Back';

  @override
  String get sessions_category_wrists_forearms => 'Wrists & Forearms';

  @override
  String get sessions_category_focus => 'Focus';

  @override
  String get sessions_category_recovery => 'Recovery';

  @override
  String get sessions_category_quiet_desk => 'Quiet & Desk';

  @override
  String get sessions_sort_recommended => 'Recommended';

  @override
  String get sessions_sort_duration_shortest => 'Duration: Shortest';

  @override
  String get sessions_sort_duration_longest => 'Duration: Longest';

  @override
  String get sessions_sort_intensity_lowest => 'Intensity: Lowest';

  @override
  String get sessions_sort_intensity_highest => 'Intensity: Highest';

  @override
  String get sessions_sort_alphabetical => 'Alphabetical';

  @override
  String get sessions_filter_silent_only => 'Silent only';

  @override
  String get sessions_filter_beginner_only => 'Beginner only';

  @override
  String sessions_duration_minutes_format(Object minutes) {
    return '$minutes min';
  }

  @override
  String get sessions_intro_title =>
      'Structured recovery sessions built for real workdays.';

  @override
  String get sessions_intro_body =>
      'Search and filter real sessions by pain point, work context, duration, and intensity.';

  @override
  String get sessions_intensity_gentle => 'Gentle';

  @override
  String get sessions_intensity_light => 'Light';

  @override
  String get sessions_intensity_moderate => 'Moderate';

  @override
  String get sessions_intensity_strong => 'Strong';

  @override
  String get sessions_tag_silent => 'Silent';

  @override
  String get sessions_tag_beginner => 'Beginner';

  @override
  String get session_detail_start_button => 'Start Session';

  @override
  String get session_detail_save_button => 'Save';

  @override
  String get session_detail_saved_button => 'Saved';

  @override
  String get session_detail_saved_success => 'Session saved.';

  @override
  String get session_detail_unsaved_success => 'Session removed from saved.';

  @override
  String get session_detail_sign_in_to_save => 'Sign in to save sessions.';

  @override
  String get session_detail_go_to_profile => 'Profile';

  @override
  String get session_detail_save_requires_account_hint =>
      'Saving requires sign-in.';

  @override
  String session_detail_duration_format(Object minutes) {
    return '$minutes min';
  }

  @override
  String get session_detail_silent_friendly => 'Silent-friendly';

  @override
  String get session_detail_beginner_friendly => 'Beginner-friendly';

  @override
  String get session_detail_goals_title => 'Goals';

  @override
  String get session_detail_compatibility_title => 'Compatibility';

  @override
  String get session_detail_modes_title => 'Works well with';

  @override
  String get session_detail_environment_title => 'Best environment';

  @override
  String get session_detail_related_title => 'Related Sessions';

  @override
  String get session_detail_related_empty => 'No related sessions found.';

  @override
  String get session_detail_related_error => 'Could not load related sessions.';

  @override
  String get session_intensity_gentle => 'Gentle';

  @override
  String get session_intensity_light => 'Light';

  @override
  String get session_intensity_moderate => 'Moderate';

  @override
  String get session_intensity_strong => 'Strong';

  @override
  String get session_goal_pain_relief => 'Pain relief';

  @override
  String get session_goal_posture_reset => 'Posture reset';

  @override
  String get session_goal_focus_prep => 'Focus prep';

  @override
  String get session_goal_recovery => 'Recovery';

  @override
  String get session_goal_mobility => 'Mobility';

  @override
  String get session_goal_decompression => 'Decompression';

  @override
  String get session_mode_dad => 'Dad Mode';

  @override
  String get session_mode_night => 'Night Mode';

  @override
  String get session_mode_focus => 'Focus Mode';

  @override
  String get session_mode_pain_relief => 'Pain Relief Mode';

  @override
  String get session_env_desk_friendly => 'Desk-friendly';

  @override
  String get session_env_office_friendly => 'Office-friendly';

  @override
  String get session_env_home_friendly => 'Home-friendly';

  @override
  String get session_env_no_mat => 'No mat required';

  @override
  String get session_env_low_space => 'Low-space friendly';

  @override
  String get session_env_quiet => 'Quiet-friendly';

  @override
  String get session_detail_equipment_title => 'Equipment';

  @override
  String get session_detail_saving_cta => 'Saving...';

  @override
  String get session_detail_steps_empty =>
      'No step preview is available for this session yet.';

  @override
  String get session_detail_step_skippable => 'Skippable';

  @override
  String get session_step_type_setup => 'Setup';

  @override
  String get session_step_type_movement => 'Movement';

  @override
  String get session_step_type_hold => 'Hold';

  @override
  String get session_step_type_breath => 'Breath';

  @override
  String get session_step_type_transition => 'Transition';

  @override
  String get session_detail_save_failed => 'Could not update saved session.';

  @override
  String get session_step_type_cooldown => 'Cooldown';

  @override
  String get auth_page_title => 'Account';

  @override
  String get auth_sign_in_title => 'Sign in';

  @override
  String get auth_sign_up_title => 'Create account';

  @override
  String get auth_sign_in_subtitle =>
      'Sign in to save sessions and keep your recovery data with your account.';

  @override
  String get auth_sign_up_subtitle =>
      'Create an account to save sessions and unlock continuity across devices.';

  @override
  String get auth_sign_in_tab => 'Sign in';

  @override
  String get auth_sign_up_tab => 'Create account';

  @override
  String get auth_email_label => 'Email';

  @override
  String get auth_password_label => 'Password';

  @override
  String get auth_confirm_password_label => 'Confirm password';

  @override
  String get auth_email_required => 'Email is required.';

  @override
  String get auth_email_invalid => 'Enter a valid email address.';

  @override
  String get auth_password_required => 'Password is required.';

  @override
  String get auth_password_too_short =>
      'Password must be at least 8 characters.';

  @override
  String get auth_confirm_password_required => 'Please confirm your password.';

  @override
  String get auth_confirm_password_mismatch => 'Passwords do not match.';

  @override
  String get auth_submitting => 'Please wait...';

  @override
  String get auth_sign_in_button => 'Sign in';

  @override
  String get auth_sign_up_button => 'Create account';

  @override
  String get auth_sign_in_success => 'Signed in successfully.';

  @override
  String get auth_sign_up_success_signed_in => 'Account created and signed in.';

  @override
  String get auth_sign_up_check_email =>
      'Account created. Check your email to confirm your account.';

  @override
  String get auth_unknown_error => 'Something went wrong. Please try again.';

  @override
  String get auth_signed_out_success => 'Signed out successfully.';

  @override
  String get profile_sign_out_tooltip => 'Sign out';

  @override
  String get profile_account_access_section_title => 'Account Access';

  @override
  String get profile_account_access_section_subtitle =>
      'Sign in to save sessions and keep your account data connected.';

  @override
  String get profile_account_sign_in_title => 'Sign in or create account';

  @override
  String get profile_account_sign_in_subtitle =>
      'Use email and password to unlock saved sessions and account continuity.';

  @override
  String get profile_account_manage_title => 'Manage account access';

  @override
  String get profile_account_signed_in_subtitle => 'Signed in successfully.';

  @override
  String get profile_status_plan_signed_in_value => 'Account Ready';

  @override
  String get profile_status_plan_signed_in_subtitle =>
      'Session saving available';

  @override
  String get profile_account_guest_name => 'Guest';

  @override
  String get profile_account_guest_subtitle =>
      'Sign in to save sessions and keep your progress connected.';

  @override
  String get profile_account_guest_initial => 'G';

  @override
  String get profile_account_signed_in_name => 'Account';

  @override
  String get profile_account_tag_signed_in => 'Signed In';

  @override
  String get profile_account_tag_session_save => 'Session Saving Enabled';

  @override
  String get profile_account_tag_guest => 'Guest';

  @override
  String get profile_account_tag_sign_in_needed => 'Sign In Required for Save';

  @override
  String get profile_account_sign_in_button => 'Sign in';

  @override
  String get profile_account_create_button => 'Create account';

  @override
  String get profile_account_sign_out_button => 'Sign out';

  @override
  String get profile_preferences_section_subtitle =>
      'Current app defaults that shape recommendations and quick session suggestions.';

  @override
  String get profile_status_section_subtitle =>
      'Current account readiness and session-saving availability.';

  @override
  String get profile_status_account_title => 'Account';

  @override
  String get profile_status_account_signed_in => 'Signed In';

  @override
  String get profile_status_account_guest => 'Guest';

  @override
  String get profile_status_account_signed_in_subtitle =>
      'Your account session is active.';

  @override
  String get profile_status_account_guest_subtitle =>
      'Sign in to unlock saved sessions.';

  @override
  String get profile_status_session_save_title => 'Session Saving';

  @override
  String get profile_status_session_save_enabled => 'Enabled';

  @override
  String get profile_status_session_save_disabled => 'Unavailable';

  @override
  String get profile_status_session_save_enabled_subtitle =>
      'Saved sessions are available on this account.';

  @override
  String get profile_status_session_save_disabled_subtitle =>
      'Sign in is required before sessions can be saved.';

  @override
  String get profile_status_plan_subtitle => 'Premium not active.';

  @override
  String get settings_language_sheet_title => 'Choose language';

  @override
  String get settings_language_sheet_subtitle =>
      'Apply a language for the whole app.';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_german => 'Deutsch';

  @override
  String get settings_language_persian => 'فارسی';

  @override
  String get session_player_title => 'Player';

  @override
  String get player_close_tooltip => 'Close player';

  @override
  String get player_progress_title => 'Session Progress';

  @override
  String get player_step_label_prefix => 'Step';

  @override
  String get player_step_label_empty => 'No steps';

  @override
  String get player_current_step_label => 'Current Step';

  @override
  String get player_step_type_label => 'Type';

  @override
  String get player_step_duration_label => 'Duration';

  @override
  String get player_step_skippable_label => 'Skippable';

  @override
  String get player_target_label => 'Target';

  @override
  String get player_terminal_title => 'Live Status';

  @override
  String get player_pause_cta => 'Pause';

  @override
  String get player_resume_cta => 'Resume';

  @override
  String get player_previous_cta => 'Previous';

  @override
  String get player_next_cta => 'Next';

  @override
  String get player_skip_cta => 'Skip';

  @override
  String get player_replay_cta => 'Replay Step';

  @override
  String get player_finish_cta => 'Finish Session';

  @override
  String get player_exit_title => 'End session?';

  @override
  String get player_exit_message =>
      'Your current session will be closed and progress will be saved as an incomplete run.';

  @override
  String get player_exit_cancel_cta => 'Keep session';

  @override
  String get player_exit_confirm_cta => 'End session';

  @override
  String get player_not_found_title => 'Session not found';

  @override
  String get player_not_found_message =>
      'The requested session could not be found or is no longer available.';

  @override
  String get player_no_steps_title => 'No steps available';

  @override
  String get player_no_steps_message =>
      'This session does not contain any playable steps yet.';

  @override
  String get player_error_title => 'Could not start player';

  @override
  String get player_error_subtitle =>
      'Something went wrong while loading this session.';

  @override
  String get player_back_cta => 'Back';

  @override
  String get player_loading_title => 'Preparing player...';

  @override
  String get player_auth_required_title => 'Sign in required';

  @override
  String get player_auth_required_message =>
      'You need an account to start and track session runs.';

  @override
  String get player_auth_required_cta => 'Sign in';

  @override
  String get player_status_completed => 'Completed';

  @override
  String get player_status_running_log => '[RUN] session is active';

  @override
  String get player_status_paused_log => '[PAUSE] session is currently paused';

  @override
  String get player_status_completed_log =>
      '[DONE] session completed successfully';

  @override
  String get player_next_step_log_prefix => '[NEXT]';

  @override
  String get player_runtime_summary_title => 'Runtime Summary';

  @override
  String get player_runtime_elapsed => 'Elapsed';

  @override
  String get player_runtime_remaining => 'Remaining';

  @override
  String get player_runtime_step_remaining => 'Step Remaining';

  @override
  String get player_breath_cue_title => 'Breathing Cue';

  @override
  String get player_safety_note_title => 'Safety Note';

  @override
  String get player_completion_title => 'Session Complete';

  @override
  String get player_completion_subtitle =>
      'Your run has been saved successfully.';

  @override
  String get player_completion_steps => 'Steps';

  @override
  String get player_completion_total_time => 'Total Time';

  @override
  String get player_completion_back_to_detail => 'Back to Session Detail';

  @override
  String get player_media_placeholder_chip => 'Movement Preview';

  @override
  String get player_media_placeholder_body_short =>
      'Video or GIF guidance will appear here for this step.';

  @override
  String get player_media_placeholder_body =>
      'Video or GIF guidance will appear here for this step. The player layout is already ready for real movement media.';

  @override
  String get player_completion_body_impact_title =>
      'What changed in this session';

  @override
  String get player_completion_effect_release => 'Mobility + release';

  @override
  String get player_completion_effect_reset => 'Posture reset';

  @override
  String get session_detail_back_tooltip => 'Back';

  @override
  String get player_completion_close => 'Close';

  @override
  String get quick_fix_title => 'Quick Fix';

  @override
  String get quick_fix_history_tooltip => 'Recent quick fixes';

  @override
  String get quick_fix_loading_title => 'Preparing Quick Fix…';

  @override
  String get quick_fix_error_title => 'Unable to load Quick Fix';

  @override
  String get quick_fix_error_body => 'Please try again.';

  @override
  String get quick_fix_empty_title => 'No recommendation available';

  @override
  String get quick_fix_empty_body =>
      'Adjust your current context to generate a live recommendation.';

  @override
  String get quick_fix_hero_eyebrow => 'Adaptive Recovery Launcher';

  @override
  String get quick_fix_hero_title =>
      'Find the right session for your body state in seconds.';

  @override
  String get quick_fix_hero_body =>
      'Quick Fix turns your current pain point, time window, energy, and environment into a real session recommendation from the live catalog.';

  @override
  String get quick_fix_hero_stat_fast => 'Fast Match';

  @override
  String get quick_fix_hero_stat_silent => 'Quiet Context';

  @override
  String get quick_fix_hero_stat_personalized => 'Live Personalization';

  @override
  String get quick_fix_problem_section_title => 'What needs help right now?';

  @override
  String get quick_fix_problem_section_subtitle =>
      'Choose the pain point or reset target that matters most.';

  @override
  String get quick_fix_context_section_title => 'Time + environment';

  @override
  String get quick_fix_context_section_subtitle =>
      'Keep the suggestion realistic for your current setup.';

  @override
  String get quick_fix_state_section_title => 'Energy + mode';

  @override
  String get quick_fix_state_section_subtitle =>
      'Shape the recommendation around how intense and contextual it should feel.';

  @override
  String get quick_fix_recommendation_section_title => 'Recommended Session';

  @override
  String get quick_fix_recommendation_section_subtitle =>
      'The engine updates the session match from your current body context.';

  @override
  String get quick_fix_recommendation_missing =>
      'No recommendation available yet.';

  @override
  String get quick_fix_primary_match_label => 'Best Match Right Now';

  @override
  String get quick_fix_reasoning_default =>
      'Recommended because it strongly matches your current problem, time window, and environment.';

  @override
  String get quick_fix_more_matches_title => 'Other strong matches';

  @override
  String get quick_fix_start_now_cta => 'Start Now';

  @override
  String get quick_fix_view_details_cta => 'View Details';

  @override
  String get quick_fix_silent_mode_title => 'Silent Mode';

  @override
  String get quick_fix_problem_neck => 'Neck Pain';

  @override
  String get quick_fix_problem_shoulder => 'Shoulder Tightness';

  @override
  String get quick_fix_problem_wrist => 'Wrist Pain';

  @override
  String get quick_fix_problem_back => 'Lower Back';

  @override
  String get quick_fix_problem_eye => 'Eye Strain';

  @override
  String get quick_fix_problem_stress => 'Stress Reset';

  @override
  String get quick_fix_time_2 => '2 min';

  @override
  String get quick_fix_time_4 => '4 min';

  @override
  String get quick_fix_time_6 => '6 min';

  @override
  String get quick_fix_time_10 => '10 min';

  @override
  String get quick_fix_location_desk => 'Desk';

  @override
  String get quick_fix_location_chair => 'Chair';

  @override
  String get quick_fix_location_standing => 'Standing';

  @override
  String get quick_fix_location_floor => 'Floor';

  @override
  String get quick_fix_location_bedside => 'Bedside';

  @override
  String get quick_fix_energy_low => 'Low';

  @override
  String get quick_fix_energy_medium => 'Medium';

  @override
  String get quick_fix_energy_high => 'High';

  @override
  String get quick_fix_mode_dad => 'Dad Mode';

  @override
  String get quick_fix_mode_night => 'Night Coder';

  @override
  String get quick_fix_mode_focus => 'Focus Mode';

  @override
  String get quick_fix_mode_pain_relief => 'Pain Relief';

  @override
  String get player_pre_state_title => 'Quick check-in before you start';

  @override
  String get player_pre_state_subtitle =>
      'Capture a few signals before this session so progress and outcomes can be tracked better.';

  @override
  String get player_pre_state_energy_title => 'Energy';

  @override
  String get player_pre_state_stress_title => 'Stress';

  @override
  String get player_pre_state_focus_title => 'Focus';

  @override
  String get player_pre_state_intent_title => 'Intent';

  @override
  String get player_pre_state_pain_areas_title => 'Pain areas';

  @override
  String get player_pre_state_skip => 'Skip for now';

  @override
  String get player_pre_state_start_cta => 'Start session';

  @override
  String get player_feedback_title => 'How did this session feel?';

  @override
  String get player_feedback_abandoned_title =>
      'Before you leave, how did this session feel?';

  @override
  String get player_feedback_summary_title => 'Session summary';

  @override
  String get player_feedback_abandoned_summary_title => 'Session ended early';

  @override
  String get player_feedback_helped_title => 'Did this help?';

  @override
  String get player_feedback_tension_title => 'Tension';

  @override
  String get player_feedback_pain_title => 'Pain';

  @override
  String get player_feedback_energy_title => 'Energy';

  @override
  String get player_feedback_fit_title => 'Session fit';

  @override
  String get player_feedback_repeat_title => 'Would you repeat this session?';

  @override
  String get player_feedback_yes => 'Yes';

  @override
  String get player_feedback_no => 'No';

  @override
  String get player_feedback_repeat_yes => 'Would repeat';

  @override
  String get player_feedback_repeat_no => 'Not likely';

  @override
  String get player_feedback_submit => 'Save feedback';

  @override
  String get player_feedback_close => 'Close';

  @override
  String get common_level_low => 'Low';

  @override
  String get common_level_medium => 'Medium';

  @override
  String get common_level_high => 'High';

  @override
  String get common_delta_worse => 'Worse';

  @override
  String get common_delta_same => 'Same';

  @override
  String get common_delta_better => 'Better';

  @override
  String get common_fit_poor => 'Poor';

  @override
  String get common_fit_okay => 'Okay';

  @override
  String get common_fit_great => 'Great';

  @override
  String get intent_relief => 'Relief';

  @override
  String get intent_reset => 'Reset';

  @override
  String get intent_focus => 'Focus';

  @override
  String get intent_unwind => 'Unwind';

  @override
  String get pain_neck => 'Neck';

  @override
  String get pain_shoulders => 'Shoulders';

  @override
  String get pain_upper_back => 'Upper back';

  @override
  String get pain_lower_back => 'Lower back';

  @override
  String get pain_wrists => 'Wrists';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_error_title => 'Unable to load dashboard';

  @override
  String get dashboard_error_body => 'Please try again.';

  @override
  String get dashboard_error_retry => 'Retry';

  @override
  String get dashboard_empty_title => 'No dashboard data yet';

  @override
  String get dashboard_empty_body =>
      'Complete a session or launch a Quick Fix to populate your dashboard.';

  @override
  String get dashboard_empty_refresh => 'Refresh';

  @override
  String get dashboard_hero_overline => 'Recovery Command Center';

  @override
  String get dashboard_hero_title => 'Recovery Command Center';

  @override
  String get dashboard_hero_body_with_next =>
      'Track your state, review momentum, and launch the next best recovery session without leaving the dashboard.';

  @override
  String get dashboard_hero_start_next => 'Start Next Session';

  @override
  String get dashboard_hero_quick_fix => 'Quick Fix';

  @override
  String get dashboard_hero_body_map => 'Body Map';

  @override
  String get dashboard_readiness_title => 'Readiness Score';

  @override
  String get dashboard_state_energy => 'Energy';

  @override
  String get dashboard_state_stress => 'Stress';

  @override
  String get dashboard_state_focus => 'Focus';

  @override
  String get dashboard_state_unknown => 'Unknown';

  @override
  String get dashboard_minutes_week => 'Minutes This Week';

  @override
  String get dashboard_completed_week => 'Completed Sessions';

  @override
  String get dashboard_quickfix_week => 'Quick Fix Starts';

  @override
  String get dashboard_body_intelligence_title => 'Body Intelligence';

  @override
  String get dashboard_body_intelligence_subtitle =>
      'Dominant zones, recent recovery quality, and where your body asks for attention most often.';

  @override
  String get dashboard_help_rate => 'Help Rate';

  @override
  String get dashboard_consistency => 'Consistency';

  @override
  String get dashboard_dominant_zone => 'Dominant Zone';

  @override
  String get dashboard_zone_unknown => 'No clear zone yet';

  @override
  String get dashboard_empty_body_zones =>
      'Body zone patterns will appear after more tracked runs.';

  @override
  String get dashboard_trends_title => 'Recovery Trends';

  @override
  String get dashboard_trends_subtitle =>
      'A visual read on how much recovery time you are logging and how helpful those sessions feel.';

  @override
  String get dashboard_chart_minutes_title => 'Recovery Minutes';

  @override
  String get dashboard_chart_relief_title => 'Relief Quality';

  @override
  String get dashboard_heatmap_title => 'Recovery Heatmap';

  @override
  String get dashboard_heatmap_subtitle =>
      'A rolling view of how consistently your recovery system has been active over the last three weeks.';

  @override
  String get dashboard_recent_runs_title => 'Recent Recovery Runs';

  @override
  String get dashboard_recent_runs_subtitle =>
      'A compact timeline of what you ran most recently, how it ended, and where it came from.';

  @override
  String get dashboard_empty_recent_runs =>
      'Recent session runs will appear here.';

  @override
  String get dashboard_body_map_cta_title => 'Inspect active tension zones';

  @override
  String get dashboard_body_map_cta_body =>
      'Open the body map to review active pain areas, see what has improved, and hand off directly into the next useful session.';

  @override
  String get dashboard_open_body_map => 'Open Body Map';

  @override
  String get dashboard_next_session_reason_quick_fix =>
      'Recommended from your latest Quick Fix context';

  @override
  String get dashboard_next_session_reason_resume =>
      'A strong fit based on your recent activity';

  @override
  String get update_later_cta => 'Later';

  @override
  String get update_now_cta => 'Update';

  @override
  String get notification_permission_prompt_title =>
      'Enable recovery reminders?';

  @override
  String get notification_permission_prompt_body =>
      'Get one gentle daily reminder for a quick posture reset.';

  @override
  String get common_not_now => 'Not now';

  @override
  String get notification_enable_cta => 'Enable';

  @override
  String get guide_skip_cta => 'Skip';

  @override
  String get guide_got_it_cta => 'Got it';

  @override
  String get guide_next_cta => 'Next';

  @override
  String get startup_error_body =>
      'The app could not finish startup. Please check your connection and try again.';

  @override
  String get startup_error_retry_cta => 'Try again';

  @override
  String get nav_training => 'Training';

  @override
  String get nav_programs => 'Programs';

  @override
  String get notification_center_title => 'Notifications';

  @override
  String get notification_center_refresh => 'Refresh reminders';

  @override
  String get notification_center_mark_all_read => 'Mark all read';

  @override
  String get notification_center_error_title => 'Could not load notifications';

  @override
  String get notification_center_empty_title => 'No reminders scheduled';

  @override
  String get notification_center_empty_body =>
      'Turn Recovery reminders on in Settings, then pull down here to refresh.';

  @override
  String get notification_center_header_title => 'Recovery reminders';

  @override
  String get notification_center_status_upcoming => 'Upcoming';

  @override
  String get notification_center_status_opened => 'Opened';

  @override
  String get notification_center_status_new => 'New';

  @override
  String get notification_center_status_scheduled => 'Scheduled';

  @override
  String get quick_fix_page_step_hint =>
      'Choose an area, then start your session';

  @override
  String get guide_quick_fix_body_title => 'Tap the body';

  @override
  String get guide_quick_fix_body_body =>
      'Pick the area that feels tight. The app will focus the recommendation there.';

  @override
  String get guide_quick_fix_filters_title => 'Set simple filters';

  @override
  String get guide_quick_fix_filters_body =>
      'Choose time and available equipment. Keep it simple.';

  @override
  String get guide_quick_fix_match_title => 'Get a match';

  @override
  String get guide_quick_fix_match_body =>
      'Tap Find Match to get one session that fits your current situation.';

  @override
  String get quick_fix_match_session_cta => 'Find Match';

  @override
  String get quick_fix_selected_target_empty => 'Selected body';

  @override
  String get quick_fix_matched_title => 'Matched session';

  @override
  String get quick_fix_matching_title => 'Matching your reset…';

  @override
  String get quick_fix_selected_count_suffix => 'selected';

  @override
  String get quick_fix_equipment_title => 'Equipment';

  @override
  String get common_apply => 'Apply';

  @override
  String get quick_fix_body_map_hint_step => 'Tap body point';

  @override
  String get body_map_front => 'Front';

  @override
  String get body_map_back => 'Back';

  @override
  String get quick_fix_recommended_badge => 'Best match';

  @override
  String get quick_fix_start_session => 'Start session';

  @override
  String get quick_fix_alternatives_title => 'Other good options';

  @override
  String get quick_fix_none_selected => 'None selected';

  @override
  String get common_close => 'Close';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_settings_tooltip => 'Open settings';

  @override
  String get profile_primary_continue => 'Continue recovery';

  @override
  String get profile_primary_open_sessions => 'Start training';

  @override
  String get profile_sign_in_cta => 'Sign in';

  @override
  String get profile_sync_connected => 'Synced';

  @override
  String get profile_sync_local => 'Local';

  @override
  String get profile_guest_subtitle => 'Guest profile';

  @override
  String get profile_metric_saved => 'Saved';

  @override
  String get profile_metric_runs => 'Runs';

  @override
  String get profile_metric_status => 'Status';

  @override
  String get profile_action_premium => 'Core Access';

  @override
  String get profile_action_premium_subtitle_large =>
      'Unlock all sessions, programs, Quick Fix, and insights.';

  @override
  String get profile_action_saved_short => 'Saved';

  @override
  String get profile_action_saved_subtitle_short => 'Sessions';

  @override
  String get session_history_title_compact => 'History';

  @override
  String get profile_action_history_subtitle_short => 'Runs';

  @override
  String get profile_action_programs => 'Programs';

  @override
  String get profile_action_programs_subtitle_short => 'Plans';

  @override
  String get profile_account_section_title => 'Account';

  @override
  String get profile_account_section_subtitle => 'Profile and app controls.';

  @override
  String get profile_edit_title => 'Edit profile';

  @override
  String get profile_edit_subtitle => 'Name and photo';

  @override
  String get profile_action_settings => 'Settings';

  @override
  String get profile_action_settings_subtitle_compact => 'App';

  @override
  String get profile_sign_out_cta => 'Sign out';

  @override
  String get profile_create_account_cta => 'Create account';

  @override
  String get profile_sign_out_subtitle => 'Leave this device';

  @override
  String get profile_create_account_subtitle => 'Sync your progress';

  @override
  String get profile_danger_zone_title => 'Danger Zone';

  @override
  String get profile_danger_zone_subtitle => 'Account and data removal.';

  @override
  String get settings_reset_app_data_title => 'Reset app data';

  @override
  String get settings_reset_app_data_loading => 'Deleting your app data...';

  @override
  String get settings_reset_app_data_subtitle_short =>
      'Clear progress, saved items, and history.';

  @override
  String get settings_delete_account_section_title => 'Delete account';

  @override
  String get settings_delete_account_loading => 'Deleting account...';

  @override
  String get settings_delete_account_section_subtitle =>
      'Permanently remove your account and app data.';

  @override
  String get settings_reset_app_data_dialog_title => 'Reset app data?';

  @override
  String get settings_reset_app_data_dialog_body =>
      'This removes your training history, saved sessions, program progress, quick-fix history, feedback, profile, and preferences. Your sign-in account stays active. This cannot be undone.';

  @override
  String get settings_reset_app_data_confirm => 'Reset data';

  @override
  String get settings_reset_app_data_sign_in_required =>
      'Sign in first to reset your app data.';

  @override
  String get settings_reset_app_data_success => 'Your app data has been reset.';

  @override
  String get settings_reset_app_data_failed => 'Could not reset app data.';

  @override
  String get settings_delete_account_dialog_title => 'Delete account?';

  @override
  String get settings_delete_account_dialog_body =>
      'Your profile, preferences, saved sessions, history, purchase access, and account data will be removed. This cannot be undone.';

  @override
  String get settings_delete_account_confirm => 'Delete';

  @override
  String get settings_delete_account_sign_in_required =>
      'Sign in first to delete your account.';

  @override
  String get settings_delete_account_success =>
      'Your account has been deleted.';

  @override
  String get settings_delete_account_failed =>
      'Could not delete your account. Please contact support.';

  @override
  String get profile_core_access_badge => 'CORE ACCESS';

  @override
  String get profile_core_access_cta_short => 'Open';

  @override
  String get profile_edit_saved => 'Profile updated.';

  @override
  String get profile_avatar_updated => 'Profile photo updated.';

  @override
  String get profile_edit_error =>
      'Profile could not be updated. Please try again.';

  @override
  String get profile_change_photo_cta => 'Change photo';

  @override
  String get profile_remove_photo_cta => 'Remove';

  @override
  String get profile_display_name_label => 'Display name';

  @override
  String get profile_save_cta => 'Save';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_hero_title => 'App controls';

  @override
  String get settings_hero_subtitle =>
      'Language, theme, support, and legal information.';

  @override
  String get settings_preferences_compact_title => 'Preferences';

  @override
  String get settings_preferences_compact_subtitle =>
      'Language, theme, and sync.';

  @override
  String get settings_language_section_title => 'Language';

  @override
  String get settings_appearance_section_title => 'Appearance';

  @override
  String get notification_settings_title_compact => 'Notifications';

  @override
  String get notification_settings_inline_subtitle =>
      'Recovery reminders and haptics.';

  @override
  String get notification_settings_error =>
      'Could not load notification settings.';

  @override
  String get notification_settings_guest_hint =>
      'Sign in to save notification preferences.';

  @override
  String get notification_settings_enable_title => 'Recovery reminders';

  @override
  String get notification_settings_enabled_short => 'Daily reminder is active.';

  @override
  String get notification_settings_disabled_short =>
      'Off by default. Enable when you want reminders.';

  @override
  String get notification_permission_denied =>
      'Notification permission was not granted.';

  @override
  String get notification_settings_time_title => 'Reminder time';

  @override
  String get notification_settings_time_error =>
      'Could not load reminder time.';

  @override
  String get notification_settings_haptics_title => 'Haptics';

  @override
  String get notification_settings_haptics_short =>
      'Tactile confirmation where supported.';

  @override
  String get notification_time_morning => 'Morning';

  @override
  String get notification_time_afternoon => 'Afternoon';

  @override
  String get notification_time_evening => 'Evening';

  @override
  String get settings_support_legal_title => 'Support & legal';

  @override
  String get settings_support_legal_subtitle =>
      'Help, policies, and account information.';

  @override
  String get settings_contact_email_label => 'Email support';

  @override
  String get settings_privacy_policy_title => 'Privacy Policy';

  @override
  String get settings_external_link_subtitle => 'Open in browser';

  @override
  String get settings_terms_title => 'Terms of Use';

  @override
  String get settings_account_data_deletion_info_title =>
      'Data deletion policy';

  @override
  String get settings_app_version_loading => 'Loading version...';

  @override
  String get settings_app_version_title => 'App version';

  @override
  String get settings_theme_system_title => 'System';

  @override
  String get settings_theme_system_short => 'Auto';

  @override
  String get settings_theme_light_title => 'Light';

  @override
  String get settings_theme_light_short => 'Light';

  @override
  String get settings_theme_dark_title => 'Dark';

  @override
  String get settings_theme_dark_short => 'Dark';

  @override
  String get settings_preferences_error_short =>
      'Could not load cloud preferences.';

  @override
  String get settings_preferences_guest_hint =>
      'Sign in to sync preferences across devices.';

  @override
  String get settings_preferences_synced_short => 'Preferences are synced.';

  @override
  String get settings_link_open_failed => 'Could not open the link.';

  @override
  String get settings_email_open_failed => 'Could not open your email app.';

  @override
  String get premium_purchase_cancelled => 'Purchase was cancelled.';

  @override
  String get premium_restore_no_purchase_found =>
      'No previous Core Access purchase was found for this Google Play account.';

  @override
  String get premium_purchase_failed =>
      'Purchase could not be completed. Please try again.';

  @override
  String get premium_page_title => 'Core Access';

  @override
  String get premium_status_core_active => 'Unlocked';

  @override
  String get premium_visual_pill => 'One-time Core';

  @override
  String get premium_hero_unlocked_title => 'Core Access is active.';

  @override
  String get premium_visual_title_v2 => 'Unlock the full recovery system.';

  @override
  String get premium_hero_unlocked_body_v2 =>
      'Programs, full sessions, Quick Fix, insights, saved items, and history are available.';

  @override
  String get premium_visual_body_v2 =>
      'Programs, full sessions, Quick Fix, insights, saved items, and history — one unlock.';

  @override
  String get premium_programs_badge => 'Programs';

  @override
  String get premium_value_programs_title => 'Recovery programs';

  @override
  String get premium_value_sessions_title => 'Full sessions';

  @override
  String get premium_value_quick_fix_title => 'Quick Fix';

  @override
  String get premium_value_insights_title => 'Insights';

  @override
  String get premium_value_active_title => 'Your unlocked toolkit';

  @override
  String get premium_value_title => 'What Core unlocks';

  @override
  String get premium_value_subtitle_v2 => 'Full access in one unlock.';

  @override
  String get premium_product_price_unavailable => 'Price unavailable';

  @override
  String get premium_plan_unlocked_subtitle =>
      'Your full recovery toolkit is unlocked.';

  @override
  String get premium_plan_subtitle_v2 =>
      'One-time unlock. No subscription. Restore anytime with the same Google Play account.';

  @override
  String get premium_sign_in_hint =>
      'Sign in first so access can be restored later.';

  @override
  String get premium_plan_title => 'Core Access';

  @override
  String get premium_plan_lifetime_badge => 'One-time';

  @override
  String get premium_signal_lifetime => 'Lifetime';

  @override
  String get premium_signal_restore => 'Restore supported';

  @override
  String get premium_signal_no_subscription => 'No subscription';

  @override
  String get premium_already_unlocked_cta => 'Already unlocked';

  @override
  String get premium_restore_cta => 'Restore';

  @override
  String get premium_loading_products_cta => 'Checking store…';

  @override
  String get premium_purchasing_cta => 'Opening store…';

  @override
  String get premium_verifying_cta => 'Verifying…';

  @override
  String get premium_product_unavailable_cta => 'Product unavailable';

  @override
  String get access_unlock_core_cta => 'Unlock Core';

  @override
  String get premium_error_purchase_linked_to_another_account =>
      'This purchase is already linked to another account. Sign in with the account used for the original unlock.';

  @override
  String get premium_error_not_authenticated =>
      'Sign in first so your purchase can be verified.';

  @override
  String get premium_error_missing_purchase_payload =>
      'The store did not return a valid purchase receipt. Please try restore or contact support.';

  @override
  String get premium_error_product_mismatch =>
      'The store product does not match this app version. Please update the app or contact support.';

  @override
  String get premium_error_purchase_not_completed =>
      'The purchase was not completed. Please try again.';

  @override
  String get premium_error_unsupported_platform =>
      'Purchases are currently available only on Android.';

  @override
  String get premium_error_store_unavailable =>
      'Google Play billing is not available on this device. Please install the app from Google Play.';

  @override
  String get premium_error_product_unavailable =>
      'Core Access is not available from the store right now. Please try again later.';

  @override
  String get premium_error_purchase_failed =>
      'The purchase could not be started. Please try again.';

  @override
  String get premium_error_verification_failed =>
      'The purchase could not be verified. Please try restore or contact support.';

  @override
  String get premium_billing_error_body =>
      'Billing is not ready or the purchase could not be verified. Please try again.';

  @override
  String get logs_page_title => 'Logs';

  @override
  String get logs_locked_title => 'Behavior Logs are part of Core Access';

  @override
  String get logs_locked_message =>
      'Unlock Core once to inspect recovery logs generated from runs, feedback, quick-fix activity, state snapshots, and player events.';

  @override
  String get logs_hero_title => 'Recovery logs';

  @override
  String get logs_hero_body_short =>
      'Recent signals from sessions and Quick Fix.';

  @override
  String get logs_positive_label => 'Positive';

  @override
  String get logs_warning_label => 'Warnings';

  @override
  String get logs_neutral_label => 'Neutral';

  @override
  String get logs_recent_title => 'Recent log entries';

  @override
  String get insights_logs_empty =>
      'Complete a few sessions to generate recovery notes.';

  @override
  String get logs_error_title => 'Unable to load logs';

  @override
  String get insights_title => 'Insights';

  @override
  String get guide_insights_signal_title => 'Recovery signal';

  @override
  String get guide_insights_signal_body =>
      'This area summarizes your recent recovery rhythm after you unlock insights.';

  @override
  String get guide_insights_metrics_title => 'Key numbers';

  @override
  String get guide_insights_metrics_body =>
      'Here you will see minutes, consistency, focus zones, and Quick Fix activity.';

  @override
  String get guide_insights_patterns_title => 'Trends and patterns';

  @override
  String get guide_insights_patterns_body =>
      'Charts help you understand what improves and where tension keeps returning.';

  @override
  String get insights_journey_intelligence_title => 'Journey intelligence';

  @override
  String get insights_journey_intelligence_empty_title =>
      'Build a therapy signal';

  @override
  String get insights_journey_intelligence_body =>
      'Your current journey is building consistency, response, and completion patterns.';

  @override
  String get insights_journey_intelligence_empty_body =>
      'Start a therapy journey to connect sessions with long-term recovery progress.';

  @override
  String get insights_focus_completion_title => 'Completion';

  @override
  String get insights_focus_helpful_title => 'Helpful';

  @override
  String get insights_summary_consistency_title => 'Rhythm';

  @override
  String get insights_locked_preview_title => 'Unlock Insights';

  @override
  String get insights_locked_preview_body =>
      'Core Access shows your real trends.';

  @override
  String get insights_range_7_short => '7 days';

  @override
  String get insights_range_14_short => '14 days';

  @override
  String get insights_range_28_short => '28 days';

  @override
  String get insights_intro_title => 'Recovery signal';

  @override
  String get insights_intro_body_short =>
      'Patterns from your recent recovery work.';

  @override
  String get insights_focus_zone_title => 'Focus';

  @override
  String get insights_range_compact => 'Range';

  @override
  String get insights_streak_compact => 'Streak';

  @override
  String get insights_summary_minutes_title => 'Minutes';

  @override
  String get insights_summary_minutes_subtitle => 'Completed';

  @override
  String get insights_active_days_title => 'Active days';

  @override
  String get insights_helpful_title => 'Helpful';

  @override
  String get insights_helpful_subtitle => 'From feedback';

  @override
  String get insights_relief_title => 'Relief';

  @override
  String get insights_relief_subtitle => 'Average score';

  @override
  String get insights_recovery_minutes_title => 'Recovery Trend';

  @override
  String get insights_recovery_minutes_subtitle_short => 'Minutes over time';

  @override
  String get insights_chart_peak => 'Peak';

  @override
  String get insights_chart_average => 'Avg';

  @override
  String get insights_rhythm_title => 'Recovery Rhythm';

  @override
  String get insights_rhythm_subtitle_short => 'Recent active days';

  @override
  String get insights_rhythm_active_days => 'Active';

  @override
  String get insights_rhythm_minutes => 'Minutes';

  @override
  String get insights_patterns_title => 'Pattern Notes';

  @override
  String get insights_patterns_subtitle_short => 'Recent signals';

  @override
  String get insights_logs_action => 'View all';

  @override
  String get insights_error_title => 'Unable to load insights';

  @override
  String get pain_forearms => 'Forearms';

  @override
  String get pain_hands => 'Hands';

  @override
  String get pain_hips_glutes => 'Hips & glutes';

  @override
  String get pain_eyes => 'Eyes';

  @override
  String get session_history_locked_title => 'See your past sessions';

  @override
  String get session_history_locked_message => 'Unlock to track your recovery.';

  @override
  String get player_access_locked_title => 'Core Access required';

  @override
  String get player_access_locked_message =>
      'This session is part of Core Access. Unlock once to use the full recovery toolkit.';

  @override
  String get guide_player_header_title => 'Session progress';

  @override
  String get guide_player_header_body =>
      'This top card shows the session title and your overall progress. Tap close only when you want to leave the session.';

  @override
  String get guide_player_video_title => 'Movement demo';

  @override
  String get guide_player_video_body =>
      'Follow the video for the safe movement shape. You can expand it or mute/unmute without leaving the player.';

  @override
  String get guide_player_timer_title => 'Main timer';

  @override
  String get guide_player_timer_body =>
      'Use this large timer as the source of truth for the current step.';

  @override
  String get guide_player_instruction_title => 'Instruction card';

  @override
  String get guide_player_instruction_body =>
      'Read the short instruction here. Extra coaching, breathing, and safety notes stay compact inside this card.';

  @override
  String get guide_player_controls_title => 'Controls';

  @override
  String get guide_player_controls_body =>
      'Control the session from here: previous, replay, pause, skip, next, or finish on the last step.';

  @override
  String get guide_done_cta => 'Done';

  @override
  String get movement_pattern_setup => 'Setup';

  @override
  String get movement_pattern_assessment => 'Assessment';

  @override
  String get movement_pattern_mobility => 'Mobility';

  @override
  String get movement_pattern_stretch => 'Stretch';

  @override
  String get movement_pattern_release => 'Release';

  @override
  String get movement_pattern_activation => 'Activation';

  @override
  String get movement_pattern_strength => 'Strength';

  @override
  String get movement_pattern_endurance => 'Endurance';

  @override
  String get movement_pattern_posture => 'Posture';

  @override
  String get movement_pattern_breathing => 'Breathing';

  @override
  String get movement_pattern_cooldown => 'Cooldown';

  @override
  String get movement_pattern_habit => 'Habit';

  @override
  String get continuity_preview_cta => 'Preview';

  @override
  String get player_pre_state_subtitle_compact =>
      'Set your starting point. This takes a few seconds.';

  @override
  String get player_feedback_subtitle_compact =>
      'One quick tap helps tune your next recommendation.';

  @override
  String get player_media_expand_tooltip => 'View larger';

  @override
  String get player_media_unmute_tooltip => 'Turn sound on';

  @override
  String get player_media_mute_tooltip => 'Turn sound off';

  @override
  String get guide_dashboard_topbar_title => 'Top bar';

  @override
  String get guide_dashboard_topbar_body =>
      'Use the top bar for notifications and your account. Free members can upgrade directly from the account badge.';

  @override
  String get guide_dashboard_home_title => 'Your recovery home';

  @override
  String get guide_dashboard_home_body =>
      'Start with the smart next action, then check your recovery status, program progress, and recent activity.';

  @override
  String get guide_dashboard_bottom_nav_title => 'Bottom navigation';

  @override
  String get guide_dashboard_bottom_nav_body =>
      'Use the bottom tabs to open Training, Quick Fix, Insights, and Programs when you need deeper details.';

  @override
  String get dashboard_greeting => 'Hello';

  @override
  String get dashboard_new_quick_fix_title => 'Where do you feel tension?';

  @override
  String get dashboard_new_quick_fix_body =>
      'Tap a body area and get the best matching reset in seconds.';

  @override
  String get dashboard_quick_fix_title => 'Find your reset';

  @override
  String get dashboard_for_you_now => 'For you now';

  @override
  String get session_duration_unit_min => 'min';

  @override
  String get dashboard_continue_session => 'Continue';

  @override
  String get dashboard_start_session => 'Start';

  @override
  String get dashboard_active_program_title => 'Your program';

  @override
  String get dashboard_continue_program => 'Continue your program';

  @override
  String get dashboard_day_label => 'Day';

  @override
  String get profile_action_notifications => 'Notifications';

  @override
  String get dashboard_command_title => 'Recovery command center';

  @override
  String get dashboard_command_active_body =>
      'Your journey, recovery signal, and next action in one place.';

  @override
  String get dashboard_command_empty_body =>
      'Start a therapy journey to build a clear recovery signal.';

  @override
  String get dashboard_readiness_label => 'readiness';

  @override
  String get dashboard_helpful_label => 'Helpful';

  @override
  String get dashboard_rhythm_label => 'Rhythm';

  @override
  String get dashboard_snapshot_error_title => 'Dashboard data is unavailable';

  @override
  String get dashboard_weekly_minutes_label => 'min week';

  @override
  String get dashboard_completed_week_label => 'sessions';

  @override
  String get dashboard_run_completed => 'Completed';

  @override
  String get dashboard_run_abandoned => 'Paused';

  @override
  String get dashboard_run_started => 'Started';

  @override
  String get dashboard_programs_active_title => 'Continue your journey';

  @override
  String get dashboard_programs_title => 'Therapy journeys';

  @override
  String get common_view_all => 'View all';

  @override
  String get dashboard_program_discovery_pill_guided => 'Guided';

  @override
  String get dashboard_program_discovery_title => 'Choose a therapy path';

  @override
  String get dashboard_program_discovery_cta => 'View paths';

  @override
  String get program_active_badge => 'Active program';

  @override
  String get dashboard_programs_continue_cta => 'Continue';

  @override
  String get program_day_unit => 'missions';

  @override
  String get program_start_cta => 'Start';

  @override
  String get dashboard_saved_title => 'Saved for later';

  @override
  String get dashboard_recommended_title => 'Recommended today';

  @override
  String get dashboard_see_all => 'See all';

  @override
  String get sessions_title => 'Training';

  @override
  String get dashboard_momentum_title => 'Your momentum';

  @override
  String get dashboard_program_days_label => 'program missions';

  @override
  String get dashboard_streak_label => 'streak';

  @override
  String get dashboard_saved_count_label => 'saved';

  @override
  String get dashboard_body_focus_title => 'Need relief now?';

  @override
  String get dashboard_body_focus_body =>
      'Use Quick Fix to choose the body zone that needs attention.';

  @override
  String get dashboard_premium_title => 'Your complete recovery system';

  @override
  String get dashboard_premium_body =>
      'Guided programs, deeper insights, and every recovery session unlocked.';

  @override
  String get dashboard_premium_cta_short => 'Explore';

  @override
  String get programs_title => 'Programs';

  @override
  String get programs_browse_all_title => 'Choose your recovery path';

  @override
  String get programs_more_journeys_title => 'More programs';

  @override
  String get programs_section_subtitle =>
      'Structured plans designed for consistent progress.';

  @override
  String get programs_header_active => 'Keep your momentum';

  @override
  String get programs_header_new => 'Build a healthier workday';

  @override
  String get programs_header_body =>
      'Guided programs with a clear daily structure.';

  @override
  String get program_premium_badge => 'Premium';

  @override
  String get programs_error_title => 'Programs are temporarily unavailable';

  @override
  String get programs_error_body => 'Check your connection and try again.';

  @override
  String get programs_empty_title => 'No programs available yet';

  @override
  String get programs_empty_body => 'Pull down or refresh to check again.';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get program_detail_title => 'Program';

  @override
  String get program_switch_title => 'Switch journey?';

  @override
  String get program_start_title => 'Start this journey?';

  @override
  String get program_switch_body =>
      'Your progress in the current journey will stay saved. This journey will become your active path.';

  @override
  String get program_start_body =>
      'Your first mission will unlock now. Progress is saved after every completed mission.';

  @override
  String get program_switch_cta => 'Switch journey';

  @override
  String get program_begin_cta => 'Begin journey';

  @override
  String get program_phase_recovery => 'Recovery';

  @override
  String get program_completed_label => 'Completed';

  @override
  String get program_continue_recovery_cta => 'Continue Recovery';

  @override
  String get program_about_journey_label => 'About this journey';

  @override
  String get program_path_label => 'Recovery program';

  @override
  String get program_unlocked_label => 'Unlocked';

  @override
  String get program_no_days_title => 'No missions available yet.';

  @override
  String get program_view_full_plan_title => 'Journey map';

  @override
  String get program_sequential_hint =>
      'Choose a phase to view its missions and progress.';

  @override
  String get program_day_missing_session => 'Missing session';

  @override
  String get program_phase_start_label => 'Phase Start';

  @override
  String get program_phase_end_label => 'Phase End';

  @override
  String get program_assessment_label => 'Assessment';

  @override
  String get program_repeat_label => 'Repeat';

  @override
  String get program_today_badge => 'TODAY';

  @override
  String get program_expected_label => 'Expected';

  @override
  String get program_detail_error_title => 'This journey could not load.';

  @override
  String get program_detail_error_body =>
      'Check your connection and try again. Your mission progress is safe.';

  @override
  String get program_progress_sync_warning =>
      'Journey loaded, but progress could not sync. Some mission states may be outdated.';

  @override
  String get program_not_found_title => 'This journey is no longer available.';

  @override
  String get program_not_found_body =>
      'Return to Programs and choose another therapy journey.';

  @override
  String get access_core_badge => 'Core';

  @override
  String get sessions_load_error_title => 'Training could not load.';

  @override
  String get guide_training_sessions_title => 'Sessions are single resets';

  @override
  String get guide_training_sessions_body =>
      'Use sessions when you want one quick recovery exercise right now.';

  @override
  String get guide_training_filter_title => 'Search and filter';

  @override
  String get guide_training_filter_body =>
      'Filter by body zone, duration, intensity, or desk-friendly sessions.';

  @override
  String get common_clear => 'Clear';

  @override
  String get training_programs_title => 'Programs';

  @override
  String get training_programs_subtitle =>
      'Guided therapy journeys for structured recovery.';

  @override
  String get training_sessions_section_title => 'Sessions';

  @override
  String get training_sessions_section_subtitle =>
      'Single recovery sessions you can start anytime.';

  @override
  String get sessions_search_hint_compact => 'Search sessions';

  @override
  String get sessions_category_lower_back_hips => 'Lower back & hips';

  @override
  String get sessions_category_wrists_hands => 'Wrists & hands';

  @override
  String get sessions_sort_shortest => 'Duration: shortest';

  @override
  String get sessions_sort_alpha => 'Alphabetical';

  @override
  String get sessions_sort_short_recommended => 'Default';

  @override
  String get sessions_sort_short_shortest => 'Shortest';

  @override
  String get sessions_sort_short_az => 'A–Z';

  @override
  String get session_detail_nav_title => 'Session Detail';

  @override
  String get premium_title => 'Premium';

  @override
  String get session_detail_label => 'Session';

  @override
  String get session_detail_body_target_general => 'General';

  @override
  String get session_detail_body_targets_title => 'Body';

  @override
  String get session_detail_equipment_none => 'No equipment';

  @override
  String get session_detail_steps_title_compact => 'Steps';

  @override
  String get session_detail_safety_title => 'Safety';

  @override
  String get session_detail_safety_compact_subtitle =>
      'Check before you start.';

  @override
  String get session_detail_warning_title => 'Use caution if';

  @override
  String get session_detail_avoid_title => 'Avoid or stop if';

  @override
  String get session_detail_error_title => 'Could not load session';

  @override
  String get session_detail_error_subtitle =>
      'Something went wrong while loading this session. Please try again.';

  @override
  String get equipment_chair => 'Chair';

  @override
  String get equipment_desk => 'Desk';

  @override
  String get equipment_wall => 'Wall';

  @override
  String get equipment_towel => 'Towel';

  @override
  String get equipment_small_cushion => 'Small cushion';

  @override
  String get equipment_lumbar_roll => 'Lumbar roll';

  @override
  String get equipment_mini_band => 'Mini band';

  @override
  String get equipment_long_band => 'Resistance band';

  @override
  String get equipment_massage_ball => 'Massage ball';

  @override
  String get equipment_soft_ball => 'Soft ball';

  @override
  String get equipment_water_bottle => 'Water bottle';

  @override
  String get equipment_dowel => 'Dowel / broomstick';

  @override
  String get equipment_yoga_mat => 'Yoga mat';

  @override
  String get equipment_foam_roller => 'Foam roller';

  @override
  String get session_level_free_starter => 'Starter';

  @override
  String get session_level_therapy => 'Therapy';

  @override
  String get session_level_advanced_therapy => 'Advanced therapy';

  @override
  String get session_level_flagship => 'Flagship';

  @override
  String get saved_sessions_locked_title => 'Save your favorite sessions';

  @override
  String get saved_sessions_locked_message => 'Unlock to keep them here.';

  @override
  String get auth_callback_title => 'Finishing sign in...';

  @override
  String get auth_callback_subtitle =>
      'Please wait while your account session is prepared.';

  @override
  String get auth_terms_required =>
      'Please accept the Terms and Privacy Policy first.';

  @override
  String get auth_google_not_started => 'Google sign-in could not be started.';

  @override
  String get auth_google_unknown_error =>
      'Google sign-in failed. Please try again.';

  @override
  String get auth_apple_coming_soon => 'Apple sign-in will be added soon.';

  @override
  String get auth_reset_email_required => 'Enter your email address first.';

  @override
  String get auth_reset_email_sent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get auth_link_open_failed => 'Could not open the link.';

  @override
  String get auth_invalid_credentials => 'Email or password is incorrect.';

  @override
  String get auth_email_not_confirmed =>
      'Please confirm your email before signing in.';

  @override
  String get auth_user_already_registered =>
      'An account already exists for this email.';

  @override
  String get auth_or_email_short => 'or continue with email';

  @override
  String get auth_app_badge => 'Desk Workout';

  @override
  String get auth_sign_up_tab_short => 'Create';

  @override
  String get auth_google_short => 'Google';

  @override
  String get auth_apple_short => 'Apple';

  @override
  String get auth_toggle_password_visibility => 'Toggle password visibility';

  @override
  String get auth_forgot_password => 'Forgot password?';

  @override
  String get auth_accept_terms_text =>
      'I accept the Terms of Use and Privacy Policy.';

  @override
  String get auth_legal_note_sign_in_compact =>
      'By continuing, you agree to our legal terms.';

  @override
  String get auth_legal_note_sign_up_compact =>
      'Review our legal terms before creating your account.';

  @override
  String get auth_privacy_policy_link => 'Privacy Policy';

  @override
  String get auth_terms_of_use_link => 'Terms of Use';

  @override
  String get common_retry => 'Retry';

  @override
  String get session_detail_save_cta => 'Save';

  @override
  String get session_detail_saved_cta => 'Saved';

  @override
  String get session_detail_start_cta => 'Start session';

  @override
  String get startup_error_title => 'Startup failed';

  @override
  String get update_available_body =>
      'A new version of Desk Workout is available.';

  @override
  String get quick_fix_equipment_none => 'No extra equipment';

  @override
  String get quick_fix_equipment_towel => 'Towel';

  @override
  String get quick_fix_equipment_long_band => 'Resistance band';

  @override
  String get quick_fix_equipment_mini_band => 'Mini band';

  @override
  String get quick_fix_equipment_foam_roller => 'Foam roller';

  @override
  String get quick_fix_equipment_massage_ball => 'Massage ball';

  @override
  String get quick_fix_equipment_soft_ball => 'Soft ball';

  @override
  String get quick_fix_equipment_water_bottle => 'Water bottle';

  @override
  String get quick_fix_equipment_dowel => 'Dowel / broomstick';

  @override
  String get quick_fix_problem_forearms => 'Forearms';

  @override
  String get quick_fix_problem_hands => 'Hands & Fingers';

  @override
  String get quick_fix_problem_hips_glutes => 'Hips & Glutes';

  @override
  String get quick_fix_problem_upper_back => 'Upper Back';

  @override
  String get quick_fix_signal_equipment_based =>
      'Matches your available equipment';

  @override
  String get player_left => 'LEFT';

  @override
  String get player_more_guidance => 'More guidance';

  @override
  String get player_voice_on => 'Voice on';

  @override
  String get player_voice_off => 'Voice off';

  @override
  String get program_days_suffix => 'days';

  @override
  String program_minutes_per_day(Object count) {
    return '$count min/day';
  }

  @override
  String get program_difficulty_beginner => 'Beginner';

  @override
  String get program_difficulty_intermediate => 'Intermediate';

  @override
  String get program_difficulty_advanced => 'Advanced';

  @override
  String get program_recovery_route => 'Recovery route';

  @override
  String get insights_active_suffix => 'active';

  @override
  String get player_reps_suffix => 'reps';

  @override
  String player_step_of(Object current, Object total) {
    return 'Step $current of $total';
  }
}
