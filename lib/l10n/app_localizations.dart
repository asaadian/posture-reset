import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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
    Locale('fa'),
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
      <String>['de', 'en', 'fa'].contains(locale.languageCode);

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
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
