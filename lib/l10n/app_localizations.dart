import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Posture Reset'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get navSessions;

  /// No description provided for @navQuickFix.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix'**
  String get navQuickFix;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get commonBackHome;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @saved_sessions_title.
  ///
  /// In en, this message translates to:
  /// **'Saved Sessions'**
  String get saved_sessions_title;

  /// No description provided for @saved_sessions_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No saved sessions yet'**
  String get saved_sessions_empty_title;

  /// No description provided for @saved_sessions_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Save sessions from the library or detail page to build your continuity list.'**
  String get saved_sessions_empty_body;

  /// No description provided for @saved_sessions_browse_cta.
  ///
  /// In en, this message translates to:
  /// **'Browse Sessions'**
  String get saved_sessions_browse_cta;

  /// No description provided for @saved_sessions_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved sessions.'**
  String get saved_sessions_error;

  /// No description provided for @session_history_title.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get session_history_title;

  /// No description provided for @session_history_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No session history yet'**
  String get session_history_empty_title;

  /// No description provided for @session_history_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Your completed and unfinished session runs will appear here.'**
  String get session_history_empty_body;

  /// No description provided for @session_history_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load session history.'**
  String get session_history_error;

  /// No description provided for @continuity_continue_title.
  ///
  /// In en, this message translates to:
  /// **'Continue Session'**
  String get continuity_continue_title;

  /// No description provided for @continuity_resume_title.
  ///
  /// In en, this message translates to:
  /// **'Resume Session'**
  String get continuity_resume_title;

  /// No description provided for @continuity_repeat_title.
  ///
  /// In en, this message translates to:
  /// **'Do It Again'**
  String get continuity_repeat_title;

  /// No description provided for @continuity_start_title.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get continuity_start_title;

  /// No description provided for @continuity_continue_cta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuity_continue_cta;

  /// No description provided for @continuity_resume_cta.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get continuity_resume_cta;

  /// No description provided for @continuity_repeat_cta.
  ///
  /// In en, this message translates to:
  /// **'Do Again'**
  String get continuity_repeat_cta;

  /// No description provided for @continuity_start_cta.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get continuity_start_cta;

  /// No description provided for @continuity_open_detail.
  ///
  /// In en, this message translates to:
  /// **'Open Detail'**
  String get continuity_open_detail;

  /// No description provided for @continuity_reason_active.
  ///
  /// In en, this message translates to:
  /// **'You still have an active recovery run.'**
  String get continuity_reason_active;

  /// No description provided for @continuity_reason_resumable.
  ///
  /// In en, this message translates to:
  /// **'You left this session unfinished and can pick it up again.'**
  String get continuity_reason_resumable;

  /// No description provided for @continuity_reason_saved.
  ///
  /// In en, this message translates to:
  /// **'This saved session is your best next continuity pick.'**
  String get continuity_reason_saved;

  /// No description provided for @continuity_reason_repeat.
  ///
  /// In en, this message translates to:
  /// **'This is the most recent session worth repeating.'**
  String get continuity_reason_repeat;

  /// No description provided for @continuity_resume_available.
  ///
  /// In en, this message translates to:
  /// **'Resume available'**
  String get continuity_resume_available;

  /// No description provided for @continuity_status_started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get continuity_status_started;

  /// No description provided for @continuity_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get continuity_status_completed;

  /// No description provided for @continuity_status_abandoned.
  ///
  /// In en, this message translates to:
  /// **'Ended early'**
  String get continuity_status_abandoned;

  /// No description provided for @continuity_label_active.
  ///
  /// In en, this message translates to:
  /// **'Active run'**
  String get continuity_label_active;

  /// No description provided for @continuity_label_resumable.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get continuity_label_resumable;

  /// No description provided for @continuity_label_repeatable.
  ///
  /// In en, this message translates to:
  /// **'Played before'**
  String get continuity_label_repeatable;

  /// No description provided for @continuity_label_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get continuity_label_saved;

  /// No description provided for @continuity_strip_title.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get continuity_strip_title;

  /// No description provided for @startupLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting app'**
  String get startupLoadingTitle;

  /// No description provided for @startupLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing app services and loading startup configuration.'**
  String get startupLoadingSubtitle;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup failed'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app could not finish startup. Check configuration and try again.'**
  String get startupErrorSubtitle;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFoundTitle;

  /// No description provided for @dashboard_hero_body.
  ///
  /// In en, this message translates to:
  /// **'Readiness first. Body signals next.'**
  String get dashboard_hero_body;

  /// No description provided for @routeNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The requested page does not exist or is no longer available.'**
  String get routeNotFoundSubtitle;

  /// No description provided for @sessions_featured_title.
  ///
  /// In en, this message translates to:
  /// **'Featured Sessions'**
  String get sessions_featured_title;

  /// No description provided for @sessions_all_results_title.
  ///
  /// In en, this message translates to:
  /// **'All Sessions'**
  String get sessions_all_results_title;

  /// No description provided for @sessions_all_results_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the complete session library with real filters and sorting.'**
  String get sessions_all_results_subtitle;

  /// No description provided for @sessions_error_title.
  ///
  /// In en, this message translates to:
  /// **'Could not load sessions'**
  String get sessions_error_title;

  /// No description provided for @sessions_error_body.
  ///
  /// In en, this message translates to:
  /// **'The session library could not be loaded. Try again.'**
  String get sessions_error_body;

  /// No description provided for @sessions_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No sessions available'**
  String get sessions_empty_title;

  /// No description provided for @sessions_empty_body.
  ///
  /// In en, this message translates to:
  /// **'No active sessions are available in the catalog right now.'**
  String get sessions_empty_body;

  /// No description provided for @sessions_no_results_title.
  ///
  /// In en, this message translates to:
  /// **'No matching sessions'**
  String get sessions_no_results_title;

  /// No description provided for @sessions_no_results_body.
  ///
  /// In en, this message translates to:
  /// **'Try a different search, category, or sort setting.'**
  String get sessions_no_results_body;

  /// No description provided for @sessions_clear_filters_cta.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get sessions_clear_filters_cta;

  /// No description provided for @sessions_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search sessions, goals, pain points, and tags...'**
  String get sessions_search_hint;

  /// No description provided for @sessions_category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sessions_category_all;

  /// No description provided for @sessions_category_neck_shoulders.
  ///
  /// In en, this message translates to:
  /// **'Neck & Shoulders'**
  String get sessions_category_neck_shoulders;

  /// No description provided for @sessions_category_upper_back.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get sessions_category_upper_back;

  /// No description provided for @sessions_category_lower_back.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get sessions_category_lower_back;

  /// No description provided for @sessions_category_wrists_forearms.
  ///
  /// In en, this message translates to:
  /// **'Wrists & Forearms'**
  String get sessions_category_wrists_forearms;

  /// No description provided for @sessions_category_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get sessions_category_focus;

  /// No description provided for @sessions_category_recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get sessions_category_recovery;

  /// No description provided for @sessions_category_quiet_desk.
  ///
  /// In en, this message translates to:
  /// **'Quiet & Desk'**
  String get sessions_category_quiet_desk;

  /// No description provided for @sessions_sort_recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sessions_sort_recommended;

  /// No description provided for @sessions_sort_duration_shortest.
  ///
  /// In en, this message translates to:
  /// **'Duration: Shortest'**
  String get sessions_sort_duration_shortest;

  /// No description provided for @sessions_sort_duration_longest.
  ///
  /// In en, this message translates to:
  /// **'Duration: Longest'**
  String get sessions_sort_duration_longest;

  /// No description provided for @sessions_sort_intensity_lowest.
  ///
  /// In en, this message translates to:
  /// **'Intensity: Lowest'**
  String get sessions_sort_intensity_lowest;

  /// No description provided for @sessions_sort_intensity_highest.
  ///
  /// In en, this message translates to:
  /// **'Intensity: Highest'**
  String get sessions_sort_intensity_highest;

  /// No description provided for @sessions_sort_alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sessions_sort_alphabetical;

  /// No description provided for @sessions_filter_silent_only.
  ///
  /// In en, this message translates to:
  /// **'Silent only'**
  String get sessions_filter_silent_only;

  /// No description provided for @sessions_filter_beginner_only.
  ///
  /// In en, this message translates to:
  /// **'Beginner only'**
  String get sessions_filter_beginner_only;

  /// No description provided for @sessions_duration_minutes_format.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sessions_duration_minutes_format(Object minutes);

  /// No description provided for @sessions_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Structured recovery sessions built for real workdays.'**
  String get sessions_intro_title;

  /// No description provided for @sessions_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Search and filter real sessions by pain point, work context, duration, and intensity.'**
  String get sessions_intro_body;

  /// No description provided for @sessions_intensity_gentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get sessions_intensity_gentle;

  /// No description provided for @sessions_intensity_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get sessions_intensity_light;

  /// No description provided for @sessions_intensity_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get sessions_intensity_moderate;

  /// No description provided for @sessions_intensity_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get sessions_intensity_strong;

  /// No description provided for @sessions_tag_silent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get sessions_tag_silent;

  /// No description provided for @sessions_tag_beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get sessions_tag_beginner;

  /// No description provided for @session_detail_start_button.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get session_detail_start_button;

  /// No description provided for @session_detail_save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get session_detail_save_button;

  /// No description provided for @session_detail_saved_button.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get session_detail_saved_button;

  /// No description provided for @session_detail_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Session saved.'**
  String get session_detail_saved_success;

  /// No description provided for @session_detail_unsaved_success.
  ///
  /// In en, this message translates to:
  /// **'Session removed from saved.'**
  String get session_detail_unsaved_success;

  /// No description provided for @session_detail_sign_in_to_save.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save sessions.'**
  String get session_detail_sign_in_to_save;

  /// No description provided for @session_detail_go_to_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get session_detail_go_to_profile;

  /// No description provided for @session_detail_save_requires_account_hint.
  ///
  /// In en, this message translates to:
  /// **'Saving requires sign-in.'**
  String get session_detail_save_requires_account_hint;

  /// No description provided for @session_detail_duration_format.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String session_detail_duration_format(Object minutes);

  /// No description provided for @session_detail_silent_friendly.
  ///
  /// In en, this message translates to:
  /// **'Silent-friendly'**
  String get session_detail_silent_friendly;

  /// No description provided for @session_detail_beginner_friendly.
  ///
  /// In en, this message translates to:
  /// **'Beginner-friendly'**
  String get session_detail_beginner_friendly;

  /// No description provided for @session_detail_goals_title.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get session_detail_goals_title;

  /// No description provided for @session_detail_compatibility_title.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get session_detail_compatibility_title;

  /// No description provided for @session_detail_modes_title.
  ///
  /// In en, this message translates to:
  /// **'Works well with'**
  String get session_detail_modes_title;

  /// No description provided for @session_detail_environment_title.
  ///
  /// In en, this message translates to:
  /// **'Best environment'**
  String get session_detail_environment_title;

  /// No description provided for @session_detail_related_title.
  ///
  /// In en, this message translates to:
  /// **'Related Sessions'**
  String get session_detail_related_title;

  /// No description provided for @session_detail_related_empty.
  ///
  /// In en, this message translates to:
  /// **'No related sessions found.'**
  String get session_detail_related_empty;

  /// No description provided for @session_detail_related_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load related sessions.'**
  String get session_detail_related_error;

  /// No description provided for @session_intensity_gentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get session_intensity_gentle;

  /// No description provided for @session_intensity_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get session_intensity_light;

  /// No description provided for @session_intensity_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get session_intensity_moderate;

  /// No description provided for @session_intensity_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get session_intensity_strong;

  /// No description provided for @session_goal_pain_relief.
  ///
  /// In en, this message translates to:
  /// **'Pain relief'**
  String get session_goal_pain_relief;

  /// No description provided for @session_goal_posture_reset.
  ///
  /// In en, this message translates to:
  /// **'Posture reset'**
  String get session_goal_posture_reset;

  /// No description provided for @session_goal_focus_prep.
  ///
  /// In en, this message translates to:
  /// **'Focus prep'**
  String get session_goal_focus_prep;

  /// No description provided for @session_goal_recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get session_goal_recovery;

  /// No description provided for @session_goal_mobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get session_goal_mobility;

  /// No description provided for @session_goal_decompression.
  ///
  /// In en, this message translates to:
  /// **'Decompression'**
  String get session_goal_decompression;

  /// No description provided for @session_mode_dad.
  ///
  /// In en, this message translates to:
  /// **'Dad Mode'**
  String get session_mode_dad;

  /// No description provided for @session_mode_night.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get session_mode_night;

  /// No description provided for @session_mode_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get session_mode_focus;

  /// No description provided for @session_mode_pain_relief.
  ///
  /// In en, this message translates to:
  /// **'Pain Relief Mode'**
  String get session_mode_pain_relief;

  /// No description provided for @session_env_desk_friendly.
  ///
  /// In en, this message translates to:
  /// **'Desk-friendly'**
  String get session_env_desk_friendly;

  /// No description provided for @session_env_office_friendly.
  ///
  /// In en, this message translates to:
  /// **'Office-friendly'**
  String get session_env_office_friendly;

  /// No description provided for @session_env_home_friendly.
  ///
  /// In en, this message translates to:
  /// **'Home-friendly'**
  String get session_env_home_friendly;

  /// No description provided for @session_env_no_mat.
  ///
  /// In en, this message translates to:
  /// **'No mat required'**
  String get session_env_no_mat;

  /// No description provided for @session_env_low_space.
  ///
  /// In en, this message translates to:
  /// **'Low-space friendly'**
  String get session_env_low_space;

  /// No description provided for @session_env_quiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet-friendly'**
  String get session_env_quiet;

  /// No description provided for @session_detail_equipment_title.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get session_detail_equipment_title;

  /// No description provided for @session_detail_saving_cta.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get session_detail_saving_cta;

  /// No description provided for @session_detail_steps_empty.
  ///
  /// In en, this message translates to:
  /// **'No step preview is available for this session yet.'**
  String get session_detail_steps_empty;

  /// No description provided for @session_detail_step_skippable.
  ///
  /// In en, this message translates to:
  /// **'Skippable'**
  String get session_detail_step_skippable;

  /// No description provided for @session_step_type_setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get session_step_type_setup;

  /// No description provided for @session_step_type_movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get session_step_type_movement;

  /// No description provided for @session_step_type_hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get session_step_type_hold;

  /// No description provided for @session_step_type_breath.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get session_step_type_breath;

  /// No description provided for @session_step_type_transition.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get session_step_type_transition;

  /// No description provided for @session_detail_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update saved session.'**
  String get session_detail_save_failed;

  /// No description provided for @session_step_type_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get session_step_type_cooldown;

  /// No description provided for @auth_page_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get auth_page_title;

  /// No description provided for @auth_sign_in_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_sign_in_title;

  /// No description provided for @auth_sign_up_title.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_sign_up_title;

  /// No description provided for @auth_sign_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save sessions and keep your recovery data with your account.'**
  String get auth_sign_in_subtitle;

  /// No description provided for @auth_sign_up_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save sessions and unlock continuity across devices.'**
  String get auth_sign_up_subtitle;

  /// No description provided for @auth_sign_in_tab.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_sign_in_tab;

  /// No description provided for @auth_sign_up_tab.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_sign_up_tab;

  /// No description provided for @auth_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email_label;

  /// No description provided for @auth_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_label;

  /// No description provided for @auth_confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get auth_confirm_password_label;

  /// No description provided for @auth_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get auth_email_required;

  /// No description provided for @auth_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get auth_email_invalid;

  /// No description provided for @auth_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get auth_password_required;

  /// No description provided for @auth_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get auth_password_too_short;

  /// No description provided for @auth_confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get auth_confirm_password_required;

  /// No description provided for @auth_confirm_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get auth_confirm_password_mismatch;

  /// No description provided for @auth_submitting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get auth_submitting;

  /// No description provided for @auth_sign_in_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_sign_in_button;

  /// No description provided for @auth_sign_up_button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_sign_up_button;

  /// No description provided for @auth_sign_in_success.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get auth_sign_in_success;

  /// No description provided for @auth_sign_up_success_signed_in.
  ///
  /// In en, this message translates to:
  /// **'Account created and signed in.'**
  String get auth_sign_up_success_signed_in;

  /// No description provided for @auth_sign_up_check_email.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm your account.'**
  String get auth_sign_up_check_email;

  /// No description provided for @auth_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get auth_unknown_error;

  /// No description provided for @auth_signed_out_success.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get auth_signed_out_success;

  /// No description provided for @profile_sign_out_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_sign_out_tooltip;

  /// No description provided for @profile_account_access_section_title.
  ///
  /// In en, this message translates to:
  /// **'Account Access'**
  String get profile_account_access_section_title;

  /// No description provided for @profile_account_access_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save sessions and keep your account data connected.'**
  String get profile_account_access_section_subtitle;

  /// No description provided for @profile_account_sign_in_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get profile_account_sign_in_title;

  /// No description provided for @profile_account_sign_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use email and password to unlock saved sessions and account continuity.'**
  String get profile_account_sign_in_subtitle;

  /// No description provided for @profile_account_manage_title.
  ///
  /// In en, this message translates to:
  /// **'Manage account access'**
  String get profile_account_manage_title;

  /// No description provided for @profile_account_signed_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get profile_account_signed_in_subtitle;

  /// No description provided for @profile_status_plan_signed_in_value.
  ///
  /// In en, this message translates to:
  /// **'Account Ready'**
  String get profile_status_plan_signed_in_value;

  /// No description provided for @profile_status_plan_signed_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Session saving available'**
  String get profile_status_plan_signed_in_subtitle;

  /// No description provided for @profile_account_guest_name.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_account_guest_name;

  /// No description provided for @profile_account_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save sessions and keep your progress connected.'**
  String get profile_account_guest_subtitle;

  /// No description provided for @profile_account_guest_initial.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get profile_account_guest_initial;

  /// No description provided for @profile_account_signed_in_name.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_account_signed_in_name;

  /// No description provided for @profile_account_tag_signed_in.
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get profile_account_tag_signed_in;

  /// No description provided for @profile_account_tag_session_save.
  ///
  /// In en, this message translates to:
  /// **'Session Saving Enabled'**
  String get profile_account_tag_session_save;

  /// No description provided for @profile_account_tag_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_account_tag_guest;

  /// No description provided for @profile_account_tag_sign_in_needed.
  ///
  /// In en, this message translates to:
  /// **'Sign In Required for Save'**
  String get profile_account_tag_sign_in_needed;

  /// No description provided for @profile_account_sign_in_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profile_account_sign_in_button;

  /// No description provided for @profile_account_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get profile_account_create_button;

  /// No description provided for @profile_account_sign_out_button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_account_sign_out_button;

  /// No description provided for @profile_preferences_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Current app defaults that shape recommendations and quick session suggestions.'**
  String get profile_preferences_section_subtitle;

  /// No description provided for @profile_status_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Current account readiness and session-saving availability.'**
  String get profile_status_section_subtitle;

  /// No description provided for @profile_status_account_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_status_account_title;

  /// No description provided for @profile_status_account_signed_in.
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get profile_status_account_signed_in;

  /// No description provided for @profile_status_account_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_status_account_guest;

  /// No description provided for @profile_status_account_signed_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account session is active.'**
  String get profile_status_account_signed_in_subtitle;

  /// No description provided for @profile_status_account_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to unlock saved sessions.'**
  String get profile_status_account_guest_subtitle;

  /// No description provided for @profile_status_session_save_title.
  ///
  /// In en, this message translates to:
  /// **'Session Saving'**
  String get profile_status_session_save_title;

  /// No description provided for @profile_status_session_save_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get profile_status_session_save_enabled;

  /// No description provided for @profile_status_session_save_disabled.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get profile_status_session_save_disabled;

  /// No description provided for @profile_status_session_save_enabled_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved sessions are available on this account.'**
  String get profile_status_session_save_enabled_subtitle;

  /// No description provided for @profile_status_session_save_disabled_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in is required before sessions can be saved.'**
  String get profile_status_session_save_disabled_subtitle;

  /// No description provided for @profile_status_plan_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium not active.'**
  String get profile_status_plan_subtitle;

  /// No description provided for @settings_language_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settings_language_sheet_title;

  /// No description provided for @settings_language_sheet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply a language for the whole app.'**
  String get settings_language_sheet_subtitle;

  /// No description provided for @settings_language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_language_german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settings_language_german;

  /// No description provided for @settings_language_persian.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get settings_language_persian;

  /// No description provided for @session_player_title.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get session_player_title;

  /// No description provided for @player_close_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Close player'**
  String get player_close_tooltip;

  /// No description provided for @player_progress_title.
  ///
  /// In en, this message translates to:
  /// **'Session Progress'**
  String get player_progress_title;

  /// No description provided for @player_step_label_prefix.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get player_step_label_prefix;

  /// No description provided for @player_step_label_empty.
  ///
  /// In en, this message translates to:
  /// **'No steps'**
  String get player_step_label_empty;

  /// No description provided for @player_current_step_label.
  ///
  /// In en, this message translates to:
  /// **'Current Step'**
  String get player_current_step_label;

  /// No description provided for @player_step_type_label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get player_step_type_label;

  /// No description provided for @player_step_duration_label.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get player_step_duration_label;

  /// No description provided for @player_step_skippable_label.
  ///
  /// In en, this message translates to:
  /// **'Skippable'**
  String get player_step_skippable_label;

  /// No description provided for @player_target_label.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get player_target_label;

  /// No description provided for @player_terminal_title.
  ///
  /// In en, this message translates to:
  /// **'Live Status'**
  String get player_terminal_title;

  /// No description provided for @player_pause_cta.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get player_pause_cta;

  /// No description provided for @player_resume_cta.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get player_resume_cta;

  /// No description provided for @player_previous_cta.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get player_previous_cta;

  /// No description provided for @player_next_cta.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get player_next_cta;

  /// No description provided for @player_skip_cta.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get player_skip_cta;

  /// No description provided for @player_replay_cta.
  ///
  /// In en, this message translates to:
  /// **'Replay Step'**
  String get player_replay_cta;

  /// No description provided for @player_finish_cta.
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get player_finish_cta;

  /// No description provided for @player_exit_title.
  ///
  /// In en, this message translates to:
  /// **'End session?'**
  String get player_exit_title;

  /// No description provided for @player_exit_message.
  ///
  /// In en, this message translates to:
  /// **'Your current session will be closed and progress will be saved as an incomplete run.'**
  String get player_exit_message;

  /// No description provided for @player_exit_cancel_cta.
  ///
  /// In en, this message translates to:
  /// **'Keep session'**
  String get player_exit_cancel_cta;

  /// No description provided for @player_exit_confirm_cta.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get player_exit_confirm_cta;

  /// No description provided for @player_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get player_not_found_title;

  /// No description provided for @player_not_found_message.
  ///
  /// In en, this message translates to:
  /// **'The requested session could not be found or is no longer available.'**
  String get player_not_found_message;

  /// No description provided for @player_no_steps_title.
  ///
  /// In en, this message translates to:
  /// **'No steps available'**
  String get player_no_steps_title;

  /// No description provided for @player_no_steps_message.
  ///
  /// In en, this message translates to:
  /// **'This session does not contain any playable steps yet.'**
  String get player_no_steps_message;

  /// No description provided for @player_error_title.
  ///
  /// In en, this message translates to:
  /// **'Could not start player'**
  String get player_error_title;

  /// No description provided for @player_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading this session.'**
  String get player_error_subtitle;

  /// No description provided for @player_back_cta.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get player_back_cta;

  /// No description provided for @player_loading_title.
  ///
  /// In en, this message translates to:
  /// **'Preparing player...'**
  String get player_loading_title;

  /// No description provided for @player_auth_required_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get player_auth_required_title;

  /// No description provided for @player_auth_required_message.
  ///
  /// In en, this message translates to:
  /// **'You need an account to start and track session runs.'**
  String get player_auth_required_message;

  /// No description provided for @player_auth_required_cta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get player_auth_required_cta;

  /// No description provided for @player_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get player_status_completed;

  /// No description provided for @player_status_running_log.
  ///
  /// In en, this message translates to:
  /// **'[RUN] session is active'**
  String get player_status_running_log;

  /// No description provided for @player_status_paused_log.
  ///
  /// In en, this message translates to:
  /// **'[PAUSE] session is currently paused'**
  String get player_status_paused_log;

  /// No description provided for @player_status_completed_log.
  ///
  /// In en, this message translates to:
  /// **'[DONE] session completed successfully'**
  String get player_status_completed_log;

  /// No description provided for @player_next_step_log_prefix.
  ///
  /// In en, this message translates to:
  /// **'[NEXT]'**
  String get player_next_step_log_prefix;

  /// No description provided for @player_runtime_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Runtime Summary'**
  String get player_runtime_summary_title;

  /// No description provided for @player_runtime_elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get player_runtime_elapsed;

  /// No description provided for @player_runtime_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get player_runtime_remaining;

  /// No description provided for @player_runtime_step_remaining.
  ///
  /// In en, this message translates to:
  /// **'Step Remaining'**
  String get player_runtime_step_remaining;

  /// No description provided for @player_breath_cue_title.
  ///
  /// In en, this message translates to:
  /// **'Breathing Cue'**
  String get player_breath_cue_title;

  /// No description provided for @player_safety_note_title.
  ///
  /// In en, this message translates to:
  /// **'Safety Note'**
  String get player_safety_note_title;

  /// No description provided for @player_completion_title.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get player_completion_title;

  /// No description provided for @player_completion_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your run has been saved successfully.'**
  String get player_completion_subtitle;

  /// No description provided for @player_completion_steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get player_completion_steps;

  /// No description provided for @player_completion_total_time.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get player_completion_total_time;

  /// No description provided for @player_completion_back_to_detail.
  ///
  /// In en, this message translates to:
  /// **'Back to Session Detail'**
  String get player_completion_back_to_detail;

  /// No description provided for @player_media_placeholder_chip.
  ///
  /// In en, this message translates to:
  /// **'Movement Preview'**
  String get player_media_placeholder_chip;

  /// No description provided for @player_media_placeholder_body_short.
  ///
  /// In en, this message translates to:
  /// **'Video or GIF guidance will appear here for this step.'**
  String get player_media_placeholder_body_short;

  /// No description provided for @player_media_placeholder_body.
  ///
  /// In en, this message translates to:
  /// **'Video or GIF guidance will appear here for this step. The player layout is already ready for real movement media.'**
  String get player_media_placeholder_body;

  /// No description provided for @player_completion_body_impact_title.
  ///
  /// In en, this message translates to:
  /// **'What changed in this session'**
  String get player_completion_body_impact_title;

  /// No description provided for @player_completion_effect_release.
  ///
  /// In en, this message translates to:
  /// **'Mobility + release'**
  String get player_completion_effect_release;

  /// No description provided for @player_completion_effect_reset.
  ///
  /// In en, this message translates to:
  /// **'Posture reset'**
  String get player_completion_effect_reset;

  /// No description provided for @session_detail_back_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get session_detail_back_tooltip;

  /// No description provided for @player_completion_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get player_completion_close;

  /// No description provided for @quick_fix_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix'**
  String get quick_fix_title;

  /// No description provided for @quick_fix_history_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Recent quick fixes'**
  String get quick_fix_history_tooltip;

  /// No description provided for @quick_fix_loading_title.
  ///
  /// In en, this message translates to:
  /// **'Preparing Quick Fix…'**
  String get quick_fix_loading_title;

  /// No description provided for @quick_fix_error_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Quick Fix'**
  String get quick_fix_error_title;

  /// No description provided for @quick_fix_error_body.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get quick_fix_error_body;

  /// No description provided for @quick_fix_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No recommendation available'**
  String get quick_fix_empty_title;

  /// No description provided for @quick_fix_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Adjust your current context to generate a live recommendation.'**
  String get quick_fix_empty_body;

  /// No description provided for @quick_fix_hero_eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Recovery Launcher'**
  String get quick_fix_hero_eyebrow;

  /// No description provided for @quick_fix_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Find the right session for your body state in seconds.'**
  String get quick_fix_hero_title;

  /// No description provided for @quick_fix_hero_body.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix turns your current pain point, time window, energy, and environment into a real session recommendation from the live catalog.'**
  String get quick_fix_hero_body;

  /// No description provided for @quick_fix_hero_stat_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast Match'**
  String get quick_fix_hero_stat_fast;

  /// No description provided for @quick_fix_hero_stat_silent.
  ///
  /// In en, this message translates to:
  /// **'Quiet Context'**
  String get quick_fix_hero_stat_silent;

  /// No description provided for @quick_fix_hero_stat_personalized.
  ///
  /// In en, this message translates to:
  /// **'Live Personalization'**
  String get quick_fix_hero_stat_personalized;

  /// No description provided for @quick_fix_problem_section_title.
  ///
  /// In en, this message translates to:
  /// **'What needs help right now?'**
  String get quick_fix_problem_section_title;

  /// No description provided for @quick_fix_problem_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the pain point or reset target that matters most.'**
  String get quick_fix_problem_section_subtitle;

  /// No description provided for @quick_fix_context_section_title.
  ///
  /// In en, this message translates to:
  /// **'Time + environment'**
  String get quick_fix_context_section_title;

  /// No description provided for @quick_fix_context_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the suggestion realistic for your current setup.'**
  String get quick_fix_context_section_subtitle;

  /// No description provided for @quick_fix_state_section_title.
  ///
  /// In en, this message translates to:
  /// **'Energy + mode'**
  String get quick_fix_state_section_title;

  /// No description provided for @quick_fix_state_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shape the recommendation around how intense and contextual it should feel.'**
  String get quick_fix_state_section_subtitle;

  /// No description provided for @quick_fix_recommendation_section_title.
  ///
  /// In en, this message translates to:
  /// **'Recommended Session'**
  String get quick_fix_recommendation_section_title;

  /// No description provided for @quick_fix_recommendation_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The engine updates the session match from your current body context.'**
  String get quick_fix_recommendation_section_subtitle;

  /// No description provided for @quick_fix_recommendation_missing.
  ///
  /// In en, this message translates to:
  /// **'No recommendation available yet.'**
  String get quick_fix_recommendation_missing;

  /// No description provided for @quick_fix_primary_match_label.
  ///
  /// In en, this message translates to:
  /// **'Best Match Right Now'**
  String get quick_fix_primary_match_label;

  /// No description provided for @quick_fix_reasoning_default.
  ///
  /// In en, this message translates to:
  /// **'Recommended because it strongly matches your current problem, time window, and environment.'**
  String get quick_fix_reasoning_default;

  /// No description provided for @quick_fix_more_matches_title.
  ///
  /// In en, this message translates to:
  /// **'Other strong matches'**
  String get quick_fix_more_matches_title;

  /// No description provided for @quick_fix_start_now_cta.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get quick_fix_start_now_cta;

  /// No description provided for @quick_fix_view_details_cta.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get quick_fix_view_details_cta;

  /// No description provided for @quick_fix_silent_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Silent Mode'**
  String get quick_fix_silent_mode_title;

  /// No description provided for @quick_fix_problem_neck.
  ///
  /// In en, this message translates to:
  /// **'Neck Pain'**
  String get quick_fix_problem_neck;

  /// No description provided for @quick_fix_problem_shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Tightness'**
  String get quick_fix_problem_shoulder;

  /// No description provided for @quick_fix_problem_wrist.
  ///
  /// In en, this message translates to:
  /// **'Wrist Pain'**
  String get quick_fix_problem_wrist;

  /// No description provided for @quick_fix_problem_back.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get quick_fix_problem_back;

  /// No description provided for @quick_fix_problem_eye.
  ///
  /// In en, this message translates to:
  /// **'Eye Strain'**
  String get quick_fix_problem_eye;

  /// No description provided for @quick_fix_problem_stress.
  ///
  /// In en, this message translates to:
  /// **'Stress Reset'**
  String get quick_fix_problem_stress;

  /// No description provided for @quick_fix_time_2.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get quick_fix_time_2;

  /// No description provided for @quick_fix_time_4.
  ///
  /// In en, this message translates to:
  /// **'4 min'**
  String get quick_fix_time_4;

  /// No description provided for @quick_fix_time_6.
  ///
  /// In en, this message translates to:
  /// **'6 min'**
  String get quick_fix_time_6;

  /// No description provided for @quick_fix_time_10.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get quick_fix_time_10;

  /// No description provided for @quick_fix_location_desk.
  ///
  /// In en, this message translates to:
  /// **'Desk'**
  String get quick_fix_location_desk;

  /// No description provided for @quick_fix_location_chair.
  ///
  /// In en, this message translates to:
  /// **'Chair'**
  String get quick_fix_location_chair;

  /// No description provided for @quick_fix_location_standing.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get quick_fix_location_standing;

  /// No description provided for @quick_fix_location_floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get quick_fix_location_floor;

  /// No description provided for @quick_fix_location_bedside.
  ///
  /// In en, this message translates to:
  /// **'Bedside'**
  String get quick_fix_location_bedside;

  /// No description provided for @quick_fix_energy_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get quick_fix_energy_low;

  /// No description provided for @quick_fix_energy_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get quick_fix_energy_medium;

  /// No description provided for @quick_fix_energy_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get quick_fix_energy_high;

  /// No description provided for @quick_fix_mode_dad.
  ///
  /// In en, this message translates to:
  /// **'Dad Mode'**
  String get quick_fix_mode_dad;

  /// No description provided for @quick_fix_mode_night.
  ///
  /// In en, this message translates to:
  /// **'Night Coder'**
  String get quick_fix_mode_night;

  /// No description provided for @quick_fix_mode_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get quick_fix_mode_focus;

  /// No description provided for @quick_fix_mode_pain_relief.
  ///
  /// In en, this message translates to:
  /// **'Pain Relief'**
  String get quick_fix_mode_pain_relief;

  /// No description provided for @player_pre_state_title.
  ///
  /// In en, this message translates to:
  /// **'Quick check-in before you start'**
  String get player_pre_state_title;

  /// No description provided for @player_pre_state_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture a few signals before this session so progress and outcomes can be tracked better.'**
  String get player_pre_state_subtitle;

  /// No description provided for @player_pre_state_energy_title.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get player_pre_state_energy_title;

  /// No description provided for @player_pre_state_stress_title.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get player_pre_state_stress_title;

  /// No description provided for @player_pre_state_focus_title.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get player_pre_state_focus_title;

  /// No description provided for @player_pre_state_intent_title.
  ///
  /// In en, this message translates to:
  /// **'Intent'**
  String get player_pre_state_intent_title;

  /// No description provided for @player_pre_state_pain_areas_title.
  ///
  /// In en, this message translates to:
  /// **'Pain areas'**
  String get player_pre_state_pain_areas_title;

  /// No description provided for @player_pre_state_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get player_pre_state_skip;

  /// No description provided for @player_pre_state_start_cta.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get player_pre_state_start_cta;

  /// No description provided for @player_feedback_title.
  ///
  /// In en, this message translates to:
  /// **'How did this session feel?'**
  String get player_feedback_title;

  /// No description provided for @player_feedback_abandoned_title.
  ///
  /// In en, this message translates to:
  /// **'Before you leave, how did this session feel?'**
  String get player_feedback_abandoned_title;

  /// No description provided for @player_feedback_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get player_feedback_summary_title;

  /// No description provided for @player_feedback_abandoned_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Session ended early'**
  String get player_feedback_abandoned_summary_title;

  /// No description provided for @player_feedback_helped_title.
  ///
  /// In en, this message translates to:
  /// **'Did this help?'**
  String get player_feedback_helped_title;

  /// No description provided for @player_feedback_tension_title.
  ///
  /// In en, this message translates to:
  /// **'Tension'**
  String get player_feedback_tension_title;

  /// No description provided for @player_feedback_pain_title.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get player_feedback_pain_title;

  /// No description provided for @player_feedback_energy_title.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get player_feedback_energy_title;

  /// No description provided for @player_feedback_fit_title.
  ///
  /// In en, this message translates to:
  /// **'Session fit'**
  String get player_feedback_fit_title;

  /// No description provided for @player_feedback_repeat_title.
  ///
  /// In en, this message translates to:
  /// **'Would you repeat this session?'**
  String get player_feedback_repeat_title;

  /// No description provided for @player_feedback_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get player_feedback_yes;

  /// No description provided for @player_feedback_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get player_feedback_no;

  /// No description provided for @player_feedback_repeat_yes.
  ///
  /// In en, this message translates to:
  /// **'Would repeat'**
  String get player_feedback_repeat_yes;

  /// No description provided for @player_feedback_repeat_no.
  ///
  /// In en, this message translates to:
  /// **'Not likely'**
  String get player_feedback_repeat_no;

  /// No description provided for @player_feedback_submit.
  ///
  /// In en, this message translates to:
  /// **'Save feedback'**
  String get player_feedback_submit;

  /// No description provided for @player_feedback_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get player_feedback_close;

  /// No description provided for @common_level_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get common_level_low;

  /// No description provided for @common_level_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get common_level_medium;

  /// No description provided for @common_level_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get common_level_high;

  /// No description provided for @common_delta_worse.
  ///
  /// In en, this message translates to:
  /// **'Worse'**
  String get common_delta_worse;

  /// No description provided for @common_delta_same.
  ///
  /// In en, this message translates to:
  /// **'Same'**
  String get common_delta_same;

  /// No description provided for @common_delta_better.
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get common_delta_better;

  /// No description provided for @common_fit_poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get common_fit_poor;

  /// No description provided for @common_fit_okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get common_fit_okay;

  /// No description provided for @common_fit_great.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get common_fit_great;

  /// No description provided for @intent_relief.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get intent_relief;

  /// No description provided for @intent_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get intent_reset;

  /// No description provided for @intent_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get intent_focus;

  /// No description provided for @intent_unwind.
  ///
  /// In en, this message translates to:
  /// **'Unwind'**
  String get intent_unwind;

  /// No description provided for @pain_neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get pain_neck;

  /// No description provided for @pain_shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get pain_shoulders;

  /// No description provided for @pain_upper_back.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get pain_upper_back;

  /// No description provided for @pain_lower_back.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get pain_lower_back;

  /// No description provided for @pain_wrists.
  ///
  /// In en, this message translates to:
  /// **'Wrists'**
  String get pain_wrists;

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @dashboard_error_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard'**
  String get dashboard_error_title;

  /// No description provided for @dashboard_error_body.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get dashboard_error_body;

  /// No description provided for @dashboard_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dashboard_error_retry;

  /// No description provided for @dashboard_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No dashboard data yet'**
  String get dashboard_empty_title;

  /// No description provided for @dashboard_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Complete a session or launch a Quick Fix to populate your dashboard.'**
  String get dashboard_empty_body;

  /// No description provided for @dashboard_empty_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dashboard_empty_refresh;

  /// No description provided for @dashboard_hero_overline.
  ///
  /// In en, this message translates to:
  /// **'Recovery Command Center'**
  String get dashboard_hero_overline;

  /// No description provided for @dashboard_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Command Center'**
  String get dashboard_hero_title;

  /// No description provided for @dashboard_hero_body_with_next.
  ///
  /// In en, this message translates to:
  /// **'Track your state, review momentum, and launch the next best recovery session without leaving the dashboard.'**
  String get dashboard_hero_body_with_next;

  /// No description provided for @dashboard_hero_start_next.
  ///
  /// In en, this message translates to:
  /// **'Start Next Session'**
  String get dashboard_hero_start_next;

  /// No description provided for @dashboard_hero_quick_fix.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix'**
  String get dashboard_hero_quick_fix;

  /// No description provided for @dashboard_hero_body_map.
  ///
  /// In en, this message translates to:
  /// **'Body Map'**
  String get dashboard_hero_body_map;

  /// No description provided for @dashboard_readiness_title.
  ///
  /// In en, this message translates to:
  /// **'Readiness Score'**
  String get dashboard_readiness_title;

  /// No description provided for @dashboard_state_energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get dashboard_state_energy;

  /// No description provided for @dashboard_state_stress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get dashboard_state_stress;

  /// No description provided for @dashboard_state_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get dashboard_state_focus;

  /// No description provided for @dashboard_state_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get dashboard_state_unknown;

  /// No description provided for @dashboard_minutes_week.
  ///
  /// In en, this message translates to:
  /// **'Minutes This Week'**
  String get dashboard_minutes_week;

  /// No description provided for @dashboard_completed_week.
  ///
  /// In en, this message translates to:
  /// **'Completed Sessions'**
  String get dashboard_completed_week;

  /// No description provided for @dashboard_quickfix_week.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix Starts'**
  String get dashboard_quickfix_week;

  /// No description provided for @dashboard_body_intelligence_title.
  ///
  /// In en, this message translates to:
  /// **'Body Intelligence'**
  String get dashboard_body_intelligence_title;

  /// No description provided for @dashboard_body_intelligence_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Dominant zones, recent recovery quality, and where your body asks for attention most often.'**
  String get dashboard_body_intelligence_subtitle;

  /// No description provided for @dashboard_help_rate.
  ///
  /// In en, this message translates to:
  /// **'Help Rate'**
  String get dashboard_help_rate;

  /// No description provided for @dashboard_consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get dashboard_consistency;

  /// No description provided for @dashboard_dominant_zone.
  ///
  /// In en, this message translates to:
  /// **'Dominant Zone'**
  String get dashboard_dominant_zone;

  /// No description provided for @dashboard_zone_unknown.
  ///
  /// In en, this message translates to:
  /// **'No clear zone yet'**
  String get dashboard_zone_unknown;

  /// No description provided for @dashboard_empty_body_zones.
  ///
  /// In en, this message translates to:
  /// **'Body zone patterns will appear after more tracked runs.'**
  String get dashboard_empty_body_zones;

  /// No description provided for @dashboard_trends_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Trends'**
  String get dashboard_trends_title;

  /// No description provided for @dashboard_trends_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A visual read on how much recovery time you are logging and how helpful those sessions feel.'**
  String get dashboard_trends_subtitle;

  /// No description provided for @dashboard_chart_minutes_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Minutes'**
  String get dashboard_chart_minutes_title;

  /// No description provided for @dashboard_chart_relief_title.
  ///
  /// In en, this message translates to:
  /// **'Relief Quality'**
  String get dashboard_chart_relief_title;

  /// No description provided for @dashboard_heatmap_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Heatmap'**
  String get dashboard_heatmap_title;

  /// No description provided for @dashboard_heatmap_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A rolling view of how consistently your recovery system has been active over the last three weeks.'**
  String get dashboard_heatmap_subtitle;

  /// No description provided for @dashboard_recent_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Recovery Runs'**
  String get dashboard_recent_runs_title;

  /// No description provided for @dashboard_recent_runs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A compact timeline of what you ran most recently, how it ended, and where it came from.'**
  String get dashboard_recent_runs_subtitle;

  /// No description provided for @dashboard_empty_recent_runs.
  ///
  /// In en, this message translates to:
  /// **'Recent session runs will appear here.'**
  String get dashboard_empty_recent_runs;

  /// No description provided for @dashboard_body_map_cta_title.
  ///
  /// In en, this message translates to:
  /// **'Inspect active tension zones'**
  String get dashboard_body_map_cta_title;

  /// No description provided for @dashboard_body_map_cta_body.
  ///
  /// In en, this message translates to:
  /// **'Open the body map to review active pain areas, see what has improved, and hand off directly into the next useful session.'**
  String get dashboard_body_map_cta_body;

  /// No description provided for @dashboard_open_body_map.
  ///
  /// In en, this message translates to:
  /// **'Open Body Map'**
  String get dashboard_open_body_map;

  /// No description provided for @dashboard_next_session_reason_quick_fix.
  ///
  /// In en, this message translates to:
  /// **'Recommended from your latest Quick Fix context'**
  String get dashboard_next_session_reason_quick_fix;

  /// No description provided for @dashboard_next_session_reason_resume.
  ///
  /// In en, this message translates to:
  /// **'A strong fit based on your recent activity'**
  String get dashboard_next_session_reason_resume;

  /// No description provided for @update_later_cta.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get update_later_cta;

  /// No description provided for @update_now_cta.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_now_cta;

  /// No description provided for @notification_permission_prompt_title.
  ///
  /// In en, this message translates to:
  /// **'Enable recovery reminders?'**
  String get notification_permission_prompt_title;

  /// No description provided for @notification_permission_prompt_body.
  ///
  /// In en, this message translates to:
  /// **'Get one gentle daily reminder for a quick posture reset.'**
  String get notification_permission_prompt_body;

  /// No description provided for @common_not_now.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get common_not_now;

  /// No description provided for @notification_enable_cta.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get notification_enable_cta;

  /// No description provided for @guide_skip_cta.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get guide_skip_cta;

  /// No description provided for @guide_got_it_cta.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get guide_got_it_cta;

  /// No description provided for @guide_next_cta.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get guide_next_cta;

  /// No description provided for @startup_error_body.
  ///
  /// In en, this message translates to:
  /// **'The app could not finish startup. Please check your connection and try again.'**
  String get startup_error_body;

  /// No description provided for @startup_error_retry_cta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startup_error_retry_cta;

  /// No description provided for @nav_training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get nav_training;

  /// No description provided for @nav_programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get nav_programs;

  /// No description provided for @notification_center_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_center_title;

  /// No description provided for @notification_center_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh reminders'**
  String get notification_center_refresh;

  /// No description provided for @notification_center_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notification_center_mark_all_read;

  /// No description provided for @notification_center_error_title.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get notification_center_error_title;

  /// No description provided for @notification_center_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled'**
  String get notification_center_empty_title;

  /// No description provided for @notification_center_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Turn Recovery reminders on in Settings, then pull down here to refresh.'**
  String get notification_center_empty_body;

  /// No description provided for @notification_center_header_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery reminders'**
  String get notification_center_header_title;

  /// No description provided for @notification_center_status_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get notification_center_status_upcoming;

  /// No description provided for @notification_center_status_opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get notification_center_status_opened;

  /// No description provided for @notification_center_status_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notification_center_status_new;

  /// No description provided for @notification_center_status_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get notification_center_status_scheduled;

  /// No description provided for @quick_fix_page_step_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose an area, then start your session'**
  String get quick_fix_page_step_hint;

  /// No description provided for @guide_quick_fix_body_title.
  ///
  /// In en, this message translates to:
  /// **'Tap the body'**
  String get guide_quick_fix_body_title;

  /// No description provided for @guide_quick_fix_body_body.
  ///
  /// In en, this message translates to:
  /// **'Pick the area that feels tight. The app will focus the recommendation there.'**
  String get guide_quick_fix_body_body;

  /// No description provided for @guide_quick_fix_filters_title.
  ///
  /// In en, this message translates to:
  /// **'Set simple filters'**
  String get guide_quick_fix_filters_title;

  /// No description provided for @guide_quick_fix_filters_body.
  ///
  /// In en, this message translates to:
  /// **'Choose time and available equipment. Keep it simple.'**
  String get guide_quick_fix_filters_body;

  /// No description provided for @guide_quick_fix_match_title.
  ///
  /// In en, this message translates to:
  /// **'Get a match'**
  String get guide_quick_fix_match_title;

  /// No description provided for @guide_quick_fix_match_body.
  ///
  /// In en, this message translates to:
  /// **'Tap Find Match to get one session that fits your current situation.'**
  String get guide_quick_fix_match_body;

  /// No description provided for @quick_fix_match_session_cta.
  ///
  /// In en, this message translates to:
  /// **'Find Match'**
  String get quick_fix_match_session_cta;

  /// No description provided for @quick_fix_selected_target_empty.
  ///
  /// In en, this message translates to:
  /// **'Selected body'**
  String get quick_fix_selected_target_empty;

  /// No description provided for @quick_fix_matched_title.
  ///
  /// In en, this message translates to:
  /// **'Matched session'**
  String get quick_fix_matched_title;

  /// No description provided for @quick_fix_matching_title.
  ///
  /// In en, this message translates to:
  /// **'Matching your reset…'**
  String get quick_fix_matching_title;

  /// No description provided for @quick_fix_selected_count_suffix.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get quick_fix_selected_count_suffix;

  /// No description provided for @quick_fix_equipment_title.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get quick_fix_equipment_title;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @quick_fix_body_map_hint_step.
  ///
  /// In en, this message translates to:
  /// **'Tap body point'**
  String get quick_fix_body_map_hint_step;

  /// No description provided for @body_map_front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get body_map_front;

  /// No description provided for @body_map_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get body_map_back;

  /// No description provided for @quick_fix_recommended_badge.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get quick_fix_recommended_badge;

  /// No description provided for @quick_fix_start_session.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get quick_fix_start_session;

  /// No description provided for @quick_fix_alternatives_title.
  ///
  /// In en, this message translates to:
  /// **'Other good options'**
  String get quick_fix_alternatives_title;

  /// No description provided for @quick_fix_none_selected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get quick_fix_none_selected;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get profile_settings_tooltip;

  /// No description provided for @profile_primary_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue recovery'**
  String get profile_primary_continue;

  /// No description provided for @profile_primary_open_sessions.
  ///
  /// In en, this message translates to:
  /// **'Start training'**
  String get profile_primary_open_sessions;

  /// No description provided for @profile_sign_in_cta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profile_sign_in_cta;

  /// No description provided for @profile_sync_connected.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get profile_sync_connected;

  /// No description provided for @profile_sync_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get profile_sync_local;

  /// No description provided for @profile_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guest profile'**
  String get profile_guest_subtitle;

  /// No description provided for @profile_metric_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profile_metric_saved;

  /// No description provided for @profile_metric_runs.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get profile_metric_runs;

  /// No description provided for @profile_metric_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get profile_metric_status;

  /// No description provided for @profile_action_premium.
  ///
  /// In en, this message translates to:
  /// **'Core Access'**
  String get profile_action_premium;

  /// No description provided for @profile_action_premium_subtitle_large.
  ///
  /// In en, this message translates to:
  /// **'Unlock all sessions, programs, Quick Fix, and insights.'**
  String get profile_action_premium_subtitle_large;

  /// No description provided for @profile_action_saved_short.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profile_action_saved_short;

  /// No description provided for @profile_action_saved_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get profile_action_saved_subtitle_short;

  /// No description provided for @session_history_title_compact.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get session_history_title_compact;

  /// No description provided for @profile_action_history_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get profile_action_history_subtitle_short;

  /// No description provided for @profile_action_programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get profile_action_programs;

  /// No description provided for @profile_action_programs_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get profile_action_programs_subtitle_short;

  /// No description provided for @profile_account_section_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_account_section_title;

  /// No description provided for @profile_account_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile and app controls.'**
  String get profile_account_section_subtitle;

  /// No description provided for @profile_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_edit_title;

  /// No description provided for @profile_edit_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Name and photo'**
  String get profile_edit_subtitle;

  /// No description provided for @profile_action_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_action_settings;

  /// No description provided for @profile_action_settings_subtitle_compact.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profile_action_settings_subtitle_compact;

  /// No description provided for @profile_sign_out_cta.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profile_sign_out_cta;

  /// No description provided for @profile_create_account_cta.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get profile_create_account_cta;

  /// No description provided for @profile_sign_out_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this device'**
  String get profile_sign_out_subtitle;

  /// No description provided for @profile_create_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your progress'**
  String get profile_create_account_subtitle;

  /// No description provided for @profile_danger_zone_title.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get profile_danger_zone_title;

  /// No description provided for @profile_danger_zone_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Account and data removal.'**
  String get profile_danger_zone_subtitle;

  /// No description provided for @settings_reset_app_data_title.
  ///
  /// In en, this message translates to:
  /// **'Reset app data'**
  String get settings_reset_app_data_title;

  /// No description provided for @settings_reset_app_data_loading.
  ///
  /// In en, this message translates to:
  /// **'Deleting your app data...'**
  String get settings_reset_app_data_loading;

  /// No description provided for @settings_reset_app_data_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Clear progress, saved items, and history.'**
  String get settings_reset_app_data_subtitle_short;

  /// No description provided for @settings_delete_account_section_title.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settings_delete_account_section_title;

  /// No description provided for @settings_delete_account_loading.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get settings_delete_account_loading;

  /// No description provided for @settings_delete_account_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and app data.'**
  String get settings_delete_account_section_subtitle;

  /// No description provided for @settings_reset_app_data_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reset app data?'**
  String get settings_reset_app_data_dialog_title;

  /// No description provided for @settings_reset_app_data_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'This removes your training history, saved sessions, program progress, quick-fix history, feedback, profile, and preferences. Your sign-in account stays active. This cannot be undone.'**
  String get settings_reset_app_data_dialog_body;

  /// No description provided for @settings_reset_app_data_confirm.
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get settings_reset_app_data_confirm;

  /// No description provided for @settings_reset_app_data_sign_in_required.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to reset your app data.'**
  String get settings_reset_app_data_sign_in_required;

  /// No description provided for @settings_reset_app_data_success.
  ///
  /// In en, this message translates to:
  /// **'Your app data has been reset.'**
  String get settings_reset_app_data_success;

  /// No description provided for @settings_reset_app_data_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset app data.'**
  String get settings_reset_app_data_failed;

  /// No description provided for @settings_delete_account_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settings_delete_account_dialog_title;

  /// No description provided for @settings_delete_account_dialog_body.
  ///
  /// In en, this message translates to:
  /// **'Your profile, preferences, saved sessions, history, purchase access, and account data will be removed. This cannot be undone.'**
  String get settings_delete_account_dialog_body;

  /// No description provided for @settings_delete_account_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settings_delete_account_confirm;

  /// No description provided for @settings_delete_account_sign_in_required.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to delete your account.'**
  String get settings_delete_account_sign_in_required;

  /// No description provided for @settings_delete_account_success.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get settings_delete_account_success;

  /// No description provided for @settings_delete_account_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please contact support.'**
  String get settings_delete_account_failed;

  /// No description provided for @profile_core_access_badge.
  ///
  /// In en, this message translates to:
  /// **'CORE ACCESS'**
  String get profile_core_access_badge;

  /// No description provided for @profile_core_access_cta_short.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get profile_core_access_cta_short;

  /// No description provided for @profile_edit_saved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profile_edit_saved;

  /// No description provided for @profile_avatar_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profile_avatar_updated;

  /// No description provided for @profile_edit_error.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be updated. Please try again.'**
  String get profile_edit_error;

  /// No description provided for @profile_change_photo_cta.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profile_change_photo_cta;

  /// No description provided for @profile_remove_photo_cta.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get profile_remove_photo_cta;

  /// No description provided for @profile_display_name_label.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profile_display_name_label;

  /// No description provided for @profile_save_cta.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profile_save_cta;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_hero_title.
  ///
  /// In en, this message translates to:
  /// **'App controls'**
  String get settings_hero_title;

  /// No description provided for @settings_hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, support, and legal information.'**
  String get settings_hero_subtitle;

  /// No description provided for @settings_preferences_compact_title.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_preferences_compact_title;

  /// No description provided for @settings_preferences_compact_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, and sync.'**
  String get settings_preferences_compact_subtitle;

  /// No description provided for @settings_language_section_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language_section_title;

  /// No description provided for @settings_appearance_section_title.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance_section_title;

  /// No description provided for @notification_settings_title_compact.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_settings_title_compact;

  /// No description provided for @notification_settings_inline_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery reminders and haptics.'**
  String get notification_settings_inline_subtitle;

  /// No description provided for @notification_settings_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load notification settings.'**
  String get notification_settings_error;

  /// No description provided for @notification_settings_guest_hint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save notification preferences.'**
  String get notification_settings_guest_hint;

  /// No description provided for @notification_settings_enable_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery reminders'**
  String get notification_settings_enable_title;

  /// No description provided for @notification_settings_enabled_short.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder is active.'**
  String get notification_settings_enabled_short;

  /// No description provided for @notification_settings_disabled_short.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Enable when you want reminders.'**
  String get notification_settings_disabled_short;

  /// No description provided for @notification_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted.'**
  String get notification_permission_denied;

  /// No description provided for @notification_settings_time_title.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get notification_settings_time_title;

  /// No description provided for @notification_settings_time_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load reminder time.'**
  String get notification_settings_time_error;

  /// No description provided for @notification_settings_haptics_title.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get notification_settings_haptics_title;

  /// No description provided for @notification_settings_haptics_short.
  ///
  /// In en, this message translates to:
  /// **'Tactile confirmation where supported.'**
  String get notification_settings_haptics_short;

  /// No description provided for @notification_time_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get notification_time_morning;

  /// No description provided for @notification_time_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get notification_time_afternoon;

  /// No description provided for @notification_time_evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get notification_time_evening;

  /// No description provided for @settings_support_legal_title.
  ///
  /// In en, this message translates to:
  /// **'Support & legal'**
  String get settings_support_legal_title;

  /// No description provided for @settings_support_legal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Help, policies, and account information.'**
  String get settings_support_legal_subtitle;

  /// No description provided for @settings_contact_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get settings_contact_email_label;

  /// No description provided for @settings_privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy_policy_title;

  /// No description provided for @settings_external_link_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get settings_external_link_subtitle;

  /// No description provided for @settings_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settings_terms_title;

  /// No description provided for @settings_account_data_deletion_info_title.
  ///
  /// In en, this message translates to:
  /// **'Data deletion policy'**
  String get settings_account_data_deletion_info_title;

  /// No description provided for @settings_app_version_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get settings_app_version_loading;

  /// No description provided for @settings_app_version_title.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_app_version_title;

  /// No description provided for @settings_theme_system_title.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system_title;

  /// No description provided for @settings_theme_system_short.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settings_theme_system_short;

  /// No description provided for @settings_theme_light_title.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light_title;

  /// No description provided for @settings_theme_light_short.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light_short;

  /// No description provided for @settings_theme_dark_title.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark_title;

  /// No description provided for @settings_theme_dark_short.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark_short;

  /// No description provided for @settings_preferences_error_short.
  ///
  /// In en, this message translates to:
  /// **'Could not load cloud preferences.'**
  String get settings_preferences_error_short;

  /// No description provided for @settings_preferences_guest_hint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync preferences across devices.'**
  String get settings_preferences_guest_hint;

  /// No description provided for @settings_preferences_synced_short.
  ///
  /// In en, this message translates to:
  /// **'Preferences are synced.'**
  String get settings_preferences_synced_short;

  /// No description provided for @settings_link_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get settings_link_open_failed;

  /// No description provided for @settings_email_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open your email app.'**
  String get settings_email_open_failed;

  /// No description provided for @premium_purchase_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase was cancelled.'**
  String get premium_purchase_cancelled;

  /// No description provided for @premium_restore_no_purchase_found.
  ///
  /// In en, this message translates to:
  /// **'No previous Core Access purchase was found for this Google Play account.'**
  String get premium_restore_no_purchase_found;

  /// No description provided for @premium_purchase_failed.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be completed. Please try again.'**
  String get premium_purchase_failed;

  /// No description provided for @premium_page_title.
  ///
  /// In en, this message translates to:
  /// **'Core Access'**
  String get premium_page_title;

  /// No description provided for @premium_status_core_active.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get premium_status_core_active;

  /// No description provided for @premium_visual_pill.
  ///
  /// In en, this message translates to:
  /// **'One-time Core'**
  String get premium_visual_pill;

  /// No description provided for @premium_hero_unlocked_title.
  ///
  /// In en, this message translates to:
  /// **'Core Access is active.'**
  String get premium_hero_unlocked_title;

  /// No description provided for @premium_visual_title_v2.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full recovery system.'**
  String get premium_visual_title_v2;

  /// No description provided for @premium_hero_unlocked_body_v2.
  ///
  /// In en, this message translates to:
  /// **'Programs, full sessions, Quick Fix, insights, saved items, and history are available.'**
  String get premium_hero_unlocked_body_v2;

  /// No description provided for @premium_visual_body_v2.
  ///
  /// In en, this message translates to:
  /// **'Programs, full sessions, Quick Fix, insights, saved items, and history — one unlock.'**
  String get premium_visual_body_v2;

  /// No description provided for @premium_programs_badge.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get premium_programs_badge;

  /// No description provided for @premium_value_programs_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery programs'**
  String get premium_value_programs_title;

  /// No description provided for @premium_value_sessions_title.
  ///
  /// In en, this message translates to:
  /// **'Full sessions'**
  String get premium_value_sessions_title;

  /// No description provided for @premium_value_quick_fix_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Fix'**
  String get premium_value_quick_fix_title;

  /// No description provided for @premium_value_insights_title.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get premium_value_insights_title;

  /// No description provided for @premium_value_active_title.
  ///
  /// In en, this message translates to:
  /// **'Your unlocked toolkit'**
  String get premium_value_active_title;

  /// No description provided for @premium_value_title.
  ///
  /// In en, this message translates to:
  /// **'What Core unlocks'**
  String get premium_value_title;

  /// No description provided for @premium_value_subtitle_v2.
  ///
  /// In en, this message translates to:
  /// **'Full access in one unlock.'**
  String get premium_value_subtitle_v2;

  /// No description provided for @premium_product_price_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get premium_product_price_unavailable;

  /// No description provided for @premium_plan_unlocked_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your full recovery toolkit is unlocked.'**
  String get premium_plan_unlocked_subtitle;

  /// No description provided for @premium_plan_subtitle_v2.
  ///
  /// In en, this message translates to:
  /// **'One-time unlock. No subscription. Restore anytime with the same Google Play account.'**
  String get premium_plan_subtitle_v2;

  /// No description provided for @premium_sign_in_hint.
  ///
  /// In en, this message translates to:
  /// **'Sign in first so access can be restored later.'**
  String get premium_sign_in_hint;

  /// No description provided for @premium_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Core Access'**
  String get premium_plan_title;

  /// No description provided for @premium_plan_lifetime_badge.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get premium_plan_lifetime_badge;

  /// No description provided for @premium_signal_lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get premium_signal_lifetime;

  /// No description provided for @premium_signal_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore supported'**
  String get premium_signal_restore;

  /// No description provided for @premium_signal_no_subscription.
  ///
  /// In en, this message translates to:
  /// **'No subscription'**
  String get premium_signal_no_subscription;

  /// No description provided for @premium_already_unlocked_cta.
  ///
  /// In en, this message translates to:
  /// **'Already unlocked'**
  String get premium_already_unlocked_cta;

  /// No description provided for @premium_restore_cta.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get premium_restore_cta;

  /// No description provided for @premium_loading_products_cta.
  ///
  /// In en, this message translates to:
  /// **'Checking store…'**
  String get premium_loading_products_cta;

  /// No description provided for @premium_purchasing_cta.
  ///
  /// In en, this message translates to:
  /// **'Opening store…'**
  String get premium_purchasing_cta;

  /// No description provided for @premium_verifying_cta.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get premium_verifying_cta;

  /// No description provided for @premium_product_unavailable_cta.
  ///
  /// In en, this message translates to:
  /// **'Product unavailable'**
  String get premium_product_unavailable_cta;

  /// No description provided for @access_unlock_core_cta.
  ///
  /// In en, this message translates to:
  /// **'Unlock Core'**
  String get access_unlock_core_cta;

  /// No description provided for @premium_error_purchase_linked_to_another_account.
  ///
  /// In en, this message translates to:
  /// **'This purchase is already linked to another account. Sign in with the account used for the original unlock.'**
  String get premium_error_purchase_linked_to_another_account;

  /// No description provided for @premium_error_not_authenticated.
  ///
  /// In en, this message translates to:
  /// **'Sign in first so your purchase can be verified.'**
  String get premium_error_not_authenticated;

  /// No description provided for @premium_error_missing_purchase_payload.
  ///
  /// In en, this message translates to:
  /// **'The store did not return a valid purchase receipt. Please try restore or contact support.'**
  String get premium_error_missing_purchase_payload;

  /// No description provided for @premium_error_product_mismatch.
  ///
  /// In en, this message translates to:
  /// **'The store product does not match this app version. Please update the app or contact support.'**
  String get premium_error_product_mismatch;

  /// No description provided for @premium_error_purchase_not_completed.
  ///
  /// In en, this message translates to:
  /// **'The purchase was not completed. Please try again.'**
  String get premium_error_purchase_not_completed;

  /// No description provided for @premium_error_unsupported_platform.
  ///
  /// In en, this message translates to:
  /// **'Purchases are currently available only on Android.'**
  String get premium_error_unsupported_platform;

  /// No description provided for @premium_error_store_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Google Play billing is not available on this device. Please install the app from Google Play.'**
  String get premium_error_store_unavailable;

  /// No description provided for @premium_error_product_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Core Access is not available from the store right now. Please try again later.'**
  String get premium_error_product_unavailable;

  /// No description provided for @premium_error_purchase_failed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be started. Please try again.'**
  String get premium_error_purchase_failed;

  /// No description provided for @premium_error_verification_failed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be verified. Please try restore or contact support.'**
  String get premium_error_verification_failed;

  /// No description provided for @premium_billing_error_body.
  ///
  /// In en, this message translates to:
  /// **'Billing is not ready or the purchase could not be verified. Please try again.'**
  String get premium_billing_error_body;

  /// No description provided for @logs_page_title.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs_page_title;

  /// No description provided for @logs_locked_title.
  ///
  /// In en, this message translates to:
  /// **'Behavior Logs are part of Core Access'**
  String get logs_locked_title;

  /// No description provided for @logs_locked_message.
  ///
  /// In en, this message translates to:
  /// **'Unlock Core once to inspect recovery logs generated from runs, feedback, quick-fix activity, state snapshots, and player events.'**
  String get logs_locked_message;

  /// No description provided for @logs_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery logs'**
  String get logs_hero_title;

  /// No description provided for @logs_hero_body_short.
  ///
  /// In en, this message translates to:
  /// **'Recent signals from sessions and Quick Fix.'**
  String get logs_hero_body_short;

  /// No description provided for @logs_positive_label.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get logs_positive_label;

  /// No description provided for @logs_warning_label.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get logs_warning_label;

  /// No description provided for @logs_neutral_label.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get logs_neutral_label;

  /// No description provided for @logs_recent_title.
  ///
  /// In en, this message translates to:
  /// **'Recent log entries'**
  String get logs_recent_title;

  /// No description provided for @insights_logs_empty.
  ///
  /// In en, this message translates to:
  /// **'Complete a few sessions to generate recovery notes.'**
  String get insights_logs_empty;

  /// No description provided for @logs_error_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to load logs'**
  String get logs_error_title;

  /// No description provided for @insights_title.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights_title;

  /// No description provided for @guide_insights_signal_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery signal'**
  String get guide_insights_signal_title;

  /// No description provided for @guide_insights_signal_body.
  ///
  /// In en, this message translates to:
  /// **'This area summarizes your recent recovery rhythm after you unlock insights.'**
  String get guide_insights_signal_body;

  /// No description provided for @guide_insights_metrics_title.
  ///
  /// In en, this message translates to:
  /// **'Key numbers'**
  String get guide_insights_metrics_title;

  /// No description provided for @guide_insights_metrics_body.
  ///
  /// In en, this message translates to:
  /// **'Here you will see minutes, consistency, focus zones, and Quick Fix activity.'**
  String get guide_insights_metrics_body;

  /// No description provided for @guide_insights_patterns_title.
  ///
  /// In en, this message translates to:
  /// **'Trends and patterns'**
  String get guide_insights_patterns_title;

  /// No description provided for @guide_insights_patterns_body.
  ///
  /// In en, this message translates to:
  /// **'Charts help you understand what improves and where tension keeps returning.'**
  String get guide_insights_patterns_body;

  /// No description provided for @insights_journey_intelligence_title.
  ///
  /// In en, this message translates to:
  /// **'Journey intelligence'**
  String get insights_journey_intelligence_title;

  /// No description provided for @insights_journey_intelligence_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Build a therapy signal'**
  String get insights_journey_intelligence_empty_title;

  /// No description provided for @insights_journey_intelligence_body.
  ///
  /// In en, this message translates to:
  /// **'Your current journey is building consistency, response, and completion patterns.'**
  String get insights_journey_intelligence_body;

  /// No description provided for @insights_journey_intelligence_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Start a therapy journey to connect sessions with long-term recovery progress.'**
  String get insights_journey_intelligence_empty_body;

  /// No description provided for @insights_focus_completion_title.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get insights_focus_completion_title;

  /// No description provided for @insights_focus_helpful_title.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get insights_focus_helpful_title;

  /// No description provided for @insights_summary_consistency_title.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get insights_summary_consistency_title;

  /// No description provided for @insights_locked_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Unlock Insights'**
  String get insights_locked_preview_title;

  /// No description provided for @insights_locked_preview_body.
  ///
  /// In en, this message translates to:
  /// **'Core Access shows your real trends.'**
  String get insights_locked_preview_body;

  /// No description provided for @insights_range_7_short.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get insights_range_7_short;

  /// No description provided for @insights_range_14_short.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get insights_range_14_short;

  /// No description provided for @insights_range_28_short.
  ///
  /// In en, this message translates to:
  /// **'28 days'**
  String get insights_range_28_short;

  /// No description provided for @insights_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery signal'**
  String get insights_intro_title;

  /// No description provided for @insights_intro_body_short.
  ///
  /// In en, this message translates to:
  /// **'Patterns from your recent recovery work.'**
  String get insights_intro_body_short;

  /// No description provided for @insights_focus_zone_title.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get insights_focus_zone_title;

  /// No description provided for @insights_range_compact.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get insights_range_compact;

  /// No description provided for @insights_streak_compact.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get insights_streak_compact;

  /// No description provided for @insights_summary_minutes_title.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get insights_summary_minutes_title;

  /// No description provided for @insights_summary_minutes_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get insights_summary_minutes_subtitle;

  /// No description provided for @insights_active_days_title.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get insights_active_days_title;

  /// No description provided for @insights_helpful_title.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get insights_helpful_title;

  /// No description provided for @insights_helpful_subtitle.
  ///
  /// In en, this message translates to:
  /// **'From feedback'**
  String get insights_helpful_subtitle;

  /// No description provided for @insights_relief_title.
  ///
  /// In en, this message translates to:
  /// **'Relief'**
  String get insights_relief_title;

  /// No description provided for @insights_relief_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get insights_relief_subtitle;

  /// No description provided for @insights_recovery_minutes_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Trend'**
  String get insights_recovery_minutes_title;

  /// No description provided for @insights_recovery_minutes_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Minutes over time'**
  String get insights_recovery_minutes_subtitle_short;

  /// No description provided for @insights_chart_peak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get insights_chart_peak;

  /// No description provided for @insights_chart_average.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get insights_chart_average;

  /// No description provided for @insights_rhythm_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery Rhythm'**
  String get insights_rhythm_title;

  /// No description provided for @insights_rhythm_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Recent active days'**
  String get insights_rhythm_subtitle_short;

  /// No description provided for @insights_rhythm_active_days.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get insights_rhythm_active_days;

  /// No description provided for @insights_rhythm_minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get insights_rhythm_minutes;

  /// No description provided for @insights_patterns_title.
  ///
  /// In en, this message translates to:
  /// **'Pattern Notes'**
  String get insights_patterns_title;

  /// No description provided for @insights_patterns_subtitle_short.
  ///
  /// In en, this message translates to:
  /// **'Recent signals'**
  String get insights_patterns_subtitle_short;

  /// No description provided for @insights_logs_action.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get insights_logs_action;

  /// No description provided for @insights_error_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to load insights'**
  String get insights_error_title;

  /// No description provided for @pain_forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get pain_forearms;

  /// No description provided for @pain_hands.
  ///
  /// In en, this message translates to:
  /// **'Hands'**
  String get pain_hands;

  /// No description provided for @pain_hips_glutes.
  ///
  /// In en, this message translates to:
  /// **'Hips & glutes'**
  String get pain_hips_glutes;

  /// No description provided for @pain_eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get pain_eyes;

  /// No description provided for @session_history_locked_title.
  ///
  /// In en, this message translates to:
  /// **'See your past sessions'**
  String get session_history_locked_title;

  /// No description provided for @session_history_locked_message.
  ///
  /// In en, this message translates to:
  /// **'Unlock to track your recovery.'**
  String get session_history_locked_message;

  /// No description provided for @player_access_locked_title.
  ///
  /// In en, this message translates to:
  /// **'Core Access required'**
  String get player_access_locked_title;

  /// No description provided for @player_access_locked_message.
  ///
  /// In en, this message translates to:
  /// **'This session is part of Core Access. Unlock once to use the full recovery toolkit.'**
  String get player_access_locked_message;

  /// No description provided for @guide_player_header_title.
  ///
  /// In en, this message translates to:
  /// **'Session progress'**
  String get guide_player_header_title;

  /// No description provided for @guide_player_header_body.
  ///
  /// In en, this message translates to:
  /// **'This top card shows the session title and your overall progress. Tap close only when you want to leave the session.'**
  String get guide_player_header_body;

  /// No description provided for @guide_player_video_title.
  ///
  /// In en, this message translates to:
  /// **'Movement demo'**
  String get guide_player_video_title;

  /// No description provided for @guide_player_video_body.
  ///
  /// In en, this message translates to:
  /// **'Follow the video for the safe movement shape. You can expand it or mute/unmute without leaving the player.'**
  String get guide_player_video_body;

  /// No description provided for @guide_player_timer_title.
  ///
  /// In en, this message translates to:
  /// **'Main timer'**
  String get guide_player_timer_title;

  /// No description provided for @guide_player_timer_body.
  ///
  /// In en, this message translates to:
  /// **'Use this large timer as the source of truth for the current step.'**
  String get guide_player_timer_body;

  /// No description provided for @guide_player_instruction_title.
  ///
  /// In en, this message translates to:
  /// **'Instruction card'**
  String get guide_player_instruction_title;

  /// No description provided for @guide_player_instruction_body.
  ///
  /// In en, this message translates to:
  /// **'Read the short instruction here. Extra coaching, breathing, and safety notes stay compact inside this card.'**
  String get guide_player_instruction_body;

  /// No description provided for @guide_player_controls_title.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get guide_player_controls_title;

  /// No description provided for @guide_player_controls_body.
  ///
  /// In en, this message translates to:
  /// **'Control the session from here: previous, replay, pause, skip, next, or finish on the last step.'**
  String get guide_player_controls_body;

  /// No description provided for @guide_done_cta.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get guide_done_cta;

  /// No description provided for @movement_pattern_setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get movement_pattern_setup;

  /// No description provided for @movement_pattern_assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get movement_pattern_assessment;

  /// No description provided for @movement_pattern_mobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get movement_pattern_mobility;

  /// No description provided for @movement_pattern_stretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get movement_pattern_stretch;

  /// No description provided for @movement_pattern_release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get movement_pattern_release;

  /// No description provided for @movement_pattern_activation.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get movement_pattern_activation;

  /// No description provided for @movement_pattern_strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get movement_pattern_strength;

  /// No description provided for @movement_pattern_endurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get movement_pattern_endurance;

  /// No description provided for @movement_pattern_posture.
  ///
  /// In en, this message translates to:
  /// **'Posture'**
  String get movement_pattern_posture;

  /// No description provided for @movement_pattern_breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get movement_pattern_breathing;

  /// No description provided for @movement_pattern_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get movement_pattern_cooldown;

  /// No description provided for @movement_pattern_habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get movement_pattern_habit;

  /// No description provided for @continuity_preview_cta.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get continuity_preview_cta;

  /// No description provided for @player_pre_state_subtitle_compact.
  ///
  /// In en, this message translates to:
  /// **'Set your starting point. This takes a few seconds.'**
  String get player_pre_state_subtitle_compact;

  /// No description provided for @player_feedback_subtitle_compact.
  ///
  /// In en, this message translates to:
  /// **'One quick tap helps tune your next recommendation.'**
  String get player_feedback_subtitle_compact;

  /// No description provided for @player_media_expand_tooltip.
  ///
  /// In en, this message translates to:
  /// **'View larger'**
  String get player_media_expand_tooltip;

  /// No description provided for @player_media_unmute_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn sound on'**
  String get player_media_unmute_tooltip;

  /// No description provided for @player_media_mute_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn sound off'**
  String get player_media_mute_tooltip;

  /// No description provided for @guide_dashboard_topbar_title.
  ///
  /// In en, this message translates to:
  /// **'Top bar'**
  String get guide_dashboard_topbar_title;

  /// No description provided for @guide_dashboard_topbar_body.
  ///
  /// In en, this message translates to:
  /// **'Use the top bar for notifications and your account. Free members can upgrade directly from the account badge.'**
  String get guide_dashboard_topbar_body;

  /// No description provided for @guide_dashboard_home_title.
  ///
  /// In en, this message translates to:
  /// **'Your recovery home'**
  String get guide_dashboard_home_title;

  /// No description provided for @guide_dashboard_home_body.
  ///
  /// In en, this message translates to:
  /// **'Start with the smart next action, then check your recovery status, program progress, and recent activity.'**
  String get guide_dashboard_home_body;

  /// No description provided for @guide_dashboard_bottom_nav_title.
  ///
  /// In en, this message translates to:
  /// **'Bottom navigation'**
  String get guide_dashboard_bottom_nav_title;

  /// No description provided for @guide_dashboard_bottom_nav_body.
  ///
  /// In en, this message translates to:
  /// **'Use the bottom tabs to open Training, Quick Fix, Insights, and Programs when you need deeper details.'**
  String get guide_dashboard_bottom_nav_body;

  /// No description provided for @dashboard_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dashboard_greeting;

  /// No description provided for @dashboard_new_quick_fix_title.
  ///
  /// In en, this message translates to:
  /// **'Where do you feel tension?'**
  String get dashboard_new_quick_fix_title;

  /// No description provided for @dashboard_new_quick_fix_body.
  ///
  /// In en, this message translates to:
  /// **'Tap a body area and get the best matching reset in seconds.'**
  String get dashboard_new_quick_fix_body;

  /// No description provided for @dashboard_quick_fix_title.
  ///
  /// In en, this message translates to:
  /// **'Find your reset'**
  String get dashboard_quick_fix_title;

  /// No description provided for @dashboard_for_you_now.
  ///
  /// In en, this message translates to:
  /// **'For you now'**
  String get dashboard_for_you_now;

  /// No description provided for @session_duration_unit_min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get session_duration_unit_min;

  /// No description provided for @dashboard_continue_session.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dashboard_continue_session;

  /// No description provided for @dashboard_start_session.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dashboard_start_session;

  /// No description provided for @dashboard_active_program_title.
  ///
  /// In en, this message translates to:
  /// **'Your program'**
  String get dashboard_active_program_title;

  /// No description provided for @dashboard_continue_program.
  ///
  /// In en, this message translates to:
  /// **'Continue your program'**
  String get dashboard_continue_program;

  /// No description provided for @dashboard_day_label.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dashboard_day_label;

  /// No description provided for @profile_action_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_action_notifications;

  /// No description provided for @dashboard_command_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery command center'**
  String get dashboard_command_title;

  /// No description provided for @dashboard_command_active_body.
  ///
  /// In en, this message translates to:
  /// **'Your journey, recovery signal, and next action in one place.'**
  String get dashboard_command_active_body;

  /// No description provided for @dashboard_command_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Start a therapy journey to build a clear recovery signal.'**
  String get dashboard_command_empty_body;

  /// No description provided for @dashboard_readiness_label.
  ///
  /// In en, this message translates to:
  /// **'readiness'**
  String get dashboard_readiness_label;

  /// No description provided for @dashboard_helpful_label.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get dashboard_helpful_label;

  /// No description provided for @dashboard_rhythm_label.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get dashboard_rhythm_label;

  /// No description provided for @dashboard_snapshot_error_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard data is unavailable'**
  String get dashboard_snapshot_error_title;

  /// No description provided for @dashboard_weekly_minutes_label.
  ///
  /// In en, this message translates to:
  /// **'min week'**
  String get dashboard_weekly_minutes_label;

  /// No description provided for @dashboard_completed_week_label.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get dashboard_completed_week_label;

  /// No description provided for @dashboard_run_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboard_run_completed;

  /// No description provided for @dashboard_run_abandoned.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get dashboard_run_abandoned;

  /// No description provided for @dashboard_run_started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get dashboard_run_started;

  /// No description provided for @dashboard_programs_active_title.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get dashboard_programs_active_title;

  /// No description provided for @dashboard_programs_title.
  ///
  /// In en, this message translates to:
  /// **'Therapy journeys'**
  String get dashboard_programs_title;

  /// No description provided for @common_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get common_view_all;

  /// No description provided for @dashboard_program_discovery_pill_guided.
  ///
  /// In en, this message translates to:
  /// **'Guided'**
  String get dashboard_program_discovery_pill_guided;

  /// No description provided for @dashboard_program_discovery_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a therapy path'**
  String get dashboard_program_discovery_title;

  /// No description provided for @dashboard_program_discovery_cta.
  ///
  /// In en, this message translates to:
  /// **'View paths'**
  String get dashboard_program_discovery_cta;

  /// No description provided for @program_active_badge.
  ///
  /// In en, this message translates to:
  /// **'Active program'**
  String get program_active_badge;

  /// No description provided for @dashboard_programs_continue_cta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dashboard_programs_continue_cta;

  /// No description provided for @program_day_unit.
  ///
  /// In en, this message translates to:
  /// **'missions'**
  String get program_day_unit;

  /// No description provided for @program_start_cta.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get program_start_cta;

  /// No description provided for @dashboard_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get dashboard_saved_title;

  /// No description provided for @dashboard_recommended_title.
  ///
  /// In en, this message translates to:
  /// **'Recommended today'**
  String get dashboard_recommended_title;

  /// No description provided for @dashboard_see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboard_see_all;

  /// No description provided for @sessions_title.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get sessions_title;

  /// No description provided for @dashboard_momentum_title.
  ///
  /// In en, this message translates to:
  /// **'Your momentum'**
  String get dashboard_momentum_title;

  /// No description provided for @dashboard_program_days_label.
  ///
  /// In en, this message translates to:
  /// **'program missions'**
  String get dashboard_program_days_label;

  /// No description provided for @dashboard_streak_label.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get dashboard_streak_label;

  /// No description provided for @dashboard_saved_count_label.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get dashboard_saved_count_label;

  /// No description provided for @dashboard_body_focus_title.
  ///
  /// In en, this message translates to:
  /// **'Need relief now?'**
  String get dashboard_body_focus_title;

  /// No description provided for @dashboard_body_focus_body.
  ///
  /// In en, this message translates to:
  /// **'Use Quick Fix to choose the body zone that needs attention.'**
  String get dashboard_body_focus_body;

  /// No description provided for @dashboard_premium_title.
  ///
  /// In en, this message translates to:
  /// **'Your complete recovery system'**
  String get dashboard_premium_title;

  /// No description provided for @dashboard_premium_body.
  ///
  /// In en, this message translates to:
  /// **'Guided programs, deeper insights, and every recovery session unlocked.'**
  String get dashboard_premium_body;

  /// No description provided for @dashboard_premium_cta_short.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get dashboard_premium_cta_short;

  /// No description provided for @programs_title.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs_title;

  /// No description provided for @programs_browse_all_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your recovery path'**
  String get programs_browse_all_title;

  /// No description provided for @programs_more_journeys_title.
  ///
  /// In en, this message translates to:
  /// **'More programs'**
  String get programs_more_journeys_title;

  /// No description provided for @programs_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Structured plans designed for consistent progress.'**
  String get programs_section_subtitle;

  /// No description provided for @programs_header_active.
  ///
  /// In en, this message translates to:
  /// **'Keep your momentum'**
  String get programs_header_active;

  /// No description provided for @programs_header_new.
  ///
  /// In en, this message translates to:
  /// **'Build a healthier workday'**
  String get programs_header_new;

  /// No description provided for @programs_header_body.
  ///
  /// In en, this message translates to:
  /// **'Guided programs with a clear daily structure.'**
  String get programs_header_body;

  /// No description provided for @program_premium_badge.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get program_premium_badge;

  /// No description provided for @programs_error_title.
  ///
  /// In en, this message translates to:
  /// **'Programs are temporarily unavailable'**
  String get programs_error_title;

  /// No description provided for @programs_error_body.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get programs_error_body;

  /// No description provided for @programs_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No programs available yet'**
  String get programs_empty_title;

  /// No description provided for @programs_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Pull down or refresh to check again.'**
  String get programs_empty_body;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @program_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get program_detail_title;

  /// No description provided for @program_switch_title.
  ///
  /// In en, this message translates to:
  /// **'Switch journey?'**
  String get program_switch_title;

  /// No description provided for @program_start_title.
  ///
  /// In en, this message translates to:
  /// **'Start this journey?'**
  String get program_start_title;

  /// No description provided for @program_switch_body.
  ///
  /// In en, this message translates to:
  /// **'Your progress in the current journey will stay saved. This journey will become your active path.'**
  String get program_switch_body;

  /// No description provided for @program_start_body.
  ///
  /// In en, this message translates to:
  /// **'Your first mission will unlock now. Progress is saved after every completed mission.'**
  String get program_start_body;

  /// No description provided for @program_switch_cta.
  ///
  /// In en, this message translates to:
  /// **'Switch journey'**
  String get program_switch_cta;

  /// No description provided for @program_begin_cta.
  ///
  /// In en, this message translates to:
  /// **'Begin journey'**
  String get program_begin_cta;

  /// No description provided for @program_phase_recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get program_phase_recovery;

  /// No description provided for @program_completed_label.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get program_completed_label;

  /// No description provided for @program_continue_recovery_cta.
  ///
  /// In en, this message translates to:
  /// **'Continue Recovery'**
  String get program_continue_recovery_cta;

  /// No description provided for @program_about_journey_label.
  ///
  /// In en, this message translates to:
  /// **'About this journey'**
  String get program_about_journey_label;

  /// No description provided for @program_path_label.
  ///
  /// In en, this message translates to:
  /// **'Recovery program'**
  String get program_path_label;

  /// No description provided for @program_unlocked_label.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get program_unlocked_label;

  /// No description provided for @program_no_days_title.
  ///
  /// In en, this message translates to:
  /// **'No missions available yet.'**
  String get program_no_days_title;

  /// No description provided for @program_view_full_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Journey map'**
  String get program_view_full_plan_title;

  /// No description provided for @program_sequential_hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a phase to view its missions and progress.'**
  String get program_sequential_hint;

  /// No description provided for @program_day_missing_session.
  ///
  /// In en, this message translates to:
  /// **'Missing session'**
  String get program_day_missing_session;

  /// No description provided for @program_phase_start_label.
  ///
  /// In en, this message translates to:
  /// **'Phase Start'**
  String get program_phase_start_label;

  /// No description provided for @program_phase_end_label.
  ///
  /// In en, this message translates to:
  /// **'Phase End'**
  String get program_phase_end_label;

  /// No description provided for @program_assessment_label.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get program_assessment_label;

  /// No description provided for @program_repeat_label.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get program_repeat_label;

  /// No description provided for @program_today_badge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get program_today_badge;

  /// No description provided for @program_expected_label.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get program_expected_label;

  /// No description provided for @program_detail_error_title.
  ///
  /// In en, this message translates to:
  /// **'This journey could not load.'**
  String get program_detail_error_title;

  /// No description provided for @program_detail_error_body.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again. Your mission progress is safe.'**
  String get program_detail_error_body;

  /// No description provided for @program_progress_sync_warning.
  ///
  /// In en, this message translates to:
  /// **'Journey loaded, but progress could not sync. Some mission states may be outdated.'**
  String get program_progress_sync_warning;

  /// No description provided for @program_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'This journey is no longer available.'**
  String get program_not_found_title;

  /// No description provided for @program_not_found_body.
  ///
  /// In en, this message translates to:
  /// **'Return to Programs and choose another therapy journey.'**
  String get program_not_found_body;

  /// No description provided for @access_core_badge.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get access_core_badge;

  /// No description provided for @sessions_load_error_title.
  ///
  /// In en, this message translates to:
  /// **'Training could not load.'**
  String get sessions_load_error_title;

  /// No description provided for @guide_training_sessions_title.
  ///
  /// In en, this message translates to:
  /// **'Sessions are single resets'**
  String get guide_training_sessions_title;

  /// No description provided for @guide_training_sessions_body.
  ///
  /// In en, this message translates to:
  /// **'Use sessions when you want one quick recovery exercise right now.'**
  String get guide_training_sessions_body;

  /// No description provided for @guide_training_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Search and filter'**
  String get guide_training_filter_title;

  /// No description provided for @guide_training_filter_body.
  ///
  /// In en, this message translates to:
  /// **'Filter by body zone, duration, intensity, or desk-friendly sessions.'**
  String get guide_training_filter_body;

  /// No description provided for @common_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clear;

  /// No description provided for @training_programs_title.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get training_programs_title;

  /// No description provided for @training_programs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Guided therapy journeys for structured recovery.'**
  String get training_programs_subtitle;

  /// No description provided for @training_sessions_section_title.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get training_sessions_section_title;

  /// No description provided for @training_sessions_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Single recovery sessions you can start anytime.'**
  String get training_sessions_section_subtitle;

  /// No description provided for @sessions_search_hint_compact.
  ///
  /// In en, this message translates to:
  /// **'Search sessions'**
  String get sessions_search_hint_compact;

  /// No description provided for @sessions_category_lower_back_hips.
  ///
  /// In en, this message translates to:
  /// **'Lower back & hips'**
  String get sessions_category_lower_back_hips;

  /// No description provided for @sessions_category_wrists_hands.
  ///
  /// In en, this message translates to:
  /// **'Wrists & hands'**
  String get sessions_category_wrists_hands;

  /// No description provided for @sessions_sort_shortest.
  ///
  /// In en, this message translates to:
  /// **'Duration: shortest'**
  String get sessions_sort_shortest;

  /// No description provided for @sessions_sort_alpha.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sessions_sort_alpha;

  /// No description provided for @sessions_sort_short_recommended.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sessions_sort_short_recommended;

  /// No description provided for @sessions_sort_short_shortest.
  ///
  /// In en, this message translates to:
  /// **'Shortest'**
  String get sessions_sort_short_shortest;

  /// No description provided for @sessions_sort_short_az.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get sessions_sort_short_az;

  /// No description provided for @session_detail_nav_title.
  ///
  /// In en, this message translates to:
  /// **'Session Detail'**
  String get session_detail_nav_title;

  /// No description provided for @premium_title.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium_title;

  /// No description provided for @session_detail_label.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session_detail_label;

  /// No description provided for @session_detail_body_target_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get session_detail_body_target_general;

  /// No description provided for @session_detail_body_targets_title.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get session_detail_body_targets_title;

  /// No description provided for @session_detail_equipment_none.
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get session_detail_equipment_none;

  /// No description provided for @session_detail_steps_title_compact.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get session_detail_steps_title_compact;

  /// No description provided for @session_detail_safety_title.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get session_detail_safety_title;

  /// No description provided for @session_detail_safety_compact_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check before you start.'**
  String get session_detail_safety_compact_subtitle;

  /// No description provided for @session_detail_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Use caution if'**
  String get session_detail_warning_title;

  /// No description provided for @session_detail_avoid_title.
  ///
  /// In en, this message translates to:
  /// **'Avoid or stop if'**
  String get session_detail_avoid_title;

  /// No description provided for @session_detail_error_title.
  ///
  /// In en, this message translates to:
  /// **'Could not load session'**
  String get session_detail_error_title;

  /// No description provided for @session_detail_error_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading this session. Please try again.'**
  String get session_detail_error_subtitle;

  /// No description provided for @equipment_chair.
  ///
  /// In en, this message translates to:
  /// **'Chair'**
  String get equipment_chair;

  /// No description provided for @equipment_desk.
  ///
  /// In en, this message translates to:
  /// **'Desk'**
  String get equipment_desk;

  /// No description provided for @equipment_wall.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get equipment_wall;

  /// No description provided for @equipment_towel.
  ///
  /// In en, this message translates to:
  /// **'Towel'**
  String get equipment_towel;

  /// No description provided for @equipment_small_cushion.
  ///
  /// In en, this message translates to:
  /// **'Small cushion'**
  String get equipment_small_cushion;

  /// No description provided for @equipment_lumbar_roll.
  ///
  /// In en, this message translates to:
  /// **'Lumbar roll'**
  String get equipment_lumbar_roll;

  /// No description provided for @equipment_mini_band.
  ///
  /// In en, this message translates to:
  /// **'Mini band'**
  String get equipment_mini_band;

  /// No description provided for @equipment_long_band.
  ///
  /// In en, this message translates to:
  /// **'Resistance band'**
  String get equipment_long_band;

  /// No description provided for @equipment_massage_ball.
  ///
  /// In en, this message translates to:
  /// **'Massage ball'**
  String get equipment_massage_ball;

  /// No description provided for @equipment_soft_ball.
  ///
  /// In en, this message translates to:
  /// **'Soft ball'**
  String get equipment_soft_ball;

  /// No description provided for @equipment_water_bottle.
  ///
  /// In en, this message translates to:
  /// **'Water bottle'**
  String get equipment_water_bottle;

  /// No description provided for @equipment_dowel.
  ///
  /// In en, this message translates to:
  /// **'Dowel / broomstick'**
  String get equipment_dowel;

  /// No description provided for @equipment_yoga_mat.
  ///
  /// In en, this message translates to:
  /// **'Yoga mat'**
  String get equipment_yoga_mat;

  /// No description provided for @equipment_foam_roller.
  ///
  /// In en, this message translates to:
  /// **'Foam roller'**
  String get equipment_foam_roller;

  /// No description provided for @session_level_free_starter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get session_level_free_starter;

  /// No description provided for @session_level_therapy.
  ///
  /// In en, this message translates to:
  /// **'Therapy'**
  String get session_level_therapy;

  /// No description provided for @session_level_advanced_therapy.
  ///
  /// In en, this message translates to:
  /// **'Advanced therapy'**
  String get session_level_advanced_therapy;

  /// No description provided for @session_level_flagship.
  ///
  /// In en, this message translates to:
  /// **'Flagship'**
  String get session_level_flagship;

  /// No description provided for @saved_sessions_locked_title.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite sessions'**
  String get saved_sessions_locked_title;

  /// No description provided for @saved_sessions_locked_message.
  ///
  /// In en, this message translates to:
  /// **'Unlock to keep them here.'**
  String get saved_sessions_locked_message;

  /// No description provided for @auth_callback_title.
  ///
  /// In en, this message translates to:
  /// **'Finishing sign in...'**
  String get auth_callback_title;

  /// No description provided for @auth_callback_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while your account session is prepared.'**
  String get auth_callback_subtitle;

  /// No description provided for @auth_terms_required.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms and Privacy Policy first.'**
  String get auth_terms_required;

  /// No description provided for @auth_google_not_started.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not be started.'**
  String get auth_google_not_started;

  /// No description provided for @auth_google_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get auth_google_unknown_error;

  /// No description provided for @auth_apple_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in will be added soon.'**
  String get auth_apple_coming_soon;

  /// No description provided for @auth_reset_email_required.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address first.'**
  String get auth_reset_email_required;

  /// No description provided for @auth_reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get auth_reset_email_sent;

  /// No description provided for @auth_link_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get auth_link_open_failed;

  /// No description provided for @auth_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get auth_invalid_credentials;

  /// No description provided for @auth_email_not_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before signing in.'**
  String get auth_email_not_confirmed;

  /// No description provided for @auth_user_already_registered.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get auth_user_already_registered;

  /// No description provided for @auth_or_email_short.
  ///
  /// In en, this message translates to:
  /// **'or continue with email'**
  String get auth_or_email_short;

  /// No description provided for @auth_app_badge.
  ///
  /// In en, this message translates to:
  /// **'Desk Workout'**
  String get auth_app_badge;

  /// No description provided for @auth_sign_up_tab_short.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get auth_sign_up_tab_short;

  /// No description provided for @auth_google_short.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get auth_google_short;

  /// No description provided for @auth_apple_short.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get auth_apple_short;

  /// No description provided for @auth_toggle_password_visibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get auth_toggle_password_visibility;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_accept_terms_text.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Use and Privacy Policy.'**
  String get auth_accept_terms_text;

  /// No description provided for @auth_legal_note_sign_in_compact.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our legal terms.'**
  String get auth_legal_note_sign_in_compact;

  /// No description provided for @auth_legal_note_sign_up_compact.
  ///
  /// In en, this message translates to:
  /// **'Review our legal terms before creating your account.'**
  String get auth_legal_note_sign_up_compact;

  /// No description provided for @auth_privacy_policy_link.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get auth_privacy_policy_link;

  /// No description provided for @auth_terms_of_use_link.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get auth_terms_of_use_link;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @session_detail_save_cta.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get session_detail_save_cta;

  /// No description provided for @session_detail_saved_cta.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get session_detail_saved_cta;

  /// No description provided for @session_detail_start_cta.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get session_detail_start_cta;

  /// No description provided for @startup_error_title.
  ///
  /// In en, this message translates to:
  /// **'Startup failed'**
  String get startup_error_title;

  /// No description provided for @update_available_body.
  ///
  /// In en, this message translates to:
  /// **'A new version of Desk Workout is available.'**
  String get update_available_body;

  /// No description provided for @quick_fix_equipment_none.
  ///
  /// In en, this message translates to:
  /// **'No extra equipment'**
  String get quick_fix_equipment_none;

  /// No description provided for @quick_fix_equipment_towel.
  ///
  /// In en, this message translates to:
  /// **'Towel'**
  String get quick_fix_equipment_towel;

  /// No description provided for @quick_fix_equipment_long_band.
  ///
  /// In en, this message translates to:
  /// **'Resistance band'**
  String get quick_fix_equipment_long_band;

  /// No description provided for @quick_fix_equipment_mini_band.
  ///
  /// In en, this message translates to:
  /// **'Mini band'**
  String get quick_fix_equipment_mini_band;

  /// No description provided for @quick_fix_equipment_foam_roller.
  ///
  /// In en, this message translates to:
  /// **'Foam roller'**
  String get quick_fix_equipment_foam_roller;

  /// No description provided for @quick_fix_equipment_massage_ball.
  ///
  /// In en, this message translates to:
  /// **'Massage ball'**
  String get quick_fix_equipment_massage_ball;

  /// No description provided for @quick_fix_equipment_soft_ball.
  ///
  /// In en, this message translates to:
  /// **'Soft ball'**
  String get quick_fix_equipment_soft_ball;

  /// No description provided for @quick_fix_equipment_water_bottle.
  ///
  /// In en, this message translates to:
  /// **'Water bottle'**
  String get quick_fix_equipment_water_bottle;

  /// No description provided for @quick_fix_equipment_dowel.
  ///
  /// In en, this message translates to:
  /// **'Dowel / broomstick'**
  String get quick_fix_equipment_dowel;

  /// No description provided for @quick_fix_problem_forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get quick_fix_problem_forearms;

  /// No description provided for @quick_fix_problem_hands.
  ///
  /// In en, this message translates to:
  /// **'Hands & Fingers'**
  String get quick_fix_problem_hands;

  /// No description provided for @quick_fix_problem_hips_glutes.
  ///
  /// In en, this message translates to:
  /// **'Hips & Glutes'**
  String get quick_fix_problem_hips_glutes;

  /// No description provided for @quick_fix_problem_upper_back.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get quick_fix_problem_upper_back;

  /// No description provided for @quick_fix_signal_equipment_based.
  ///
  /// In en, this message translates to:
  /// **'Matches your available equipment'**
  String get quick_fix_signal_equipment_based;

  /// No description provided for @player_left.
  ///
  /// In en, this message translates to:
  /// **'LEFT'**
  String get player_left;

  /// No description provided for @player_more_guidance.
  ///
  /// In en, this message translates to:
  /// **'More guidance'**
  String get player_more_guidance;

  /// No description provided for @player_voice_on.
  ///
  /// In en, this message translates to:
  /// **'Voice on'**
  String get player_voice_on;

  /// No description provided for @player_voice_off.
  ///
  /// In en, this message translates to:
  /// **'Voice off'**
  String get player_voice_off;

  /// No description provided for @program_days_suffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get program_days_suffix;

  /// No description provided for @program_minutes_per_day.
  ///
  /// In en, this message translates to:
  /// **'{count} min/day'**
  String program_minutes_per_day(Object count);

  /// No description provided for @program_difficulty_beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get program_difficulty_beginner;

  /// No description provided for @program_difficulty_intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get program_difficulty_intermediate;

  /// No description provided for @program_difficulty_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get program_difficulty_advanced;

  /// No description provided for @program_recovery_route.
  ///
  /// In en, this message translates to:
  /// **'Recovery route'**
  String get program_recovery_route;

  /// No description provided for @insights_active_suffix.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get insights_active_suffix;

  /// No description provided for @player_reps_suffix.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get player_reps_suffix;

  /// No description provided for @player_step_of.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String player_step_of(Object current, Object total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
