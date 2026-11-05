import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum LegalDocumentKind { privacy, terms, deletion }

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.kind});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final german = Localizations.localeOf(context).languageCode == 'de';
    final title = switch (kind) {
      LegalDocumentKind.privacy => german ? 'Datenschutzerklärung' : 'Privacy Policy',
      LegalDocumentKind.terms => german ? 'Nutzungsbedingungen' : 'Terms of Use',
      LegalDocumentKind.deletion => german ? 'Konto- und Datenlöschung' : 'Account & Data Deletion',
    };
    final sections = _sections(kind, german);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            children: [
              Text(
                german
                    ? 'Desk Workout · WegLabs · Stand: November 2026'
                    : 'Desk Workout · WegLabs · Updated: November 2026',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              for (final section in sections) ...[
                Text(section.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                Text(section.body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.55)),
                const SizedBox(height: 22),
              ],
              const Divider(),
              const SizedBox(height: 10),
              Text(german ? 'Kontakt' : 'Contact',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri(scheme: 'mailto', path: 'contact@weglabs.com'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.mail_outline_rounded),
                label: const Text('contact@weglabs.com'),
              ),
              const SizedBox(height: 8),
              Text(
                german
                    ? 'Diese Hinweise sind direkt in der App gespeichert und auch offline verfügbar. Fragen zu deinen Rechten oder zur Löschung kannst du an die oben genannte Adresse richten.'
                    : 'This notice is stored in the app and is available offline. You can ask questions about your rights or data deletion using the email address above.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection(this.title, this.body);
  final String title;
  final String body;
}

List<_LegalSection> _sections(LegalDocumentKind kind, bool de) {
  switch (kind) {
    case LegalDocumentKind.privacy:
      return de
          ? const [
              _LegalSection('1. Verantwortlicher',
                  'WegLabs ist ein unabhängiges App-Studio in Deutschland. Für Datenschutzanfragen: contact@weglabs.com. Diese Hinweise beziehen sich auf die App Desk Workout.'),
              _LegalSection('2. Daten für die App-Funktionen',
                  'Bei der Nutzung eines Kontos können Kontodaten (z. B. E-Mail-Adresse und Benutzerkennung), Einstellungen, gespeicherte Sessions, Fortschritt, Trainingsverlauf und Premium-Berechtigungen verarbeitet werden. Die Daten werden verwendet, um dein Konto und die gewünschten Funktionen bereitzustellen.'),
              _LegalSection('3. Dienstleister',
                  'Desk Workout nutzt Supabase für Anmeldung, Speicherung und Synchronisierung sowie Google Play für die Abwicklung von In-App-Käufen. Für eine freiwillige Produktanalyse nutzen wir PostHog Cloud EU. Je nach Funktion erhalten diese Anbieter die zur Ausführung benötigten Informationen.'),
              _LegalSection('4. Freiwillige Nutzungsanalyse',
                  'Nur mit deiner gesonderten Einwilligung übermitteln wir ausgewählte Nutzungsereignisse an PostHog, beispielsweise die Nutzung von App-Bereichen, den Beginn oder Abschluss einer Session oder Schritte im Premium-Kaufprozess. Wir senden dabei keine E-Mail-Adresse, keinen Namen und keine Angaben zu Beschwerden, Symptomen oder ausgewählten Körperbereichen als Ereignisparameter. Session Replay (Bildschirmaufzeichnung) ist deaktiviert.'),
              _LegalSection('5. Einwilligung und Widerruf',
                  'Die Nutzungsanalyse ist freiwillig. Du kannst sie ablehnen und Desk Workout weiterhin nutzen. Unter Einstellungen > Datenschutz & Analyse kannst du deine Entscheidung jederzeit ändern. Nach einem Widerruf werden keine neuen freiwilligen Analyseereignisse mehr gesendet. Bereits verarbeitete Daten werden dadurch nicht automatisch gelöscht; hierfür kannst du eine Löschanfrage stellen.'),
              _LegalSection('6. Technische Informationen und Aufbewahrung',
                  'Zur Bereitstellung der App können technische Informationen wie App-Version, Gerätetyp und Betriebssystem anfallen. Daten werden nur für die erforderlichen Zwecke oder aufgrund gesetzlicher Pflichten aufbewahrt. Für genaue Auskunft, Zugriff, Berichtigung oder Löschung kontaktiere uns bitte.'),
              _LegalSection('7. Deine Rechte',
                  'Soweit die Datenschutz-Grundverordnung anwendbar ist, stehen dir unter anderem Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit und Widerspruch sowie der Widerruf einer Einwilligung zu. Du kannst dich auch bei einer zuständigen Datenschutzaufsichtsbehörde beschweren.'),
              _LegalSection('8. Gesundheit und Sicherheit',
                  'Desk Workout bietet allgemeine Bewegungsübungen, keine medizinische Diagnose oder Behandlung. Bitte teile in Analyseereignissen keine Gesundheitsdaten mit.'),
              _LegalSection('9. Änderungen',
                  'Wir aktualisieren diese Hinweise, wenn sich die Datenverarbeitung oder eingesetzte Dienste ändern. Eine aktuelle Fassung wird innerhalb der App bereitgestellt.'),
            ]
          : const [
              _LegalSection('1. Controller',
                  'WegLabs is an independent app studio based in Germany. For privacy requests: contact@weglabs.com. This notice covers the Desk Workout app.'),
              _LegalSection('2. Data required for app features',
                  'If you use an account, we may process account information (such as email and user ID), preferences, saved sessions, progress, session history, and premium entitlements to provide the features you choose.'),
              _LegalSection('3. Service providers',
                  'Desk Workout uses Supabase for authentication, storage and synchronization, and Google Play for in-app purchases. Optional product analytics is provided by PostHog Cloud EU. These providers process information needed for their respective functions.'),
              _LegalSection('4. Optional product analytics',
                  'Only with your separate consent, we send selected usage events to PostHog, such as app-area interactions, session starts and completions, and premium purchase steps. We do not send names, email addresses, symptoms, complaints or selected body areas as event properties. Session Replay (screen recording) is disabled.'),
              _LegalSection('5. Consent and withdrawal',
                  'Product analytics is optional. You can decline and continue using Desk Workout. Change your choice at any time in Settings > Privacy & analytics. After withdrawal, no new optional analytics events are sent. Withdrawal does not automatically erase events already processed; you can request deletion separately.'),
              _LegalSection('6. Technical data and retention',
                  'Technical information such as app version, device category and operating system may be processed to operate the app. Information is retained only as necessary for its purpose or legal obligations. Contact us for details, access, correction or deletion.'),
              _LegalSection('7. Your rights',
                  'Where the GDPR applies, you may have rights to access, correct, erase, restrict, object, request portability and withdraw consent. You may also complain to a competent data protection authority.'),
              _LegalSection('8. Wellness disclaimer',
                  'Desk Workout provides general movement guidance, not diagnosis or medical treatment. Do not include health information in analytics events.'),
              _LegalSection('9. Changes',
                  'We update this notice when our processing or service providers change. A current copy is included in the app.'),
            ];
    case LegalDocumentKind.terms:
      return de
          ? const [
              _LegalSection('1. Anbieter und Geltung',
                  'Desk Workout wird von WegLabs, Deutschland, bereitgestellt. Mit der Nutzung gelten diese Bedingungen und zwingende gesetzliche Verbraucherrechte.'),
              _LegalSection('2. Nutzung',
                  'Du darfst die App im Rahmen der vorgesehenen Funktionen nutzen. Unberechtigter Zugriff, Missbrauch der Dienste, automatisierte Überlastung oder die Umgehung von Kaufberechtigungen sind nicht gestattet.'),
              _LegalSection('3. Konto',
                  'Wenn du ein Konto anlegst, bist du für die Sicherung deiner Zugangsdaten verantwortlich. Bitte informiere uns über einen vermuteten unberechtigten Zugriff.'),
              _LegalSection('4. Trainingshinweise',
                  'Die Inhalte dienen der allgemeinen Bewegung, Mobilität und Entspannung und ersetzen keine medizinische Beratung. Unterbrich eine Übung bei Schmerzen, Schwindel oder anderen Beschwerden und hole bei Bedarf ärztlichen Rat ein.'),
              _LegalSection('5. Premium-Käufe',
                  'Premium-Funktionen können als einmaliger In-App-Kauf über den jeweiligen App-Store angeboten werden. Abrechnung, Rückerstattungen und Bestätigung der Berechtigung erfolgen nach den anwendbaren Store-Bedingungen.'),
              _LegalSection('6. Rechte an Inhalten',
                  'App-Code, Texte, Grafiken und Design gehören WegLabs oder den jeweiligen Lizenzgebern. Gesetzlich erlaubte Nutzungen bleiben unberührt.'),
              _LegalSection('7. Verfügbarkeit und Änderungen',
                  'Funktionen können aktualisiert oder zeitweise eingeschränkt sein. Gesetzliche Gewährleistungs- und Haftungsrechte werden durch diese Bedingungen nicht ausgeschlossen.'),
              _LegalSection('8. Datenschutz und Löschung',
                  'Informationen zur Datenverarbeitung und zur Löschung findest du in den separaten, offline verfügbaren Seiten der App. Fragen richte bitte an contact@weglabs.com.'),
            ]
          : const [
              _LegalSection('1. Provider and scope',
                  'Desk Workout is provided by WegLabs, Germany. These terms apply to use of the app, subject to mandatory consumer protections.'),
              _LegalSection('2. Acceptable use',
                  'Use the app for its intended functions. Unauthorized access, misuse of services, automated disruption or circumvention of purchase entitlements is prohibited.'),
              _LegalSection('3. Accounts',
                  'If you create an account, protect your credentials and contact us if you suspect unauthorized account access.'),
              _LegalSection('4. Exercise guidance',
                  'Content is for general movement, mobility and wellness. It does not replace medical advice. Stop an exercise if you experience pain, dizziness or other concerning symptoms, and seek professional guidance when appropriate.'),
              _LegalSection('5. Premium purchases',
                  'Premium features may be provided through a one-time in-app purchase. Billing, refunds and entitlement confirmation are subject to applicable app store terms.'),
              _LegalSection('6. Intellectual property',
                  'App code, text, artwork and design are owned by WegLabs or their licensors, subject to uses permitted by law.'),
              _LegalSection('7. Availability and changes',
                  'Features may change or be temporarily unavailable. Nothing here excludes statutory consumer or liability protections.'),
              _LegalSection('8. Privacy and deletion',
                  'See the separate offline Privacy Policy and Account & Data Deletion pages for details. Contact contact@weglabs.com with questions.'),
            ];
    case LegalDocumentKind.deletion:
      return de
          ? const [
              _LegalSection('Konto und Daten löschen lassen',
                  'Du kannst die Löschung deines Desk-Workout-Kontos und der zugehörigen personenbezogenen Daten anfragen. Schreibe dazu von der mit deinem Konto verbundenen E-Mail-Adresse an contact@weglabs.com mit dem Betreff „Desk Workout – Konto löschen“.'),
              _LegalSection('Was du angeben solltest',
                  'Nenne die App Desk Workout und bitte ausdrücklich um Kontolöschung. Bitte sende weder Passwörter noch Zahlungsinformationen oder medizinische Angaben. Wir können eine angemessene Identitätsprüfung verlangen, um dein Konto zu schützen.'),
              _LegalSection('Umfang der Löschung',
                  'Soweit rechtlich und technisch möglich, werden das Konto und die damit verbundenen gespeicherten Daten gelöscht oder anonymisiert. Bestimmte Unterlagen können für gesetzliche Pflichten, Sicherheit, Buchhaltung oder Streitfallbearbeitung länger erforderlich sein.'),
              _LegalSection('Freiwillige Analyse',
                  'Unter Einstellungen > Datenschutz & Analyse kannst du weitere Analyseereignisse sofort stoppen. Wenn du auch die Löschung bereits erfasster optionaler Analysedaten möchtest, erwähne das ausdrücklich in deiner Anfrage.'),
              _LegalSection('Hilfe',
                  'Wenn du keinen Zugriff mehr auf die Konto-E-Mail-Adresse hast, beschreibe dies in deiner Anfrage. Wir erläutern dann die mögliche Identitätsprüfung und die nächsten Schritte.'),
            ]
          : const [
              _LegalSection('Request account and data deletion',
                  'You can request deletion of your Desk Workout account and associated personal data. Email contact@weglabs.com from your account email address with the subject “Desk Workout – Delete my account”.'),
              _LegalSection('Information to include',
                  'Name Desk Workout and explicitly request account deletion. Do not send passwords, payment information or medical details. We may need reasonable identity verification to protect the account.'),
              _LegalSection('What is deleted',
                  'Where legally and technically possible, the account and linked stored information will be deleted or anonymized. Some records may need to be retained for legal obligations, security, accounting or dispute resolution.'),
              _LegalSection('Optional analytics',
                  'You can immediately stop new optional analytics events under Settings > Privacy & analytics. If you also want deletion of previously collected optional analytics data, specifically request this in your email.'),
              _LegalSection('Need assistance?',
                  'If you no longer have access to the email linked to your account, explain this in your request. We will advise about possible verification and next steps.'),
            ];
  }
}
