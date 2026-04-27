// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Posture Reset';

  @override
  String get navDashboard => 'داشبورد';

  @override
  String get navSessions => 'جلسه‌ها';

  @override
  String get navQuickFix => 'راه‌حل سریع';

  @override
  String get navInsights => 'بینش‌ها';

  @override
  String get navProfile => 'پروفایل';

  @override
  String get commonRetry => 'تلاش دوباره';

  @override
  String get commonBackHome => 'بازگشت به داشبورد';

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
  String get startupLoadingTitle => 'در حال شروع برنامه';

  @override
  String get startupLoadingSubtitle =>
      'سرویس‌ها و تنظیمات اولیه برنامه در حال آماده‌سازی هستند.';

  @override
  String get startupErrorTitle => 'شروع برنامه ناموفق بود';

  @override
  String get startupErrorSubtitle =>
      'برنامه نتوانست به‌درستی بالا بیاید. تنظیمات را بررسی کن و دوباره تلاش کن.';

  @override
  String get routeNotFoundTitle => 'صفحه پیدا نشد';

  @override
  String get dashboard_hero_body =>
      'وضعیتت را دنبال کن، روندت را ببین و از داشبورد به‌عنوان مرکز بصری چرخه ریکاوری‌ات استفاده کن.';

  @override
  String get routeNotFoundSubtitle =>
      'صفحه درخواستی وجود ندارد یا دیگر در دسترس نیست.';

  @override
  String get sessions_featured_title => 'سشن‌های منتخب';

  @override
  String get sessions_all_results_title => 'همه سشن‌ها';

  @override
  String get sessions_all_results_subtitle =>
      'کل کتابخانه سشن‌ها را با فیلتر و مرتب‌سازی واقعی مرور کنید.';

  @override
  String get sessions_error_title => 'بارگذاری سشن‌ها انجام نشد';

  @override
  String get sessions_error_body =>
      'کتابخانه سشن‌ها بارگذاری نشد. دوباره تلاش کنید.';

  @override
  String get sessions_empty_title => 'هیچ سشنی موجود نیست';

  @override
  String get sessions_empty_body =>
      'در حال حاضر هیچ سشن فعالی در کاتالوگ موجود نیست.';

  @override
  String get sessions_no_results_title => 'سشن منطبق پیدا نشد';

  @override
  String get sessions_no_results_body =>
      'جستجو، دسته‌بندی یا مرتب‌سازی دیگری را امتحان کنید.';

  @override
  String get sessions_clear_filters_cta => 'پاک کردن فیلترها';

  @override
  String get sessions_search_hint =>
      'جستجو در سشن‌ها، هدف‌ها، نواحی درد و برچسب‌ها...';

  @override
  String get sessions_category_all => 'همه';

  @override
  String get sessions_category_neck_shoulders => 'گردن و شانه';

  @override
  String get sessions_category_upper_back => 'پشتِ بالا';

  @override
  String get sessions_category_lower_back => 'کمر';

  @override
  String get sessions_category_wrists_forearms => 'مچ و ساعد';

  @override
  String get sessions_category_focus => 'تمرکز';

  @override
  String get sessions_category_recovery => 'ریکاوری';

  @override
  String get sessions_category_quiet_desk => 'آرام و مناسب میز';

  @override
  String get sessions_sort_recommended => 'پیشنهادی';

  @override
  String get sessions_sort_duration_shortest => 'مدت: کوتاه‌تر';

  @override
  String get sessions_sort_duration_longest => 'مدت: طولانی‌تر';

  @override
  String get sessions_sort_intensity_lowest => 'شدت: کمتر';

  @override
  String get sessions_sort_intensity_highest => 'شدت: بیشتر';

  @override
  String get sessions_sort_alphabetical => 'الفبایی';

  @override
  String get sessions_filter_silent_only => 'فقط بی‌صدا';

  @override
  String get sessions_filter_beginner_only => 'فقط مناسب مبتدی';

  @override
  String sessions_duration_minutes_format(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get sessions_intro_title =>
      'سشن‌های ریکاوری ساختارمند برای روزهای کاری واقعی.';

  @override
  String get sessions_intro_body =>
      'سشن‌های واقعی را بر اساس ناحیه درد، شرایط کاری، مدت و شدت جستجو و فیلتر کنید.';

  @override
  String get sessions_intensity_gentle => 'خیلی ملایم';

  @override
  String get sessions_intensity_light => 'ملایم';

  @override
  String get sessions_intensity_moderate => 'متوسط';

  @override
  String get sessions_intensity_strong => 'شدید';

  @override
  String get sessions_tag_silent => 'بی‌صدا';

  @override
  String get sessions_tag_beginner => 'مناسب مبتدی';

  @override
  String get session_detail_start_button => 'شروع جلسه';

  @override
  String get session_detail_save_button => 'ذخیره';

  @override
  String get session_detail_saved_button => 'ذخیره‌شده';

  @override
  String get session_detail_saved_success => 'جلسه ذخیره شد.';

  @override
  String get session_detail_unsaved_success => 'جلسه از ذخیره‌ها حذف شد.';

  @override
  String get session_detail_sign_in_to_save =>
      'برای ذخیره کردن جلسه وارد حساب شوید.';

  @override
  String get session_detail_go_to_profile => 'پروفایل';

  @override
  String get session_detail_save_requires_account_hint =>
      'ذخیره‌کردن نیاز به ورود دارد.';

  @override
  String session_detail_duration_format(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get session_detail_silent_friendly => 'مناسب محیط ساکت';

  @override
  String get session_detail_beginner_friendly => 'مناسب مبتدی‌ها';

  @override
  String get session_detail_goals_title => 'هدف‌ها';

  @override
  String get session_detail_compatibility_title => 'سازگاری';

  @override
  String get session_detail_modes_title => 'مناسب برای';

  @override
  String get session_detail_environment_title => 'بهترین محیط';

  @override
  String get session_detail_related_title => 'جلسه‌های مرتبط';

  @override
  String get session_detail_related_empty => 'جلسه مرتبطی پیدا نشد.';

  @override
  String get session_detail_related_error =>
      'بارگذاری جلسه‌های مرتبط انجام نشد.';

  @override
  String get session_intensity_gentle => 'خیلی سبک';

  @override
  String get session_intensity_light => 'سبک';

  @override
  String get session_intensity_moderate => 'متوسط';

  @override
  String get session_intensity_strong => 'شدید';

  @override
  String get session_goal_pain_relief => 'کاهش درد';

  @override
  String get session_goal_posture_reset => 'تنظیم دوباره وضعیت بدن';

  @override
  String get session_goal_focus_prep => 'آماده‌سازی تمرکز';

  @override
  String get session_goal_recovery => 'ریکاوری';

  @override
  String get session_goal_mobility => 'افزایش تحرک';

  @override
  String get session_goal_decompression => 'ریلکس و آزادسازی';

  @override
  String get session_mode_dad => 'حالت پدر';

  @override
  String get session_mode_night => 'حالت شب';

  @override
  String get session_mode_focus => 'حالت تمرکز';

  @override
  String get session_mode_pain_relief => 'حالت کاهش درد';

  @override
  String get session_env_desk_friendly => 'مناسب پشت میز';

  @override
  String get session_env_office_friendly => 'مناسب محیط کار';

  @override
  String get session_env_home_friendly => 'مناسب خانه';

  @override
  String get session_env_no_mat => 'بدون نیاز به زیرانداز';

  @override
  String get session_env_low_space => 'مناسب فضای کم';

  @override
  String get session_env_quiet => 'مناسب محیط ساکت';

  @override
  String get session_detail_equipment_title => 'تجهیزات';

  @override
  String get session_detail_saving_cta => 'در حال ذخیره...';

  @override
  String get session_detail_steps_empty =>
      'هنوز پیش‌نمایش مرحله‌ها برای این جلسه موجود نیست.';

  @override
  String get session_detail_step_skippable => 'قابل رد کردن';

  @override
  String get session_step_type_setup => 'آماده‌سازی';

  @override
  String get session_step_type_movement => 'حرکت';

  @override
  String get session_step_type_hold => 'نگه‌داشتن';

  @override
  String get session_step_type_breath => 'تنفس';

  @override
  String get session_step_type_transition => 'انتقال';

  @override
  String get session_detail_save_failed =>
      'به‌روزرسانی جلسه ذخیره‌شده انجام نشد.';

  @override
  String get session_step_type_cooldown => 'پایان';

  @override
  String get auth_page_title => 'حساب';

  @override
  String get auth_sign_in_title => 'ورود';

  @override
  String get auth_sign_up_title => 'ایجاد حساب';

  @override
  String get auth_sign_in_subtitle =>
      'وارد شوید تا بتوانید جلسه‌ها را ذخیره کنید و داده‌های ریکاوری را به حساب خود وصل کنید.';

  @override
  String get auth_sign_up_subtitle =>
      'برای ذخیره‌کردن جلسه‌ها و داشتن تداوم بین دستگاه‌ها حساب ایجاد کنید.';

  @override
  String get auth_sign_in_tab => 'ورود';

  @override
  String get auth_sign_up_tab => 'ایجاد حساب';

  @override
  String get auth_email_label => 'ایمیل';

  @override
  String get auth_password_label => 'رمز عبور';

  @override
  String get auth_confirm_password_label => 'تأیید رمز عبور';

  @override
  String get auth_email_required => 'ایمیل لازم است.';

  @override
  String get auth_email_invalid => 'یک ایمیل معتبر وارد کنید.';

  @override
  String get auth_password_required => 'رمز عبور لازم است.';

  @override
  String get auth_password_too_short => 'رمز عبور باید حداقل ۸ کاراکتر باشد.';

  @override
  String get auth_confirm_password_required => 'لطفاً رمز عبور را تأیید کنید.';

  @override
  String get auth_confirm_password_mismatch => 'رمزهای عبور یکسان نیستند.';

  @override
  String get auth_submitting => 'لطفاً صبر کنید...';

  @override
  String get auth_sign_in_button => 'ورود';

  @override
  String get auth_sign_up_button => 'ایجاد حساب';

  @override
  String get auth_sign_in_success => 'با موفقیت وارد شدید.';

  @override
  String get auth_sign_up_success_signed_in => 'حساب ساخته شد و وارد شدید.';

  @override
  String get auth_sign_up_check_email =>
      'حساب ساخته شد. برای تأیید حساب، ایمیل خود را بررسی کنید.';

  @override
  String get auth_unknown_error => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get auth_signed_out_success => 'با موفقیت خارج شدید.';

  @override
  String get profile_sign_out_tooltip => 'خروج';

  @override
  String get profile_account_access_section_title => 'دسترسی حساب';

  @override
  String get profile_account_access_section_subtitle =>
      'وارد شوید تا بتوانید جلسه‌ها را ذخیره کنید و داده‌های حساب را متصل نگه دارید.';

  @override
  String get profile_account_sign_in_title => 'ورود یا ایجاد حساب';

  @override
  String get profile_account_sign_in_subtitle =>
      'با ایمیل و رمز عبور وارد شوید تا ذخیره‌سازی جلسه‌ها و تداوم حساب فعال شود.';

  @override
  String get profile_account_manage_title => 'مدیریت دسترسی حساب';

  @override
  String get profile_account_signed_in_subtitle => 'با موفقیت وارد شدید.';

  @override
  String get profile_status_plan_signed_in_value => 'حساب آماده است';

  @override
  String get profile_status_plan_signed_in_subtitle =>
      'ذخیره‌سازی جلسه فعال است';

  @override
  String get profile_account_guest_name => 'مهمان';

  @override
  String get profile_account_guest_subtitle =>
      'برای ذخیره‌کردن جلسه‌ها و نگه داشتن پیشرفت خود وارد شوید.';

  @override
  String get profile_account_guest_initial => 'م';

  @override
  String get profile_account_signed_in_name => 'حساب';

  @override
  String get profile_account_tag_signed_in => 'وارد شده';

  @override
  String get profile_account_tag_session_save => 'ذخیره‌سازی جلسه فعال';

  @override
  String get profile_account_tag_guest => 'مهمان';

  @override
  String get profile_account_tag_sign_in_needed =>
      'برای ذخیره نیاز به ورود است';

  @override
  String get profile_account_sign_in_button => 'ورود';

  @override
  String get profile_account_create_button => 'ایجاد حساب';

  @override
  String get profile_account_sign_out_button => 'خروج';

  @override
  String get profile_preferences_section_subtitle =>
      'پیش‌فرض‌های فعلی اپ که روی پیشنهادها و سشن‌های کوتاه پیشنهادی اثر می‌گذارند.';

  @override
  String get profile_status_section_subtitle =>
      'وضعیت فعلی حساب و در دسترس بودن ذخیره‌سازی جلسه‌ها.';

  @override
  String get profile_status_account_title => 'حساب';

  @override
  String get profile_status_account_signed_in => 'وارد شده';

  @override
  String get profile_status_account_guest => 'مهمان';

  @override
  String get profile_status_account_signed_in_subtitle =>
      'نشست حساب شما فعال است.';

  @override
  String get profile_status_account_guest_subtitle =>
      'برای فعال شدن ذخیره‌سازی جلسه‌ها وارد شوید.';

  @override
  String get profile_status_session_save_title => 'ذخیره‌سازی جلسه';

  @override
  String get profile_status_session_save_enabled => 'فعال';

  @override
  String get profile_status_session_save_disabled => 'در دسترس نیست';

  @override
  String get profile_status_session_save_enabled_subtitle =>
      'جلسه‌های ذخیره‌شده برای این حساب در دسترس هستند.';

  @override
  String get profile_status_session_save_disabled_subtitle =>
      'قبل از ذخیره‌کردن جلسه‌ها باید وارد شوید.';

  @override
  String get profile_status_plan_subtitle => 'پریمیوم فعال نیست.';

  @override
  String get settings_language_sheet_title => 'انتخاب زبان';

  @override
  String get settings_language_sheet_subtitle =>
      'یک زبان برای کل اپ انتخاب کنید.';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_german => 'Deutsch';

  @override
  String get settings_language_persian => 'فارسی';

  @override
  String get session_player_title => 'پلیر';

  @override
  String get player_close_tooltip => 'بستن پلیر';

  @override
  String get player_progress_title => 'پیشرفت سشن';

  @override
  String get player_step_label_prefix => 'مرحله';

  @override
  String get player_step_label_empty => 'مرحله‌ای وجود ندارد';

  @override
  String get player_current_step_label => 'مرحله فعلی';

  @override
  String get player_step_type_label => 'نوع';

  @override
  String get player_step_duration_label => 'مدت';

  @override
  String get player_step_skippable_label => 'قابل رد کردن';

  @override
  String get player_target_label => 'هدف';

  @override
  String get player_terminal_title => 'وضعیت زنده';

  @override
  String get player_pause_cta => 'توقف';

  @override
  String get player_resume_cta => 'ادامه';

  @override
  String get player_previous_cta => 'قبلی';

  @override
  String get player_next_cta => 'بعدی';

  @override
  String get player_skip_cta => 'رد کردن';

  @override
  String get player_replay_cta => 'تکرار مرحله';

  @override
  String get player_finish_cta => 'پایان سشن';

  @override
  String get player_exit_title => 'سشن تمام شود؟';

  @override
  String get player_exit_message =>
      'سشن فعلی بسته می‌شود و پیشرفت به‌صورت اجرای ناقص ذخیره می‌شود.';

  @override
  String get player_exit_cancel_cta => 'ادامه سشن';

  @override
  String get player_exit_confirm_cta => 'پایان سشن';

  @override
  String get player_not_found_title => 'سشن پیدا نشد';

  @override
  String get player_not_found_message =>
      'سشن درخواستی پیدا نشد یا دیگر در دسترس نیست.';

  @override
  String get player_no_steps_title => 'مرحله‌ای موجود نیست';

  @override
  String get player_no_steps_message => 'این سشن هنوز مرحله قابل اجرا ندارد.';

  @override
  String get player_error_title => 'شروع پلیر ممکن نشد';

  @override
  String get player_error_subtitle => 'هنگام بارگذاری این سشن مشکلی پیش آمد.';

  @override
  String get player_back_cta => 'بازگشت';

  @override
  String get player_loading_title => 'در حال آماده‌سازی پلیر...';

  @override
  String get player_auth_required_title => 'ورود لازم است';

  @override
  String get player_auth_required_message =>
      'برای شروع و ثبت اجرای سشن باید وارد حساب شوی.';

  @override
  String get player_auth_required_cta => 'ورود';

  @override
  String get player_status_completed => 'تکمیل شد';

  @override
  String get player_status_running_log => '[RUN] سشن فعال است';

  @override
  String get player_status_paused_log => '[PAUSE] سشن متوقف است';

  @override
  String get player_status_completed_log => '[DONE] سشن با موفقیت کامل شد';

  @override
  String get player_next_step_log_prefix => '[NEXT]';

  @override
  String get player_runtime_summary_title => 'خلاصه اجرا';

  @override
  String get player_runtime_elapsed => 'سپری‌شده';

  @override
  String get player_runtime_remaining => 'باقی‌مانده';

  @override
  String get player_runtime_step_remaining => 'باقی‌مانده مرحله';

  @override
  String get player_breath_cue_title => 'راهنمای تنفس';

  @override
  String get player_safety_note_title => 'نکته ایمنی';

  @override
  String get player_completion_title => 'سشن کامل شد';

  @override
  String get player_completion_subtitle => 'اجرای این سشن با موفقیت ذخیره شد.';

  @override
  String get player_completion_steps => 'تعداد مراحل';

  @override
  String get player_completion_total_time => 'زمان کل';

  @override
  String get player_completion_back_to_detail => 'بازگشت به جزئیات سشن';

  @override
  String get player_media_placeholder_chip => 'پیش‌نمایش حرکت';

  @override
  String get player_media_placeholder_body_short =>
      'ویدیو یا گیف راهنمای این مرحله بعداً اینجا نمایش داده می‌شود.';

  @override
  String get player_media_placeholder_body =>
      'ویدیو یا گیف راهنمای این مرحله بعداً اینجا نمایش داده می‌شود. ساختار پلیر از الان برای مدیای واقعی آماده است.';

  @override
  String get player_completion_body_impact_title =>
      'در این تمرین چه تغییری ایجاد شد';

  @override
  String get player_completion_effect_release => 'رهایی + تحرک بهتر';

  @override
  String get player_completion_effect_reset => 'ریست وضعیت بدنی';

  @override
  String get session_detail_back_tooltip => 'بازگشت';

  @override
  String get player_completion_close => 'بستن';

  @override
  String get quick_fix_title => 'کوئیک فیکس';

  @override
  String get quick_fix_history_tooltip => 'کوئیک فیکس‌های اخیر';

  @override
  String get quick_fix_loading_title => 'در حال آماده‌سازی کوئیک فیکس…';

  @override
  String get quick_fix_error_title => 'بارگذاری کوئیک فیکس ممکن نشد';

  @override
  String get quick_fix_error_body => 'لطفاً دوباره تلاش کنید.';

  @override
  String get quick_fix_empty_title => 'هیچ پیشنهادی در دسترس نیست';

  @override
  String get quick_fix_empty_body =>
      'شرایط فعلی خود را تغییر دهید تا یک پیشنهاد زنده دریافت شود.';

  @override
  String get quick_fix_hero_eyebrow => 'راه‌انداز تطبیقی ریکاوری';

  @override
  String get quick_fix_hero_title =>
      'در چند ثانیه سشن مناسب وضعیت فعلی بدنت را پیدا کن.';

  @override
  String get quick_fix_hero_body =>
      'کوئیک فیکس نقطه درد فعلی، زمان در دسترس، سطح انرژی و محیط تو را به یک پیشنهاد واقعی از کاتالوگ زنده سشن‌ها تبدیل می‌کند.';

  @override
  String get quick_fix_hero_stat_fast => 'پیشنهاد سریع';

  @override
  String get quick_fix_hero_stat_silent => 'محیط بی‌صدا';

  @override
  String get quick_fix_hero_stat_personalized => 'شخصی‌سازی زنده';

  @override
  String get quick_fix_problem_section_title => 'مشکل';

  @override
  String get quick_fix_problem_section_subtitle =>
      'نقطه درد یا هدف ریسِتی را انتخاب کن که الآن بیشترین اهمیت را دارد.';

  @override
  String get quick_fix_context_section_title => 'زمان + فضا';

  @override
  String get quick_fix_context_section_subtitle =>
      'پیشنهاد را متناسب با شرایط واقعی فعلی خود نگه دار.';

  @override
  String get quick_fix_state_section_title => 'انرژی + حالت';

  @override
  String get quick_fix_state_section_subtitle =>
      'پیشنهاد را بر اساس شدت موردنیاز و زمینه فعلی تنظیم کن.';

  @override
  String get quick_fix_recommendation_section_title => 'پیشنهاد';

  @override
  String get quick_fix_recommendation_section_subtitle =>
      'موتور پیشنهاد بر اساس وضعیت فعلی بدن تو، سشن مناسب را به‌روزرسانی می‌کند.';

  @override
  String get quick_fix_recommendation_missing => 'هنوز پیشنهادی در دسترس نیست.';

  @override
  String get quick_fix_primary_match_label => 'بهترین انتخاب برای الآن';

  @override
  String get quick_fix_reasoning_default =>
      'این پیشنهاد به این دلیل انتخاب شده که با مشکل فعلی، زمان در دسترس و محیط تو هماهنگی بالایی دارد.';

  @override
  String get quick_fix_more_matches_title => 'پیشنهادهای قوی دیگر';

  @override
  String get quick_fix_start_now_cta => 'شروع کن';

  @override
  String get quick_fix_view_details_cta => 'مشاهده جزئیات';

  @override
  String get quick_fix_silent_mode_title => 'حالت بی‌صدا';

  @override
  String get quick_fix_problem_neck => 'گردن';

  @override
  String get quick_fix_problem_shoulder => 'شانه';

  @override
  String get quick_fix_problem_wrist => 'مچ';

  @override
  String get quick_fix_problem_back => 'کمر';

  @override
  String get quick_fix_problem_eye => 'چشم';

  @override
  String get quick_fix_problem_stress => 'استرس';

  @override
  String get quick_fix_time_2 => '۲ دقیقه';

  @override
  String get quick_fix_time_4 => '۴ دقیقه';

  @override
  String get quick_fix_time_6 => '۶ دقیقه';

  @override
  String get quick_fix_time_10 => '۱۰ دقیقه';

  @override
  String get quick_fix_location_desk => 'میز';

  @override
  String get quick_fix_location_chair => 'صندلی';

  @override
  String get quick_fix_location_standing => 'ایستاده';

  @override
  String get quick_fix_location_floor => 'زمین';

  @override
  String get quick_fix_location_bedside => 'کنار تخت';

  @override
  String get quick_fix_energy_low => 'کم';

  @override
  String get quick_fix_energy_medium => 'متوسط';

  @override
  String get quick_fix_energy_high => 'زیاد';

  @override
  String get quick_fix_mode_dad => 'حالت Dad';

  @override
  String get quick_fix_mode_night => 'کدنویسی شب';

  @override
  String get quick_fix_mode_focus => 'حالت تمرکز';

  @override
  String get quick_fix_mode_pain_relief => 'درد';

  @override
  String get player_pre_state_title => 'یک چک کوتاه قبل از شروع';

  @override
  String get player_pre_state_subtitle =>
      'قبل از شروع این سشن چند وضعیت کوتاه ثبت کن تا بعداً بتوانیم نتیجه و تغییرات را بهتر دنبال کنیم.';

  @override
  String get player_pre_state_energy_title => 'انرژی';

  @override
  String get player_pre_state_stress_title => 'استرس';

  @override
  String get player_pre_state_focus_title => 'تمرکز';

  @override
  String get player_pre_state_intent_title => 'هدف';

  @override
  String get player_pre_state_pain_areas_title => 'ناحیه درد';

  @override
  String get player_pre_state_skip => 'فعلاً رد کن';

  @override
  String get player_pre_state_start_cta => 'شروع سشن';

  @override
  String get player_feedback_title => 'این سشن چه حسی داشت؟';

  @override
  String get player_feedback_abandoned_title =>
      'قبل از خروج، این سشن چه حسی داشت؟';

  @override
  String get player_feedback_summary_title => 'خلاصه سشن';

  @override
  String get player_feedback_abandoned_summary_title => 'سشن زودتر تمام شد';

  @override
  String get player_feedback_helped_title => 'کمک کرد؟';

  @override
  String get player_feedback_tension_title => 'گرفتگی';

  @override
  String get player_feedback_pain_title => 'درد';

  @override
  String get player_feedback_energy_title => 'انرژی';

  @override
  String get player_feedback_fit_title => 'تناسب سشن';

  @override
  String get player_feedback_repeat_title => 'دوباره این سشن را انجام می‌دهی؟';

  @override
  String get player_feedback_yes => 'بله';

  @override
  String get player_feedback_no => 'نه';

  @override
  String get player_feedback_repeat_yes => 'دوباره انجام می‌دهم';

  @override
  String get player_feedback_repeat_no => 'احتمالاً نه';

  @override
  String get player_feedback_submit => 'ذخیره بازخورد';

  @override
  String get player_feedback_close => 'بستن';

  @override
  String get common_level_low => 'کم';

  @override
  String get common_level_medium => 'متوسط';

  @override
  String get common_level_high => 'زیاد';

  @override
  String get common_delta_worse => 'بدتر';

  @override
  String get common_delta_same => 'بدون تغییر';

  @override
  String get common_delta_better => 'بهتر';

  @override
  String get common_fit_poor => 'ضعیف';

  @override
  String get common_fit_okay => 'قابل قبول';

  @override
  String get common_fit_great => 'خیلی خوب';

  @override
  String get intent_relief => 'کاهش فشار';

  @override
  String get intent_reset => 'ریست';

  @override
  String get intent_focus => 'تمرکز';

  @override
  String get intent_unwind => 'ریلکس';

  @override
  String get pain_neck => 'گردن';

  @override
  String get pain_shoulders => 'شانه‌ها';

  @override
  String get pain_upper_back => 'پشت بالا';

  @override
  String get pain_lower_back => 'کمر';

  @override
  String get pain_wrists => 'مچ‌ها';

  @override
  String get dashboard_title => 'داشبورد';

  @override
  String get dashboard_error_title => 'بارگذاری داشبورد انجام نشد';

  @override
  String get dashboard_error_body => 'لطفاً دوباره تلاش کن.';

  @override
  String get dashboard_error_retry => 'تلاش دوباره';

  @override
  String get dashboard_empty_title => 'هنوز داده‌ای برای داشبورد وجود ندارد';

  @override
  String get dashboard_empty_body =>
      'یک سشن را کامل کن یا Quick Fix را اجرا کن تا داشبورد پر شود.';

  @override
  String get dashboard_empty_refresh => 'بروزرسانی';

  @override
  String get dashboard_hero_overline => 'مرکز کنترل ریکاوری';

  @override
  String get dashboard_hero_title => 'سیستم ریکاوری تو در جریان است.';

  @override
  String get dashboard_hero_body_with_next =>
      'وضعیتت را دنبال کن، روندت را ببین و سشن بعدی مناسب را بدون خروج از داشبورد شروع کن.';

  @override
  String get dashboard_hero_start_next => 'شروع سشن بعدی';

  @override
  String get dashboard_hero_quick_fix => 'کوئیک فیکس';

  @override
  String get dashboard_hero_body_map => 'نقشه بدن';

  @override
  String get dashboard_readiness_title => 'امتیاز آمادگی';

  @override
  String get dashboard_state_energy => 'انرژی';

  @override
  String get dashboard_state_stress => 'استرس';

  @override
  String get dashboard_state_focus => 'تمرکز';

  @override
  String get dashboard_state_unknown => 'نامشخص';

  @override
  String get dashboard_minutes_week => 'دقایق این هفته';

  @override
  String get dashboard_completed_week => 'سشن‌های کامل‌شده';

  @override
  String get dashboard_quickfix_week => 'شروع‌های Quick Fix';

  @override
  String get dashboard_body_intelligence_title => 'هوش بدنی';

  @override
  String get dashboard_body_intelligence_subtitle =>
      'ناحیه‌های غالب، کیفیت ریکاوری اخیر و بخش‌هایی که بیشتر از همه نیاز به توجه دارند.';

  @override
  String get dashboard_help_rate => 'نرخ کمک';

  @override
  String get dashboard_consistency => 'ثبات';

  @override
  String get dashboard_dominant_zone => 'ناحیه غالب';

  @override
  String get dashboard_zone_unknown => 'هنوز ناحیه مشخصی نیست';

  @override
  String get dashboard_empty_body_zones =>
      'الگوهای ناحیه‌های بدن بعد از ثبت سشن‌های بیشتر نمایش داده می‌شوند.';

  @override
  String get dashboard_trends_title => 'روندهای ریکاوری';

  @override
  String get dashboard_trends_subtitle =>
      'یک نمای بصری از اینکه چقدر زمان برای ریکاوری ثبت می‌کنی و این سشن‌ها چقدر مفید بوده‌اند.';

  @override
  String get dashboard_chart_minutes_title => 'دقایق ریکاوری';

  @override
  String get dashboard_chart_relief_title => 'کیفیت بهبود';

  @override
  String get dashboard_heatmap_title => 'هیت‌مپ ریکاوری';

  @override
  String get dashboard_heatmap_subtitle =>
      'نمایی از میزان پیوستگی فعالیت سیستم ریکاوری تو در سه هفته اخیر.';

  @override
  String get dashboard_recent_runs_title => 'آخرین اجراهای ریکاوری';

  @override
  String get dashboard_recent_runs_subtitle =>
      'یک نمای فشرده از آخرین اجراها، نتیجه آن‌ها و مسیری که از آن شروع شده‌اند.';

  @override
  String get dashboard_empty_recent_runs =>
      'آخرین اجراهای سشن اینجا نمایش داده می‌شوند.';

  @override
  String get dashboard_body_map_cta_title => 'ناحیه‌های فعال تنش را بررسی کن';

  @override
  String get dashboard_body_map_cta_body =>
      'نقشه بدن را باز کن تا ناحیه‌های درد فعال را ببینی، بهبودها را بررسی کنی و مستقیم به سشن مناسب بعدی بروی.';

  @override
  String get dashboard_open_body_map => 'باز کردن نقشه بدن';

  @override
  String get dashboard_next_session_reason_quick_fix =>
      'بر اساس آخرین زمینه Quick Fix به تو پیشنهاد شده';

  @override
  String get dashboard_next_session_reason_resume =>
      'یک پیشنهاد مناسب بر اساس فعالیت‌های اخیر تو';
}
