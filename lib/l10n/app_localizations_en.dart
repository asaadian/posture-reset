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
}
