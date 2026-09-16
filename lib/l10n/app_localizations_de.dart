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
  String get common_back => 'Zurück';

  @override
  String get saved_sessions_title => 'Gespeicherte Sessions';

  @override
  String get saved_sessions_empty_title => 'Noch keine Sessions gespeichert';

  @override
  String get saved_sessions_empty_body =>
      'Speichere Sessions aus der Übersicht oder Detailseite, um deine persönliche Liste aufzubauen.';

  @override
  String get saved_sessions_browse_cta => 'Sessions ansehen';

  @override
  String get saved_sessions_error =>
      'Gespeicherte Sessions konnten nicht geladen werden.';

  @override
  String get session_history_title => 'Session-Verlauf';

  @override
  String get session_history_empty_title => 'Noch kein Session-Verlauf';

  @override
  String get session_history_empty_body =>
      'Deine abgeschlossenen und nicht beendeten Sessions erscheinen hier.';

  @override
  String get session_history_error =>
      'Der Session-Verlauf konnte nicht geladen werden.';

  @override
  String get continuity_continue_title => 'Session fortsetzen';

  @override
  String get continuity_resume_title => 'Session wieder aufnehmen';

  @override
  String get continuity_repeat_title => 'Noch einmal machen';

  @override
  String get continuity_start_title => 'Session starten';

  @override
  String get continuity_continue_cta => 'Fortsetzen';

  @override
  String get continuity_resume_cta => 'Wieder aufnehmen';

  @override
  String get continuity_repeat_cta => 'Wiederholen';

  @override
  String get continuity_start_cta => 'Starten';

  @override
  String get continuity_open_detail => 'Details öffnen';

  @override
  String get continuity_reason_active =>
      'Du hast noch eine aktive Recovery-Session.';

  @override
  String get continuity_reason_resumable =>
      'Du hast diese Session nicht beendet und kannst sie wieder aufnehmen.';

  @override
  String get continuity_reason_saved =>
      'Diese gespeicherte Session ist deine beste nächste Option.';

  @override
  String get continuity_reason_repeat =>
      'Diese zuletzt absolvierte Session eignet sich zum Wiederholen.';

  @override
  String get continuity_resume_available => 'Fortsetzen verfügbar';

  @override
  String get continuity_status_started => 'Gestartet';

  @override
  String get continuity_status_completed => 'Abgeschlossen';

  @override
  String get continuity_status_abandoned => 'Vorzeitig beendet';

  @override
  String get continuity_label_active => 'Aktive Session';

  @override
  String get continuity_label_resumable => 'Nicht beendet';

  @override
  String get continuity_label_repeatable => 'Bereits absolviert';

  @override
  String get continuity_label_saved => 'Gespeichert';

  @override
  String get continuity_strip_title => 'Mach dort weiter, wo du aufgehört hast';

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

  @override
  String get update_later_cta => 'Später';

  @override
  String get update_now_cta => 'Aktualisieren';

  @override
  String get notification_permission_prompt_title =>
      'Recovery-Erinnerungen aktivieren?';

  @override
  String get notification_permission_prompt_body =>
      'Erhalte täglich eine sanfte Erinnerung für einen kurzen Haltungs-Reset.';

  @override
  String get common_not_now => 'Nicht jetzt';

  @override
  String get notification_enable_cta => 'Aktivieren';

  @override
  String get guide_skip_cta => 'Überspringen';

  @override
  String get guide_got_it_cta => 'Verstanden';

  @override
  String get guide_next_cta => 'Weiter';

  @override
  String get startup_error_body =>
      'Die App konnte den Start nicht abschließen. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get startup_error_retry_cta => 'Erneut versuchen';

  @override
  String get nav_training => 'Training';

  @override
  String get nav_programs => 'Programme';

  @override
  String get notification_center_title => 'Benachrichtigungen';

  @override
  String get notification_center_refresh => 'Erinnerungen aktualisieren';

  @override
  String get notification_center_mark_all_read => 'Alle als gelesen markieren';

  @override
  String get notification_center_error_title =>
      'Benachrichtigungen konnten nicht geladen werden';

  @override
  String get notification_center_empty_title => 'Keine Erinnerungen geplant';

  @override
  String get notification_center_empty_body =>
      'Aktiviere die Recovery-Erinnerungen in den Einstellungen und ziehe diese Seite anschließend zum Aktualisieren nach unten.';

  @override
  String get notification_center_header_title => 'Recovery-Erinnerungen';

  @override
  String get notification_center_status_upcoming => 'Bevorstehend';

  @override
  String get notification_center_status_opened => 'Geöffnet';

  @override
  String get notification_center_status_new => 'Neu';

  @override
  String get notification_center_status_scheduled => 'Geplant';

  @override
  String get quick_fix_page_step_hint =>
      'Wähle einen Bereich und starte dann deine Session';

  @override
  String get guide_quick_fix_body_title => 'Körper auswählen';

  @override
  String get guide_quick_fix_body_body =>
      'Wähle den Bereich aus, der sich verspannt anfühlt. Die Empfehlung wird darauf ausgerichtet.';

  @override
  String get guide_quick_fix_filters_title => 'Einfache Filter';

  @override
  String get guide_quick_fix_filters_body =>
      'Wähle verfügbare Ausrüstung. Halte es einfach.';

  @override
  String get guide_quick_fix_match_title => 'Passende Session erhalten';

  @override
  String get guide_quick_fix_match_body =>
      'Tippe auf Passende Session finden, um eine Session für deine aktuelle Situation zu erhalten.';

  @override
  String get quick_fix_match_session_cta => 'Passende Session finden';

  @override
  String get quick_fix_selected_target_empty => 'Kein Bereich';

  @override
  String get quick_fix_matched_title => 'Passende Session';

  @override
  String get quick_fix_matching_title => 'Dein Reset wird gesucht …';

  @override
  String get quick_fix_selected_count_suffix => 'ausgewählt';

  @override
  String get quick_fix_equipment_title => 'Ausrüstung';

  @override
  String get common_apply => 'Übernehmen';

  @override
  String get quick_fix_body_map_hint_step => 'Körperpunkt antippen';

  @override
  String get body_map_front => 'Vorderseite';

  @override
  String get body_map_back => 'Zurück';

  @override
  String get quick_fix_recommended_badge => 'Beste Übereinstimmung';

  @override
  String get quick_fix_start_session => 'Session starten';

  @override
  String get quick_fix_alternatives_title => 'Weitere gute Optionen';

  @override
  String get quick_fix_none_selected => 'Nichts ausgewählt';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_settings_tooltip => 'Einstellungen öffnen';

  @override
  String get profile_primary_continue => 'Recovery fortsetzen';

  @override
  String get profile_primary_open_sessions => 'Training starten';

  @override
  String get profile_sign_in_cta => 'Anmelden';

  @override
  String get profile_sync_connected => 'Synchronisiert';

  @override
  String get profile_sync_local => 'Lokal';

  @override
  String get profile_guest_subtitle => 'Gastprofil';

  @override
  String get profile_metric_saved => 'Gespeichert';

  @override
  String get profile_metric_runs => 'Durchläufe';

  @override
  String get profile_metric_status => 'Status';

  @override
  String get profile_action_premium => 'Core Access';

  @override
  String get profile_action_premium_subtitle_large =>
      'Schalte alle Sessions, Programme, Quick Fix und Insights frei.';

  @override
  String get profile_action_saved_short => 'Gespeichert';

  @override
  String get profile_action_saved_subtitle_short => 'Sitzungen';

  @override
  String get session_history_title_compact => 'Verlauf';

  @override
  String get profile_action_history_subtitle_short => 'Verläufe';

  @override
  String get profile_action_programs => 'Programme';

  @override
  String get profile_action_programs_subtitle_short => 'Pläne';

  @override
  String get profile_account_section_title => 'Konto';

  @override
  String get profile_account_section_subtitle => 'Profil- und App-Steuerung.';

  @override
  String get profile_edit_title => 'Profil bearbeiten';

  @override
  String get profile_edit_subtitle => 'Name und Foto';

  @override
  String get profile_action_settings => 'Einstellungen';

  @override
  String get profile_action_settings_subtitle_compact => 'App';

  @override
  String get profile_sign_out_cta => 'Abmelden';

  @override
  String get profile_create_account_cta => 'Konto erstellen';

  @override
  String get profile_sign_out_subtitle => 'Dieses Gerät verlassen';

  @override
  String get profile_create_account_subtitle => 'Fortschritt synchronisieren';

  @override
  String get profile_danger_zone_title => 'Gefahrenbereich';

  @override
  String get profile_danger_zone_subtitle => 'Konto und Daten entfernen.';

  @override
  String get settings_reset_app_data_title => 'App-Daten zurücksetzen';

  @override
  String get settings_reset_app_data_loading => 'App-Daten werden gelöscht …';

  @override
  String get settings_reset_app_data_subtitle_short =>
      'Fortschritt, gespeicherte Inhalte und Verlauf löschen.';

  @override
  String get settings_delete_account_section_title => 'Konto löschen';

  @override
  String get settings_delete_account_loading => 'Konto wird gelöscht …';

  @override
  String get settings_delete_account_section_subtitle =>
      'Konto und App-Daten dauerhaft entfernen.';

  @override
  String get settings_reset_app_data_dialog_title => 'App-Daten zurücksetzen?';

  @override
  String get settings_reset_app_data_dialog_body =>
      'Dadurch werden Trainingsverlauf, gespeicherte Sessions, Programmfortschritt, Quick-Fix-Verlauf, Feedback, Profil und Einstellungen entfernt. Dein Anmeldekonto bleibt aktiv. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get settings_reset_app_data_confirm => 'Daten zurücksetzen';

  @override
  String get settings_reset_app_data_sign_in_required =>
      'Melde dich zuerst an, um deine App-Daten zurückzusetzen.';

  @override
  String get settings_reset_app_data_success =>
      'Deine App-Daten wurden zurückgesetzt.';

  @override
  String get settings_reset_app_data_failed =>
      'App-Daten konnten nicht zurückgesetzt werden.';

  @override
  String get settings_delete_account_dialog_title => 'Konto löschen?';

  @override
  String get settings_delete_account_dialog_body =>
      'Dein Profil, deine Einstellungen, gespeicherte Sessions, Verläufe, Kaufzugänge und Kontodaten werden entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get settings_delete_account_confirm => 'Löschen';

  @override
  String get settings_delete_account_sign_in_required =>
      'Melde dich zuerst an, um dein Konto zu löschen.';

  @override
  String get settings_delete_account_success => 'Dein Konto wurde gelöscht.';

  @override
  String get settings_delete_account_failed =>
      'Dein Konto konnte nicht gelöscht werden. Bitte kontaktiere den Support.';

  @override
  String get profile_core_access_badge => 'CORE ACCESS';

  @override
  String get profile_core_access_cta_short => 'Öffnen';

  @override
  String get profile_edit_saved => 'Profil aktualisiert.';

  @override
  String get profile_avatar_updated => 'Profilfoto aktualisiert.';

  @override
  String get profile_edit_error =>
      'Das Profil konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get profile_change_photo_cta => 'Foto ändern';

  @override
  String get profile_remove_photo_cta => 'Entfernen';

  @override
  String get profile_display_name_label => 'Anzeigename';

  @override
  String get profile_save_cta => 'Speichern';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_hero_title => 'App-Steuerung';

  @override
  String get settings_hero_subtitle =>
      'Sprache, Design, Support und rechtliche Informationen.';

  @override
  String get settings_preferences_compact_title => 'Einstellungen';

  @override
  String get settings_preferences_compact_subtitle =>
      'Sprache, Design und Synchronisierung.';

  @override
  String get settings_language_section_title => 'Sprache';

  @override
  String get settings_appearance_section_title => 'Darstellung';

  @override
  String get notification_settings_title_compact => 'Benachrichtigungen';

  @override
  String get notification_settings_inline_subtitle =>
      'Recovery-Erinnerungen und haptisches Feedback.';

  @override
  String get notification_settings_error =>
      'Benachrichtigungseinstellungen konnten nicht geladen werden.';

  @override
  String get notification_settings_guest_hint =>
      'Melde dich an, um deine Benachrichtigungseinstellungen zu speichern.';

  @override
  String get notification_settings_enable_title => 'Recovery-Erinnerungen';

  @override
  String get notification_settings_enabled_short =>
      'Die tägliche Erinnerung ist aktiv.';

  @override
  String get notification_settings_disabled_short =>
      'Standardmäßig deaktiviert. Aktiviere Erinnerungen bei Bedarf.';

  @override
  String get notification_permission_denied =>
      'Die Berechtigung für Benachrichtigungen wurde nicht erteilt.';

  @override
  String get notification_settings_time_title => 'Erinnerungszeit';

  @override
  String get notification_settings_time_error =>
      'Die Erinnerungszeit konnte nicht geladen werden.';

  @override
  String get notification_settings_haptics_title => 'Haptisches Feedback';

  @override
  String get notification_settings_haptics_short =>
      'Spürbare Bestätigung auf unterstützten Geräten.';

  @override
  String get notification_time_morning => 'Morgen';

  @override
  String get notification_time_afternoon => 'Nachmittag';

  @override
  String get notification_time_evening => 'Abend';

  @override
  String get settings_support_legal_title => 'Support & Rechtliches';

  @override
  String get settings_support_legal_subtitle =>
      'Hilfe, Richtlinien und Kontoinformationen.';

  @override
  String get settings_contact_email_label => 'E-Mail-Support';

  @override
  String get settings_privacy_policy_title => 'Datenschutzerklärung';

  @override
  String get settings_external_link_subtitle => 'Im Browser öffnen';

  @override
  String get settings_terms_title => 'Nutzungsbedingungen';

  @override
  String get settings_account_data_deletion_info_title =>
      'Richtlinie zur Datenlöschung';

  @override
  String get settings_app_version_loading => 'Version wird geladen …';

  @override
  String get settings_app_version_title => 'App-Version';

  @override
  String get settings_theme_system_title => 'System';

  @override
  String get settings_theme_system_short => 'Auto';

  @override
  String get settings_theme_light_title => 'Leicht';

  @override
  String get settings_theme_light_short => 'Leicht';

  @override
  String get settings_theme_dark_title => 'Dunkel';

  @override
  String get settings_theme_dark_short => 'Dunkel';

  @override
  String get settings_preferences_error_short =>
      'Cloud-Einstellungen konnten nicht geladen werden.';

  @override
  String get settings_preferences_guest_hint =>
      'Melde dich an, um Einstellungen geräteübergreifend zu synchronisieren.';

  @override
  String get settings_preferences_synced_short =>
      'Einstellungen sind synchronisiert.';

  @override
  String get settings_link_open_failed =>
      'Der Link konnte nicht geöffnet werden.';

  @override
  String get settings_email_open_failed =>
      'Deine E-Mail-App konnte nicht geöffnet werden.';

  @override
  String get premium_purchase_cancelled => 'Der Kauf wurde abgebrochen.';

  @override
  String get premium_restore_no_purchase_found =>
      'Für dieses Google-Play-Konto wurde kein früherer Core-Access-Kauf gefunden.';

  @override
  String get premium_purchase_failed =>
      'Der Kauf konnte nicht abgeschlossen werden. Bitte versuche es erneut.';

  @override
  String get premium_page_title => 'Core Access';

  @override
  String get premium_status_core_active => 'Freigeschaltet';

  @override
  String get premium_visual_pill => 'Core einmalig freischalten';

  @override
  String get premium_hero_unlocked_title => 'Core Access ist aktiv.';

  @override
  String get premium_visual_title_v2 =>
      'Schalte das vollständige Erholungssystem frei.';

  @override
  String get premium_hero_unlocked_body_v2 =>
      'Programme, vollständige Sessions, Quick Fix, Insights, gespeicherte Inhalte und Verlauf sind verfügbar.';

  @override
  String get premium_visual_body_v2 =>
      'Programme, vollständige Sessions, Quick Fix, Insights, gespeicherte Inhalte und Verlauf – mit einer Freischaltung.';

  @override
  String get premium_programs_badge => 'Programme';

  @override
  String get premium_value_programs_title => 'Recovery-Programme';

  @override
  String get premium_value_sessions_title => 'Alle Sessions';

  @override
  String get premium_value_quick_fix_title => 'Quick Fix';

  @override
  String get premium_value_insights_title => 'Insights';

  @override
  String get premium_value_active_title => 'Deine freigeschalteten Funktionen';

  @override
  String get premium_value_title => 'Das bietet Core';

  @override
  String get premium_value_subtitle_v2 =>
      'Vollständiger Zugriff mit einer Freischaltung.';

  @override
  String get premium_product_price_unavailable => 'Preis nicht verfügbar';

  @override
  String get premium_plan_unlocked_subtitle =>
      'Dein vollständiges Recovery-Paket ist freigeschaltet.';

  @override
  String get premium_plan_subtitle_v2 =>
      'Einmalig freischalten. Kein Abonnement. Jederzeit mit demselben Google-Play-Konto wiederherstellen.';

  @override
  String get premium_sign_in_hint =>
      'Melde dich zuerst an, damit der Zugriff später wiederhergestellt werden kann.';

  @override
  String get premium_plan_title => 'Core Access';

  @override
  String get premium_plan_lifetime_badge => 'Einmalig';

  @override
  String get premium_signal_lifetime => 'Lebenslang';

  @override
  String get premium_signal_restore => 'Wiederherstellung unterstützt';

  @override
  String get premium_signal_no_subscription => 'Kein Abonnement';

  @override
  String get premium_already_unlocked_cta => 'Bereits freigeschaltet';

  @override
  String get premium_restore_cta => 'Wiederherstellen';

  @override
  String get premium_loading_products_cta => 'Store wird geprüft …';

  @override
  String get premium_purchasing_cta => 'Store wird geöffnet …';

  @override
  String get premium_verifying_cta => 'Wird überprüft …';

  @override
  String get premium_product_unavailable_cta => 'Produkt nicht verfügbar';

  @override
  String get access_unlock_core_cta => 'Core freischalten';

  @override
  String get premium_error_purchase_linked_to_another_account =>
      'Dieser Kauf ist bereits mit einem anderen Konto verknüpft. Melde dich mit dem Konto an, das für die ursprüngliche Freischaltung verwendet wurde.';

  @override
  String get premium_error_not_authenticated =>
      'Melde dich zuerst an, damit dein Kauf überprüft werden kann.';

  @override
  String get premium_error_missing_purchase_payload =>
      'Der Store hat keinen gültigen Kaufbeleg zurückgegeben. Versuche die Wiederherstellung oder kontaktiere den Support.';

  @override
  String get premium_error_product_mismatch =>
      'Das Store-Produkt passt nicht zu dieser App-Version. Aktualisiere die App oder kontaktiere den Support.';

  @override
  String get premium_error_purchase_not_completed =>
      'Der Kauf wurde nicht abgeschlossen. Bitte versuche es erneut.';

  @override
  String get premium_error_unsupported_platform =>
      'Käufe sind derzeit nur unter Android verfügbar.';

  @override
  String get premium_error_store_unavailable =>
      'Google-Play-Abrechnung ist auf diesem Gerät nicht verfügbar. Installiere die App bitte über Google Play.';

  @override
  String get premium_error_product_unavailable =>
      'Core Access ist derzeit nicht im Store verfügbar. Bitte versuche es später erneut.';

  @override
  String get premium_error_purchase_failed =>
      'Der Kauf konnte nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get premium_error_verification_failed =>
      'Der Kauf konnte nicht überprüft werden. Versuche die Wiederherstellung oder kontaktiere den Support.';

  @override
  String get premium_billing_error_body =>
      'Die Abrechnung ist noch nicht bereit oder der Kauf konnte nicht überprüft werden. Bitte versuche es erneut.';

  @override
  String get logs_page_title => 'Protokolle';

  @override
  String get logs_locked_title => 'Verhaltensprotokolle gehören zu Core Access';

  @override
  String get logs_locked_message =>
      'Schalte Core einmalig frei, um Recovery-Protokolle aus Sessions, Feedback, Quick Fix, Statusdaten und Player-Ereignissen zu prüfen.';

  @override
  String get logs_hero_title => 'Recovery-Protokolle';

  @override
  String get logs_hero_body_short =>
      'Aktuelle Signale aus Sessions und Quick Fix.';

  @override
  String get logs_positive_label => 'Positiv';

  @override
  String get logs_warning_label => 'Warnungen';

  @override
  String get logs_neutral_label => 'Neutral';

  @override
  String get logs_recent_title => 'Letzte Protokolleinträge';

  @override
  String get insights_logs_empty =>
      'Schließe einige Sessions ab, um Recovery-Notizen zu erzeugen.';

  @override
  String get logs_error_title => 'Protokolle konnten nicht geladen werden';

  @override
  String get insights_title => 'Einblicke';

  @override
  String get guide_insights_signal_title => 'Erholungssignal';

  @override
  String get guide_insights_signal_body =>
      'Dieser Bereich fasst deinen aktuellen Erholungsrhythmus zusammen, nachdem du Insights freigeschaltet hast.';

  @override
  String get guide_insights_metrics_title => 'Wichtige Werte';

  @override
  String get guide_insights_metrics_body =>
      'Hier siehst du Minuten, Regelmäßigkeit, Fokusbereiche und Quick-Fix-Aktivität.';

  @override
  String get guide_insights_patterns_title => 'Trends und Muster';

  @override
  String get guide_insights_patterns_body =>
      'Diagramme zeigen dir, was sich verbessert und wo Verspannungen wiederkehren.';

  @override
  String get insights_journey_intelligence_title => 'Fortschrittsanalyse';

  @override
  String get insights_journey_intelligence_empty_title =>
      'Therapiesignal aufbauen';

  @override
  String get insights_journey_intelligence_body =>
      'Dein aktueller Weg baut Muster für Regelmäßigkeit, Reaktion und Abschluss auf.';

  @override
  String get insights_journey_intelligence_empty_body =>
      'Starte einen Therapiepfad, um Sessions mit deinem langfristigen Fortschritt zu verbinden.';

  @override
  String get insights_focus_completion_title => 'Abschluss';

  @override
  String get insights_focus_helpful_title => 'Hilfreich';

  @override
  String get insights_summary_consistency_title => 'Rhythmus';

  @override
  String get insights_locked_preview_title => 'Insights freischalten';

  @override
  String get insights_locked_preview_body =>
      'Core Access zeigt dir deine echten Trends.';

  @override
  String get insights_range_7_short => '7 Tage';

  @override
  String get insights_range_14_short => '14 Tage';

  @override
  String get insights_range_28_short => '28 Tage';

  @override
  String get insights_intro_title => 'Erholungssignal';

  @override
  String get insights_intro_body_short =>
      'Muster aus deiner letzten Recovery-Arbeit.';

  @override
  String get insights_focus_zone_title => 'Fokus';

  @override
  String get insights_range_compact => 'Zeitraum';

  @override
  String get insights_streak_compact => 'Serie';

  @override
  String get insights_summary_minutes_title => 'Minuten';

  @override
  String get insights_summary_minutes_subtitle => 'Abgeschlossen';

  @override
  String get insights_active_days_title => 'Aktive Tage';

  @override
  String get insights_helpful_title => 'Hilfreich';

  @override
  String get insights_helpful_subtitle => 'Aus Feedback';

  @override
  String get insights_relief_title => 'Entlastung';

  @override
  String get insights_relief_subtitle => 'Durchschnittswert';

  @override
  String get insights_recovery_minutes_title => 'Recovery-Trend';

  @override
  String get insights_recovery_minutes_subtitle_short =>
      'Minuten im Zeitverlauf';

  @override
  String get insights_chart_peak => 'Höchstwert';

  @override
  String get insights_chart_average => 'Ø';

  @override
  String get insights_rhythm_title => 'Erholungsrhythmus';

  @override
  String get insights_rhythm_subtitle_short => 'Aktive Tage zuletzt';

  @override
  String get insights_rhythm_active_days => 'Aktiv';

  @override
  String get insights_rhythm_minutes => 'Minuten';

  @override
  String get insights_patterns_title => 'Musterhinweise';

  @override
  String get insights_patterns_subtitle_short => 'Aktuelle Signale';

  @override
  String get insights_logs_action => 'Alle anzeigen';

  @override
  String get insights_error_title => 'Insights konnten nicht geladen werden';

  @override
  String get pain_forearms => 'Unterarme';

  @override
  String get pain_hands => 'Hände';

  @override
  String get pain_hips_glutes => 'Hüfte & Gesäß';

  @override
  String get pain_eyes => 'Augen';

  @override
  String get session_history_locked_title => 'Vergangene Sessions ansehen';

  @override
  String get session_history_locked_message =>
      'Schalte die Funktion frei, um deine Recovery zu verfolgen.';

  @override
  String get player_access_locked_title => 'Core Access erforderlich';

  @override
  String get player_access_locked_message =>
      'Diese Session gehört zu Core Access. Schalte Core einmalig frei, um das vollständige Recovery-Paket zu nutzen.';

  @override
  String get guide_player_header_title => 'Session-Fortschritt';

  @override
  String get guide_player_header_body =>
      'Die obere Karte zeigt den Session-Titel und deinen Gesamtfortschritt. Tippe nur auf Schließen, wenn du die Session verlassen möchtest.';

  @override
  String get guide_player_video_title => 'Bewegungsdemo';

  @override
  String get guide_player_video_body =>
      'Folge dem Video für eine sichere Bewegungsausführung. Du kannst es vergrößern oder stummschalten, ohne den Player zu verlassen.';

  @override
  String get guide_player_timer_title => 'Haupttimer';

  @override
  String get guide_player_timer_body =>
      'Nutze diesen großen Timer als maßgebliche Zeitangabe für den aktuellen Schritt.';

  @override
  String get guide_player_instruction_title => 'Anleitungskarte';

  @override
  String get guide_player_instruction_body =>
      'Lies hier die kurze Anleitung. Zusätzliche Coaching-, Atem- und Sicherheitshinweise bleiben kompakt in dieser Karte.';

  @override
  String get guide_player_controls_title => 'Steuerung';

  @override
  String get guide_player_controls_body =>
      'Steuere die Session hier: zurück, wiederholen, pausieren, überspringen, weiter oder beim letzten Schritt beenden.';

  @override
  String get guide_done_cta => 'Fertig';

  @override
  String get movement_pattern_setup => 'Vorbereitung';

  @override
  String get movement_pattern_assessment => 'Überprüfung';

  @override
  String get movement_pattern_mobility => 'Mobilität';

  @override
  String get movement_pattern_stretch => 'Dehnung';

  @override
  String get movement_pattern_release => 'Lösen';

  @override
  String get movement_pattern_activation => 'Aktivierung';

  @override
  String get movement_pattern_strength => 'Kraft';

  @override
  String get movement_pattern_endurance => 'Ausdauer';

  @override
  String get movement_pattern_posture => 'Haltung';

  @override
  String get movement_pattern_breathing => 'Atmung';

  @override
  String get movement_pattern_cooldown => 'Abschluss';

  @override
  String get movement_pattern_habit => 'Gewohnheit';

  @override
  String get continuity_preview_cta => 'Vorschau';

  @override
  String get player_pre_state_subtitle_compact =>
      'Lege deinen Ausgangspunkt fest. Das dauert nur wenige Sekunden.';

  @override
  String get player_feedback_subtitle_compact =>
      'Ein kurzes Feedback hilft, deine nächste Empfehlung zu verbessern.';

  @override
  String get player_media_expand_tooltip => 'Größer anzeigen';

  @override
  String get player_media_unmute_tooltip => 'Ton einschalten';

  @override
  String get player_media_mute_tooltip => 'Ton ausschalten';

  @override
  String get guide_dashboard_topbar_title => 'Obere Leiste';

  @override
  String get guide_dashboard_topbar_body =>
      'Nutze die obere Leiste für Benachrichtigungen und dein Konto. Kostenlose Mitglieder können direkt über das Kontosymbol upgraden.';

  @override
  String get guide_dashboard_home_title => 'Deine Erholungsübersicht';

  @override
  String get guide_dashboard_home_body =>
      'Starte mit dem empfohlenen nächsten Schritt und prüfe danach Status, Programmfortschritt und letzte Aktivität.';

  @override
  String get guide_dashboard_bottom_nav_title => 'Untere Navigation';

  @override
  String get guide_dashboard_bottom_nav_body =>
      'Nutze die unteren Tabs, um Training, Quick Fix, Insights und Programme zu öffnen.';

  @override
  String get dashboard_greeting => 'Hallo';

  @override
  String get dashboard_new_quick_fix_title => 'Wo spürst du Verspannung?';

  @override
  String get dashboard_new_quick_fix_body =>
      'Tippe auf einen Körperbereich und erhalte in Sekunden den passenden Reset.';

  @override
  String get dashboard_quick_fix_title => 'Finde deinen Reset';

  @override
  String get dashboard_for_you_now => 'Jetzt für dich';

  @override
  String get session_duration_unit_min => 'Min.';

  @override
  String get dashboard_continue_session => 'Fortsetzen';

  @override
  String get dashboard_start_session => 'Starten';

  @override
  String get dashboard_active_program_title => 'Dein Programm';

  @override
  String get dashboard_continue_program => 'Programm fortsetzen';

  @override
  String get dashboard_day_label => 'Tag';

  @override
  String get profile_action_notifications => 'Benachrichtigungen';

  @override
  String get dashboard_command_title => 'Erholungszentrale';

  @override
  String get dashboard_command_active_body =>
      'Dein Weg, dein Erholungssignal und der nächste Schritt an einem Ort.';

  @override
  String get dashboard_command_empty_body =>
      'Starte einen Therapiepfad, um ein klares Erholungssignal aufzubauen.';

  @override
  String get dashboard_readiness_label => 'Bereitschaft';

  @override
  String get dashboard_helpful_label => 'Hilfreich';

  @override
  String get dashboard_rhythm_label => 'Rhythmus';

  @override
  String get dashboard_snapshot_error_title =>
      'Dashboard-Daten sind nicht verfügbar';

  @override
  String get dashboard_weekly_minutes_label => 'Min. diese Woche';

  @override
  String get dashboard_completed_week_label => 'Sessions';

  @override
  String get dashboard_run_completed => 'Abgeschlossen';

  @override
  String get dashboard_run_abandoned => 'Pausiert';

  @override
  String get dashboard_run_started => 'Gestartet';

  @override
  String get dashboard_programs_active_title => 'Setze deinen Weg fort';

  @override
  String get dashboard_programs_title => 'Therapiepfade';

  @override
  String get common_view_all => 'Alle anzeigen';

  @override
  String get dashboard_program_discovery_pill_guided => 'Geführt';

  @override
  String get dashboard_program_discovery_title => 'Wähle einen Therapiepfad';

  @override
  String get dashboard_program_discovery_cta => 'Pfade ansehen';

  @override
  String get program_active_badge => 'Aktiv';

  @override
  String get dashboard_programs_continue_cta => 'Fortsetzen';

  @override
  String get program_day_unit => 'Etappen';

  @override
  String get program_start_cta => 'Starten';

  @override
  String get dashboard_saved_title => 'Für später gespeichert';

  @override
  String get dashboard_recommended_title => 'Heute empfohlen';

  @override
  String get dashboard_see_all => 'Alle anzeigen';

  @override
  String get sessions_title => 'Training';

  @override
  String get dashboard_momentum_title => 'Dein Fortschritt';

  @override
  String get dashboard_program_days_label => 'Programmetappen';

  @override
  String get dashboard_streak_label => 'Serie';

  @override
  String get dashboard_saved_count_label => 'gespeichert';

  @override
  String get dashboard_body_focus_title => 'Brauchst du jetzt Entlastung?';

  @override
  String get dashboard_body_focus_body =>
      'Wähle in Quick Fix den Körperbereich aus, der Aufmerksamkeit braucht.';

  @override
  String get dashboard_premium_title => 'Dein vollständiges Erholungssystem';

  @override
  String get dashboard_premium_body =>
      'Geführte Programme, tiefere Einblicke und alle Recovery-Sessions freigeschaltet.';

  @override
  String get dashboard_premium_cta_short => 'Entdecken';

  @override
  String get programs_title => 'Programme';

  @override
  String get programs_browse_all_title => 'Wähle deinen Recovery-Pfad';

  @override
  String get programs_more_journeys_title => 'Weitere Programme';

  @override
  String get programs_section_subtitle =>
      'Strukturierte Pläne für kontinuierlichen Fortschritt.';

  @override
  String get programs_header_active => 'Halte deinen Schwung';

  @override
  String get programs_header_new => 'Baue einen gesünderen Arbeitstag auf';

  @override
  String get programs_header_body =>
      'Geführte Programme mit klarer täglicher Struktur.';

  @override
  String get program_premium_badge => 'Premium';

  @override
  String get programs_error_title =>
      'Programme sind vorübergehend nicht verfügbar';

  @override
  String get programs_error_body =>
      'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get programs_empty_title => 'Noch keine Programme verfügbar';

  @override
  String get programs_empty_body =>
      'Ziehe nach unten oder aktualisiere die Seite.';

  @override
  String get common_refresh => 'Aktualisieren';

  @override
  String get program_detail_title => 'Programm';

  @override
  String get program_switch_title => 'Weg wechseln?';

  @override
  String get program_start_title => 'Diesen Weg starten?';

  @override
  String get program_switch_body =>
      'Dein Fortschritt im aktuellen Weg bleibt gespeichert. Dieser Weg wird dein aktiver Pfad.';

  @override
  String get program_start_body =>
      'Deine erste Etappe wird jetzt freigeschaltet. Der Fortschritt wird nach jeder abgeschlossenen Etappe gespeichert.';

  @override
  String get program_switch_cta => 'Weg wechseln';

  @override
  String get program_begin_cta => 'Weg beginnen';

  @override
  String get program_phase_recovery => 'Erholung';

  @override
  String get program_completed_label => 'Abgeschlossen';

  @override
  String get program_continue_recovery_cta => 'Recovery fortsetzen';

  @override
  String get program_about_journey_label => 'Über diesen Weg';

  @override
  String get program_path_label => 'Recovery-Programm';

  @override
  String get program_unlocked_label => 'Freigeschaltet';

  @override
  String get program_no_days_title => 'Noch keine Etappen verfügbar.';

  @override
  String get program_view_full_plan_title => 'Wegübersicht';

  @override
  String get program_sequential_hint =>
      'Wähle eine Phase, um ihre Etappen und den Fortschritt anzusehen.';

  @override
  String get program_day_missing_session => 'Session fehlt';

  @override
  String get program_phase_start_label => 'Phasenstart';

  @override
  String get program_phase_end_label => 'Phasenende';

  @override
  String get program_assessment_label => 'Überprüfung';

  @override
  String get program_repeat_label => 'Wiederholen';

  @override
  String get program_today_badge => 'HEUTE';

  @override
  String get program_expected_label => 'Erwartet';

  @override
  String get program_detail_error_title =>
      'Dieser Weg konnte nicht geladen werden.';

  @override
  String get program_detail_error_body =>
      'Prüfe deine Verbindung und versuche es erneut. Dein Fortschritt ist sicher.';

  @override
  String get program_progress_sync_warning =>
      'Der Weg wurde geladen, aber der Fortschritt konnte nicht synchronisiert werden. Einige Zustände könnten veraltet sein.';

  @override
  String get program_not_found_title => 'Dieser Weg ist nicht mehr verfügbar.';

  @override
  String get program_not_found_body =>
      'Kehre zu Programme zurück und wähle einen anderen Therapiepfad.';

  @override
  String get access_core_badge => 'Core';

  @override
  String get sessions_load_error_title =>
      'Training konnte nicht geladen werden.';

  @override
  String get guide_training_sessions_title => 'Sessions sind einzelne Resets';

  @override
  String get guide_training_sessions_body =>
      'Nutze Sessions, wenn du jetzt eine einzelne kurze Recovery-Übung machen möchtest.';

  @override
  String get guide_training_filter_title => 'Suchen und filtern';

  @override
  String get guide_training_filter_body =>
      'Filtere nach Körperbereich oder sortiere die Sessions passend zu deinem Bedarf.';

  @override
  String get common_clear => 'Löschen';

  @override
  String get training_programs_title => 'Programme';

  @override
  String get training_programs_subtitle =>
      'Geführte Therapiepfade für strukturierte Recovery.';

  @override
  String get training_sessions_section_title => 'Sitzungen';

  @override
  String get training_sessions_section_subtitle =>
      'Einzelne Recovery-Sessions, die du jederzeit starten kannst.';

  @override
  String get sessions_search_hint_compact => 'Sessions suchen';

  @override
  String get sessions_category_lower_back_hips => 'Unterer Rücken & Hüfte';

  @override
  String get sessions_category_wrists_hands => 'Handgelenke & Hände';

  @override
  String get sessions_sort_shortest => 'Dauer: kürzeste zuerst';

  @override
  String get sessions_sort_alpha => 'Alphabetisch';

  @override
  String get sessions_sort_short_recommended => 'Standard';

  @override
  String get sessions_sort_short_shortest => 'Kürzeste';

  @override
  String get sessions_sort_short_az => 'A–Z';

  @override
  String get session_detail_nav_title => 'Session-Details';

  @override
  String get premium_title => 'Premium';

  @override
  String get session_detail_label => 'Session';

  @override
  String get session_detail_body_target_general => 'Allgemein';

  @override
  String get session_detail_body_targets_title => 'Körper';

  @override
  String get session_detail_equipment_none => 'Keine Ausrüstung';

  @override
  String get session_detail_steps_title_compact => 'Schritte';

  @override
  String get session_detail_safety_title => 'Sicherheit';

  @override
  String get session_detail_safety_compact_subtitle => 'Vor dem Start prüfen.';

  @override
  String get session_detail_warning_title => 'Vorsicht bei';

  @override
  String get session_detail_avoid_title => 'Vermeiden oder stoppen bei';

  @override
  String get session_detail_error_title =>
      'Session konnte nicht geladen werden';

  @override
  String get session_detail_error_subtitle =>
      'Beim Laden dieser Session ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get equipment_chair => 'Stuhl';

  @override
  String get equipment_desk => 'Schreibtisch';

  @override
  String get equipment_wall => 'Wand';

  @override
  String get equipment_towel => 'Handtuch';

  @override
  String get equipment_small_cushion => 'Kleines Kissen';

  @override
  String get equipment_lumbar_roll => 'Lendenrolle';

  @override
  String get equipment_mini_band => 'Mini-Band';

  @override
  String get equipment_long_band => 'Widerstandsband';

  @override
  String get equipment_massage_ball => 'Massageball';

  @override
  String get equipment_soft_ball => 'Weicher Ball';

  @override
  String get equipment_water_bottle => 'Wasserflasche';

  @override
  String get equipment_dowel => 'Stab / Besenstiel';

  @override
  String get equipment_yoga_mat => 'Yogamatte';

  @override
  String get equipment_foam_roller => 'Faszienrolle';

  @override
  String get session_level_free_starter => 'Starter';

  @override
  String get session_level_therapy => 'Therapie';

  @override
  String get session_level_advanced_therapy => 'Fortgeschrittene Therapie';

  @override
  String get session_level_flagship => 'Flagship';

  @override
  String get saved_sessions_locked_title =>
      'Speichere deine Lieblings-Sessions';

  @override
  String get saved_sessions_locked_message =>
      'Schalte die Funktion frei, um sie hier zu speichern.';

  @override
  String get auth_callback_title => 'Anmeldung wird abgeschlossen …';

  @override
  String get auth_callback_subtitle =>
      'Bitte warte, während deine Kontositzung vorbereitet wird.';

  @override
  String get auth_terms_required =>
      'Bitte akzeptiere zuerst die Nutzungsbedingungen und die Datenschutzerklärung.';

  @override
  String get auth_google_not_started =>
      'Die Google-Anmeldung konnte nicht gestartet werden.';

  @override
  String get auth_google_unknown_error =>
      'Die Google-Anmeldung ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get auth_apple_coming_soon =>
      'Die Anmeldung mit Apple wird bald hinzugefügt.';

  @override
  String get auth_reset_email_required =>
      'Gib zuerst deine E-Mail-Adresse ein.';

  @override
  String get auth_reset_email_sent =>
      'Die E-Mail zum Zurücksetzen des Passworts wurde gesendet. Prüfe deinen Posteingang.';

  @override
  String get auth_link_open_failed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get auth_invalid_credentials =>
      'E-Mail-Adresse oder Passwort ist falsch.';

  @override
  String get auth_email_not_confirmed =>
      'Bitte bestätige deine E-Mail-Adresse, bevor du dich anmeldest.';

  @override
  String get auth_user_already_registered =>
      'Für diese E-Mail-Adresse besteht bereits ein Konto.';

  @override
  String get auth_or_email_short => 'oder mit E-Mail fortfahren';

  @override
  String get auth_app_badge => 'Desk Workout';

  @override
  String get auth_sign_up_tab_short => 'Erstellen';

  @override
  String get auth_google_short => 'Google';

  @override
  String get auth_apple_short => 'Apple';

  @override
  String get auth_toggle_password_visibility =>
      'Passwortsichtbarkeit umschalten';

  @override
  String get auth_forgot_password => 'Passwort vergessen?';

  @override
  String get auth_accept_terms_text =>
      'Ich akzeptiere die Nutzungsbedingungen und die Datenschutzerklärung.';

  @override
  String get auth_legal_note_sign_in_compact =>
      'Indem du fortfährst, stimmst du unseren rechtlichen Bedingungen zu.';

  @override
  String get auth_legal_note_sign_up_compact =>
      'Lies unsere rechtlichen Bedingungen, bevor du dein Konto erstellst.';

  @override
  String get auth_privacy_policy_link => 'Datenschutzerklärung';

  @override
  String get auth_terms_of_use_link => 'Nutzungsbedingungen';

  @override
  String get common_retry => 'Erneut versuchen';

  @override
  String get session_detail_save_cta => 'Speichern';

  @override
  String get session_detail_saved_cta => 'Gespeichert';

  @override
  String get session_detail_start_cta => 'Session starten';

  @override
  String get startup_error_title => 'Start fehlgeschlagen';

  @override
  String get update_available_body =>
      'Eine neue Version von Desk Workout ist verfügbar.';

  @override
  String get quick_fix_equipment_none => 'Keine zusätzliche Ausrüstung';

  @override
  String get quick_fix_equipment_towel => 'Handtuch';

  @override
  String get quick_fix_equipment_long_band => 'Widerstandsband';

  @override
  String get quick_fix_equipment_mini_band => 'Mini-Band';

  @override
  String get quick_fix_equipment_foam_roller => 'Faszienrolle';

  @override
  String get quick_fix_equipment_massage_ball => 'Massageball';

  @override
  String get quick_fix_equipment_soft_ball => 'Weicher Ball';

  @override
  String get quick_fix_equipment_water_bottle => 'Wasserflasche';

  @override
  String get quick_fix_equipment_dowel => 'Stab / Besenstiel';

  @override
  String get quick_fix_problem_forearms => 'Unterarme';

  @override
  String get quick_fix_problem_hands => 'Hände & Finger';

  @override
  String get quick_fix_problem_hips_glutes => 'Hüfte & Gesäß';

  @override
  String get quick_fix_problem_upper_back => 'Oberer Rücken';

  @override
  String get quick_fix_signal_equipment_based =>
      'Passt zu deiner verfügbaren Ausrüstung';

  @override
  String get player_left => 'VERBLEIBEND';

  @override
  String get player_more_guidance => 'Mehr Anleitung';

  @override
  String get player_voice_on => 'Stimme an';

  @override
  String get player_voice_off => 'Stimme aus';

  @override
  String get program_days_suffix => 'Tage';

  @override
  String program_minutes_per_day(Object count) {
    return '$count Min./Tag';
  }

  @override
  String get program_difficulty_beginner => 'Einsteiger';

  @override
  String get program_difficulty_intermediate => 'Mittel';

  @override
  String get program_difficulty_advanced => 'Fortgeschritten';

  @override
  String get program_recovery_route => 'Erholungsweg';

  @override
  String get insights_active_suffix => 'aktiv';

  @override
  String get player_reps_suffix => 'Wdh.';

  @override
  String player_step_of(Object current, Object total) {
    return 'Schritt $current von $total';
  }
}
