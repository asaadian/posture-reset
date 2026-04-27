// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Posture Reset';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSessions => 'Sitzungen';

  @override
  String get navQuickFix => 'Schnellhilfe';

  @override
  String get navInsights => 'Einblicke';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonBackHome => 'Zum Dashboard';

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
  String get startupLoadingTitle => 'App wird gestartet';

  @override
  String get startupLoadingSubtitle =>
      'Dienste und Startkonfiguration werden vorbereitet.';

  @override
  String get startupErrorTitle => 'Start fehlgeschlagen';

  @override
  String get startupErrorSubtitle =>
      'Die App konnte nicht korrekt gestartet werden. Prüfe die Konfiguration und versuche es erneut.';

  @override
  String get routeNotFoundTitle => 'Seite nicht gefunden';

  @override
  String get dashboard_hero_body =>
      'Verfolge deinen Zustand, prüfe deinen Verlauf und nutze das Dashboard als visuelles Zentrum deines Recovery-Workflows.';

  @override
  String get routeNotFoundSubtitle =>
      'Die angeforderte Seite existiert nicht oder ist nicht mehr verfügbar.';

  @override
  String get sessions_featured_title => 'Ausgewählte Sessions';

  @override
  String get sessions_all_results_title => 'Alle Sessions';

  @override
  String get sessions_all_results_subtitle =>
      'Durchsuche die gesamte Session-Bibliothek mit echten Filtern und Sortierung.';

  @override
  String get sessions_error_title => 'Sessions konnten nicht geladen werden';

  @override
  String get sessions_error_body =>
      'Die Session-Bibliothek konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get sessions_empty_title => 'Keine Sessions verfügbar';

  @override
  String get sessions_empty_body =>
      'Derzeit sind keine aktiven Sessions im Katalog verfügbar.';

  @override
  String get sessions_no_results_title => 'Keine passenden Sessions';

  @override
  String get sessions_no_results_body =>
      'Versuche eine andere Suche, Kategorie oder Sortierung.';

  @override
  String get sessions_clear_filters_cta => 'Filter zurücksetzen';

  @override
  String get sessions_search_hint =>
      'Sessions, Ziele, Schmerzbereiche und Tags durchsuchen...';

  @override
  String get sessions_category_all => 'Alle';

  @override
  String get sessions_category_neck_shoulders => 'Nacken & Schultern';

  @override
  String get sessions_category_upper_back => 'Oberer Rücken';

  @override
  String get sessions_category_lower_back => 'Unterer Rücken';

  @override
  String get sessions_category_wrists_forearms => 'Handgelenke & Unterarme';

  @override
  String get sessions_category_focus => 'Fokus';

  @override
  String get sessions_category_recovery => 'Erholung';

  @override
  String get sessions_category_quiet_desk => 'Leise & Schreibtisch';

  @override
  String get sessions_sort_recommended => 'Empfohlen';

  @override
  String get sessions_sort_duration_shortest => 'Dauer: Kürzeste zuerst';

  @override
  String get sessions_sort_duration_longest => 'Dauer: Längste zuerst';

  @override
  String get sessions_sort_intensity_lowest => 'Intensität: Niedrigste zuerst';

  @override
  String get sessions_sort_intensity_highest => 'Intensität: Höchste zuerst';

  @override
  String get sessions_sort_alphabetical => 'Alphabetisch';

  @override
  String get sessions_filter_silent_only => 'Nur leise';

  @override
  String get sessions_filter_beginner_only => 'Nur für Einsteiger';

  @override
  String sessions_duration_minutes_format(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String get sessions_intro_title =>
      'Strukturierte Recovery-Sessions für echte Arbeitstage.';

  @override
  String get sessions_intro_body =>
      'Suche und filtere echte Sessions nach Schmerzbereich, Arbeitskontext, Dauer und Intensität.';

  @override
  String get sessions_intensity_gentle => 'Sehr sanft';

  @override
  String get sessions_intensity_light => 'Leicht';

  @override
  String get sessions_intensity_moderate => 'Mittel';

  @override
  String get sessions_intensity_strong => 'Intensiv';

  @override
  String get sessions_tag_silent => 'Leise';

  @override
  String get sessions_tag_beginner => 'Für Einsteiger';

  @override
  String get session_detail_start_button => 'Sitzung starten';

  @override
  String get session_detail_save_button => 'Speichern';

  @override
  String get session_detail_saved_button => 'Gespeichert';

  @override
  String get session_detail_saved_success => 'Sitzung gespeichert.';

  @override
  String get session_detail_unsaved_success =>
      'Sitzung aus Gespeichert entfernt.';

  @override
  String get session_detail_sign_in_to_save =>
      'Melde dich an, um Sitzungen zu speichern.';

  @override
  String get session_detail_go_to_profile => 'Profil';

  @override
  String get session_detail_save_requires_account_hint =>
      'Zum Speichern ist eine Anmeldung erforderlich.';

  @override
  String session_detail_duration_format(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String get session_detail_silent_friendly => 'Leise geeignet';

  @override
  String get session_detail_beginner_friendly => 'Für Anfänger geeignet';

  @override
  String get session_detail_goals_title => 'Ziele';

  @override
  String get session_detail_compatibility_title => 'Kompatibilität';

  @override
  String get session_detail_modes_title => 'Passt gut zu';

  @override
  String get session_detail_environment_title => 'Beste Umgebung';

  @override
  String get session_detail_related_title => 'Ähnliche Sitzungen';

  @override
  String get session_detail_related_empty =>
      'Keine ähnlichen Sitzungen gefunden.';

  @override
  String get session_detail_related_error =>
      'Ähnliche Sitzungen konnten nicht geladen werden.';

  @override
  String get session_intensity_gentle => 'Sanft';

  @override
  String get session_intensity_light => 'Leicht';

  @override
  String get session_intensity_moderate => 'Mittel';

  @override
  String get session_intensity_strong => 'Intensiv';

  @override
  String get session_goal_pain_relief => 'Schmerzlinderung';

  @override
  String get session_goal_posture_reset => 'Haltungs-Reset';

  @override
  String get session_goal_focus_prep => 'Fokus vorbereiten';

  @override
  String get session_goal_recovery => 'Erholung';

  @override
  String get session_goal_mobility => 'Mobilität';

  @override
  String get session_goal_decompression => 'Entspannung';

  @override
  String get session_mode_dad => 'Dad Mode';

  @override
  String get session_mode_night => 'Nachtmodus';

  @override
  String get session_mode_focus => 'Fokusmodus';

  @override
  String get session_mode_pain_relief => 'Schmerzlinderungsmodus';

  @override
  String get session_env_desk_friendly => 'Schreibtischgeeignet';

  @override
  String get session_env_office_friendly => 'Bürogeeignet';

  @override
  String get session_env_home_friendly => 'Für Zuhause geeignet';

  @override
  String get session_env_no_mat => 'Keine Matte erforderlich';

  @override
  String get session_env_low_space => 'Für wenig Platz geeignet';

  @override
  String get session_env_quiet => 'Leise geeignet';

  @override
  String get session_detail_equipment_title => 'Ausrüstung';

  @override
  String get session_detail_saving_cta => 'Wird gespeichert...';

  @override
  String get session_detail_steps_empty =>
      'Für diese Sitzung ist noch keine Schrittvorschau verfügbar.';

  @override
  String get session_detail_step_skippable => 'Überspringbar';

  @override
  String get session_step_type_setup => 'Vorbereitung';

  @override
  String get session_step_type_movement => 'Bewegung';

  @override
  String get session_step_type_hold => 'Halten';

  @override
  String get session_step_type_breath => 'Atmung';

  @override
  String get session_step_type_transition => 'Übergang';

  @override
  String get session_detail_save_failed =>
      'Gespeicherte Sitzung konnte nicht aktualisiert werden.';

  @override
  String get session_step_type_cooldown => 'Abschluss';

  @override
  String get auth_page_title => 'Konto';

  @override
  String get auth_sign_in_title => 'Anmelden';

  @override
  String get auth_sign_up_title => 'Konto erstellen';

  @override
  String get auth_sign_in_subtitle =>
      'Melde dich an, um Sitzungen zu speichern und deine Erholungsdaten mit deinem Konto zu verknüpfen.';

  @override
  String get auth_sign_up_subtitle =>
      'Erstelle ein Konto, um Sitzungen zu speichern und Kontinuität über Geräte hinweg zu erhalten.';

  @override
  String get auth_sign_in_tab => 'Anmelden';

  @override
  String get auth_sign_up_tab => 'Konto erstellen';

  @override
  String get auth_email_label => 'E-Mail';

  @override
  String get auth_password_label => 'Passwort';

  @override
  String get auth_confirm_password_label => 'Passwort bestätigen';

  @override
  String get auth_email_required => 'E-Mail ist erforderlich.';

  @override
  String get auth_email_invalid => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get auth_password_required => 'Passwort ist erforderlich.';

  @override
  String get auth_password_too_short =>
      'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get auth_confirm_password_required => 'Bitte bestätige dein Passwort.';

  @override
  String get auth_confirm_password_mismatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get auth_submitting => 'Bitte warten...';

  @override
  String get auth_sign_in_button => 'Anmelden';

  @override
  String get auth_sign_up_button => 'Konto erstellen';

  @override
  String get auth_sign_in_success => 'Erfolgreich angemeldet.';

  @override
  String get auth_sign_up_success_signed_in => 'Konto erstellt und angemeldet.';

  @override
  String get auth_sign_up_check_email =>
      'Konto erstellt. Prüfe deine E-Mails, um dein Konto zu bestätigen.';

  @override
  String get auth_unknown_error =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get auth_signed_out_success => 'Erfolgreich abgemeldet.';

  @override
  String get profile_sign_out_tooltip => 'Abmelden';

  @override
  String get profile_account_access_section_title => 'Kontozugang';

  @override
  String get profile_account_access_section_subtitle =>
      'Melde dich an, um Sitzungen zu speichern und deine Kontodaten zu verbinden.';

  @override
  String get profile_account_sign_in_title => 'Anmelden oder Konto erstellen';

  @override
  String get profile_account_sign_in_subtitle =>
      'Nutze E-Mail und Passwort, um gespeicherte Sitzungen und Kontinuität freizuschalten.';

  @override
  String get profile_account_manage_title => 'Kontozugang verwalten';

  @override
  String get profile_account_signed_in_subtitle => 'Erfolgreich angemeldet.';

  @override
  String get profile_status_plan_signed_in_value => 'Konto bereit';

  @override
  String get profile_status_plan_signed_in_subtitle =>
      'Sitzungsspeicherung verfügbar';

  @override
  String get profile_account_guest_name => 'Gast';

  @override
  String get profile_account_guest_subtitle =>
      'Melde dich an, um Sitzungen zu speichern und deinen Fortschritt zu verbinden.';

  @override
  String get profile_account_guest_initial => 'G';

  @override
  String get profile_account_signed_in_name => 'Konto';

  @override
  String get profile_account_tag_signed_in => 'Angemeldet';

  @override
  String get profile_account_tag_session_save => 'Sitzungsspeicherung aktiv';

  @override
  String get profile_account_tag_guest => 'Gast';

  @override
  String get profile_account_tag_sign_in_needed =>
      'Anmeldung zum Speichern erforderlich';

  @override
  String get profile_account_sign_in_button => 'Anmelden';

  @override
  String get profile_account_create_button => 'Konto erstellen';

  @override
  String get profile_account_sign_out_button => 'Abmelden';

  @override
  String get profile_preferences_section_subtitle =>
      'Aktuelle App-Standards, die Empfehlungen und kurze Sitzungsvorschläge beeinflussen.';

  @override
  String get profile_status_section_subtitle =>
      'Aktuelle Kontobereitschaft und Verfügbarkeit der Sitzungsspeicherung.';

  @override
  String get profile_status_account_title => 'Konto';

  @override
  String get profile_status_account_signed_in => 'Angemeldet';

  @override
  String get profile_status_account_guest => 'Gast';

  @override
  String get profile_status_account_signed_in_subtitle =>
      'Deine Kontositzung ist aktiv.';

  @override
  String get profile_status_account_guest_subtitle =>
      'Melde dich an, um gespeicherte Sitzungen freizuschalten.';

  @override
  String get profile_status_session_save_title => 'Sitzungsspeicherung';

  @override
  String get profile_status_session_save_enabled => 'Aktiv';

  @override
  String get profile_status_session_save_disabled => 'Nicht verfügbar';

  @override
  String get profile_status_session_save_enabled_subtitle =>
      'Gespeicherte Sitzungen sind für dieses Konto verfügbar.';

  @override
  String get profile_status_session_save_disabled_subtitle =>
      'Vor dem Speichern von Sitzungen ist eine Anmeldung erforderlich.';

  @override
  String get profile_status_plan_subtitle => 'Premium ist nicht aktiv.';

  @override
  String get settings_language_sheet_title => 'Sprache wählen';

  @override
  String get settings_language_sheet_subtitle =>
      'Wähle eine Sprache für die ganze App.';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_german => 'Deutsch';

  @override
  String get settings_language_persian => 'فارسی';

  @override
  String get session_player_title => 'Player';

  @override
  String get player_close_tooltip => 'Player schließen';

  @override
  String get player_progress_title => 'Sitzungsfortschritt';

  @override
  String get player_step_label_prefix => 'Schritt';

  @override
  String get player_step_label_empty => 'Keine Schritte';

  @override
  String get player_current_step_label => 'Aktueller Schritt';

  @override
  String get player_step_type_label => 'Typ';

  @override
  String get player_step_duration_label => 'Dauer';

  @override
  String get player_step_skippable_label => 'Überspringbar';

  @override
  String get player_target_label => 'Ziel';

  @override
  String get player_terminal_title => 'Live-Status';

  @override
  String get player_pause_cta => 'Pausieren';

  @override
  String get player_resume_cta => 'Fortsetzen';

  @override
  String get player_previous_cta => 'Zurück';

  @override
  String get player_next_cta => 'Weiter';

  @override
  String get player_skip_cta => 'Überspringen';

  @override
  String get player_replay_cta => 'Schritt wiederholen';

  @override
  String get player_finish_cta => 'Sitzung beenden';

  @override
  String get player_exit_title => 'Sitzung beenden?';

  @override
  String get player_exit_message =>
      'Die aktuelle Sitzung wird beendet und der Fortschritt als unvollständiger Durchlauf gespeichert.';

  @override
  String get player_exit_cancel_cta => 'Weiter machen';

  @override
  String get player_exit_confirm_cta => 'Beenden';

  @override
  String get player_not_found_title => 'Sitzung nicht gefunden';

  @override
  String get player_not_found_message =>
      'Die angeforderte Sitzung konnte nicht gefunden werden oder ist nicht mehr verfügbar.';

  @override
  String get player_no_steps_title => 'Keine Schritte verfügbar';

  @override
  String get player_no_steps_message =>
      'Diese Sitzung enthält noch keine abspielbaren Schritte.';

  @override
  String get player_error_title => 'Player konnte nicht gestartet werden';

  @override
  String get player_error_subtitle =>
      'Beim Laden dieser Sitzung ist ein Fehler aufgetreten.';

  @override
  String get player_back_cta => 'Zurück';

  @override
  String get player_loading_title => 'Player wird vorbereitet...';

  @override
  String get player_auth_required_title => 'Anmeldung erforderlich';

  @override
  String get player_auth_required_message =>
      'Du brauchst ein Konto, um Sitzungen zu starten und zu verfolgen.';

  @override
  String get player_auth_required_cta => 'Anmelden';

  @override
  String get player_status_completed => 'Abgeschlossen';

  @override
  String get player_status_running_log => '[RUN] Sitzung ist aktiv';

  @override
  String get player_status_paused_log => '[PAUSE] Sitzung ist pausiert';

  @override
  String get player_status_completed_log =>
      '[DONE] Sitzung erfolgreich abgeschlossen';

  @override
  String get player_next_step_log_prefix => '[NEXT]';

  @override
  String get player_runtime_summary_title => 'Laufzeitübersicht';

  @override
  String get player_runtime_elapsed => 'Verstrichen';

  @override
  String get player_runtime_remaining => 'Verbleibend';

  @override
  String get player_runtime_step_remaining => 'Schritt verbleibend';

  @override
  String get player_breath_cue_title => 'Atemhinweis';

  @override
  String get player_safety_note_title => 'Sicherheitshinweis';

  @override
  String get player_completion_title => 'Sitzung abgeschlossen';

  @override
  String get player_completion_subtitle =>
      'Dein Durchlauf wurde erfolgreich gespeichert.';

  @override
  String get player_completion_steps => 'Schritte';

  @override
  String get player_completion_total_time => 'Gesamtzeit';

  @override
  String get player_completion_back_to_detail =>
      'Zurück zur Sitzungsdetailseite';

  @override
  String get player_media_placeholder_chip => 'Bewegungsvorschau';

  @override
  String get player_media_placeholder_body_short =>
      'Hier wird für diesen Schritt später eine Video- oder GIF-Anleitung angezeigt.';

  @override
  String get player_media_placeholder_body =>
      'Hier wird für diesen Schritt später eine Video- oder GIF-Anleitung angezeigt. Das Player-Layout ist bereits für echte Bewegungsmedien vorbereitet.';

  @override
  String get player_completion_body_impact_title =>
      'Was sich in dieser Sitzung verändert hat';

  @override
  String get player_completion_effect_release => 'Mobilität + Entlastung';

  @override
  String get player_completion_effect_reset => 'Haltungs-Reset';

  @override
  String get session_detail_back_tooltip => 'Zurück';

  @override
  String get player_completion_close => 'Schließen';

  @override
  String get quick_fix_title => 'Quick Fix';

  @override
  String get quick_fix_history_tooltip => 'Letzte Quick Fixes';

  @override
  String get quick_fix_loading_title => 'Quick Fix wird vorbereitet…';

  @override
  String get quick_fix_error_title => 'Quick Fix konnte nicht geladen werden';

  @override
  String get quick_fix_error_body => 'Bitte versuche es erneut.';

  @override
  String get quick_fix_empty_title => 'Keine Empfehlung verfügbar';

  @override
  String get quick_fix_empty_body =>
      'Passe deinen aktuellen Kontext an, um eine Live-Empfehlung zu erhalten.';

  @override
  String get quick_fix_hero_eyebrow => 'Adaptiver Recovery Launcher';

  @override
  String get quick_fix_hero_title =>
      'Finde in Sekunden die richtige Session für deinen aktuellen Körperzustand.';

  @override
  String get quick_fix_hero_body =>
      'Quick Fix verwandelt deinen aktuellen Schmerzpunkt, dein Zeitfenster, dein Energielevel und deine Umgebung in eine echte Session-Empfehlung aus dem Live-Katalog.';

  @override
  String get quick_fix_hero_stat_fast => 'Schneller Match';

  @override
  String get quick_fix_hero_stat_silent => 'Ruhiger Kontext';

  @override
  String get quick_fix_hero_stat_personalized => 'Live-Personalisierung';

  @override
  String get quick_fix_problem_section_title => 'Problem';

  @override
  String get quick_fix_problem_section_subtitle =>
      'Wähle den Schmerzpunkt oder Reset-Fokus, der jetzt am wichtigsten ist.';

  @override
  String get quick_fix_context_section_title => 'Zeit + Raum';

  @override
  String get quick_fix_context_section_subtitle =>
      'Halte die Empfehlung realistisch für dein aktuelles Setup.';

  @override
  String get quick_fix_state_section_title => 'Energie + Modus';

  @override
  String get quick_fix_state_section_subtitle =>
      'Forme die Empfehlung danach, wie intensiv und kontextbezogen sie sich anfühlen soll.';

  @override
  String get quick_fix_recommendation_section_title => 'Empfehlung';

  @override
  String get quick_fix_recommendation_section_subtitle =>
      'Die Engine aktualisiert die Session-Empfehlung anhand deines aktuellen Körperkontexts.';

  @override
  String get quick_fix_recommendation_missing =>
      'Noch keine Empfehlung verfügbar.';

  @override
  String get quick_fix_primary_match_label => 'Bester Match im Moment';

  @override
  String get quick_fix_reasoning_default =>
      'Empfohlen, weil es stark zu deinem aktuellen Problem, deinem Zeitfenster und deiner Umgebung passt.';

  @override
  String get quick_fix_more_matches_title => 'Weitere starke Treffer';

  @override
  String get quick_fix_start_now_cta => 'Jetzt starten';

  @override
  String get quick_fix_view_details_cta => 'Details ansehen';

  @override
  String get quick_fix_silent_mode_title => 'Stiller Modus';

  @override
  String get quick_fix_problem_neck => 'Nacken';

  @override
  String get quick_fix_problem_shoulder => 'Schulter';

  @override
  String get quick_fix_problem_wrist => 'Handgelenk';

  @override
  String get quick_fix_problem_back => 'Rücken';

  @override
  String get quick_fix_problem_eye => 'Augen';

  @override
  String get quick_fix_problem_stress => 'Stress';

  @override
  String get quick_fix_time_2 => '2 Min';

  @override
  String get quick_fix_time_4 => '4 Min';

  @override
  String get quick_fix_time_6 => '6 Min';

  @override
  String get quick_fix_time_10 => '10 Min';

  @override
  String get quick_fix_location_desk => 'Schreibtisch';

  @override
  String get quick_fix_location_chair => 'Stuhl';

  @override
  String get quick_fix_location_standing => 'Stehend';

  @override
  String get quick_fix_location_floor => 'Boden';

  @override
  String get quick_fix_location_bedside => 'Bett';

  @override
  String get quick_fix_energy_low => 'Niedrig';

  @override
  String get quick_fix_energy_medium => 'Mittel';

  @override
  String get quick_fix_energy_high => 'Hoch';

  @override
  String get quick_fix_mode_dad => 'Dad Mode';

  @override
  String get quick_fix_mode_night => 'Night Coder';

  @override
  String get quick_fix_mode_focus => 'Fokusmodus';

  @override
  String get quick_fix_mode_pain_relief => 'Schmerz';

  @override
  String get player_pre_state_title => 'Kurzer Check vor dem Start';

  @override
  String get player_pre_state_subtitle =>
      'Erfasse ein paar Signale vor der Session, damit Fortschritt und Wirkung besser nachvollzogen werden können.';

  @override
  String get player_pre_state_energy_title => 'Energie';

  @override
  String get player_pre_state_stress_title => 'Stress';

  @override
  String get player_pre_state_focus_title => 'Fokus';

  @override
  String get player_pre_state_intent_title => 'Ziel';

  @override
  String get player_pre_state_pain_areas_title => 'Bereiche';

  @override
  String get player_pre_state_skip => 'Jetzt überspringen';

  @override
  String get player_pre_state_start_cta => 'Session starten';

  @override
  String get player_feedback_title => 'Wie war diese Session?';

  @override
  String get player_feedback_abandoned_title =>
      'Bevor du gehst: Wie hat sich diese Session angefühlt?';

  @override
  String get player_feedback_summary_title => 'Zusammenfassung';

  @override
  String get player_feedback_abandoned_summary_title => 'Session früh beendet';

  @override
  String get player_feedback_helped_title => 'Hat es geholfen?';

  @override
  String get player_feedback_tension_title => 'Spannung';

  @override
  String get player_feedback_pain_title => 'Schmerz';

  @override
  String get player_feedback_energy_title => 'Energie';

  @override
  String get player_feedback_fit_title => 'Passung';

  @override
  String get player_feedback_repeat_title =>
      'Würdest du diese Session wiederholen?';

  @override
  String get player_feedback_yes => 'Ja';

  @override
  String get player_feedback_no => 'Nein';

  @override
  String get player_feedback_repeat_yes => 'Würde ich wiederholen';

  @override
  String get player_feedback_repeat_no => 'Eher nicht';

  @override
  String get player_feedback_submit => 'Feedback speichern';

  @override
  String get player_feedback_close => 'Schließen';

  @override
  String get common_level_low => 'Niedrig';

  @override
  String get common_level_medium => 'Mittel';

  @override
  String get common_level_high => 'Hoch';

  @override
  String get common_delta_worse => 'Schlechter';

  @override
  String get common_delta_same => 'Gleich';

  @override
  String get common_delta_better => 'Besser';

  @override
  String get common_fit_poor => 'Schwach';

  @override
  String get common_fit_okay => 'Okay';

  @override
  String get common_fit_great => 'Sehr gut';

  @override
  String get intent_relief => 'Entlastung';

  @override
  String get intent_reset => 'Reset';

  @override
  String get intent_focus => 'Fokus';

  @override
  String get intent_unwind => 'Runterkommen';

  @override
  String get pain_neck => 'Nacken';

  @override
  String get pain_shoulders => 'Schultern';

  @override
  String get pain_upper_back => 'Oberer Rücken';

  @override
  String get pain_lower_back => 'Unterer Rücken';

  @override
  String get pain_wrists => 'Handgelenke';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_error_title => 'Dashboard konnte nicht geladen werden';

  @override
  String get dashboard_error_body => 'Bitte versuche es erneut.';

  @override
  String get dashboard_error_retry => 'Erneut versuchen';

  @override
  String get dashboard_empty_title => 'Noch keine Dashboard-Daten';

  @override
  String get dashboard_empty_body =>
      'Schließe eine Session ab oder starte einen Quick Fix, um dein Dashboard zu füllen.';

  @override
  String get dashboard_empty_refresh => 'Aktualisieren';

  @override
  String get dashboard_hero_overline => 'Recovery-Kontrollzentrum';

  @override
  String get dashboard_hero_title => 'Dein Recovery-System in Bewegung.';

  @override
  String get dashboard_hero_body_with_next =>
      'Verfolge deinen Zustand, prüfe deinen Verlauf und starte die nächste passende Session direkt aus dem Dashboard.';

  @override
  String get dashboard_hero_start_next => 'Nächste Session starten';

  @override
  String get dashboard_hero_quick_fix => 'Quick Fix';

  @override
  String get dashboard_hero_body_map => 'Körperkarte';

  @override
  String get dashboard_readiness_title => 'Bereitschafts-Score';

  @override
  String get dashboard_state_energy => 'Energie';

  @override
  String get dashboard_state_stress => 'Stress';

  @override
  String get dashboard_state_focus => 'Fokus';

  @override
  String get dashboard_state_unknown => 'Unbekannt';

  @override
  String get dashboard_minutes_week => 'Minuten diese Woche';

  @override
  String get dashboard_completed_week => 'Abgeschlossene Sessions';

  @override
  String get dashboard_quickfix_week => 'Quick-Fix-Starts';

  @override
  String get dashboard_body_intelligence_title => 'Körper-Intelligenz';

  @override
  String get dashboard_body_intelligence_subtitle =>
      'Dominante Zonen, aktuelle Recovery-Qualität und Bereiche, die am häufigsten Aufmerksamkeit brauchen.';

  @override
  String get dashboard_help_rate => 'Hilfsrate';

  @override
  String get dashboard_consistency => 'Konstanz';

  @override
  String get dashboard_dominant_zone => 'Dominante Zone';

  @override
  String get dashboard_zone_unknown => 'Noch keine klare Zone';

  @override
  String get dashboard_empty_body_zones =>
      'Körperzonen-Muster erscheinen nach mehr erfassten Runs.';

  @override
  String get dashboard_trends_title => 'Recovery-Trends';

  @override
  String get dashboard_trends_subtitle =>
      'Eine visuelle Übersicht darüber, wie viel Recovery-Zeit du loggst und wie hilfreich sich diese Sessions anfühlen.';

  @override
  String get dashboard_chart_minutes_title => 'Recovery-Minuten';

  @override
  String get dashboard_chart_relief_title => 'Erholungsqualität';

  @override
  String get dashboard_heatmap_title => 'Recovery-Heatmap';

  @override
  String get dashboard_heatmap_subtitle =>
      'Eine Übersicht, wie konstant dein Recovery-System in den letzten drei Wochen aktiv war.';

  @override
  String get dashboard_recent_runs_title => 'Letzte Recovery-Runs';

  @override
  String get dashboard_recent_runs_subtitle =>
      'Eine kompakte Zeitleiste deiner letzten Runs, ihres Ausgangs und ihres Ursprungs.';

  @override
  String get dashboard_empty_recent_runs =>
      'Letzte Session-Runs erscheinen hier.';

  @override
  String get dashboard_body_map_cta_title => 'Aktive Spannungszonen prüfen';

  @override
  String get dashboard_body_map_cta_body =>
      'Öffne die Körperkarte, um aktive Schmerzbereiche zu prüfen, Verbesserungen zu sehen und direkt zur nächsten sinnvollen Session zu wechseln.';

  @override
  String get dashboard_open_body_map => 'Körperkarte öffnen';

  @override
  String get dashboard_next_session_reason_quick_fix =>
      'Empfohlen aus deinem letzten Quick-Fix-Kontext';

  @override
  String get dashboard_next_session_reason_resume =>
      'Eine starke Empfehlung basierend auf deiner letzten Aktivität';
}
