import 'package:flutter/material.dart';
import 'translations/pt_br.dart';
import 'translations/en_us.dart';
import 'translations/es_es.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    switch (locale.languageCode) {
      case 'pt':
        _localizedStrings = ptBR;
        break;
      case 'en':
        _localizedStrings = enUS;
        break;
      case 'es':
        _localizedStrings = esES;
        break;
      default:
        _localizedStrings = ptBR;
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common
  String get appName => translate('app_name');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get close => translate('close');
  String get back => translate('back');
  String get next => translate('next');
  String get skip => translate('skip');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get tryAgain => translate('try_again');
  String get noData => translate('no_data');
  String get refresh => translate('refresh');

  // Auth
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get cpf => translate('cpf');
  String get birthDate => translate('birth_date');

  // Ride
  String get requestRide => translate('request_ride');
  String get pickup => translate('pickup');
  String get dropoff => translate('dropoff');
  String get estimatedPrice => translate('estimated_price');
  String get estimatedTime => translate('estimated_time');
  String get distance => translate('distance');
  String get duration => translate('duration');
  String get rideHistory => translate('ride_history');
  String get rideDetails => translate('ride_details');
  String get cancelRide => translate('cancel_ride');
  String get rateRide => translate('rate_ride');
  String get rideStatus => translate('ride_status');

  // Ride Status
  String get statusSearching => translate('status_searching');
  String get statusAccepted => translate('status_accepted');
  String get statusArrived => translate('status_arrived');
  String get statusInProgress => translate('status_in_progress');
  String get statusCompleted => translate('status_completed');
  String get statusCancelled => translate('status_cancelled');

  // Payment
  String get payment => translate('payment');
  String get paymentMethod => translate('payment_method');
  String get paymentMethods => translate('payment_methods');
  String get addPaymentMethod => translate('add_payment_method');
  String get cash => translate('cash');
  String get creditCard => translate('credit_card');
  String get pix => translate('pix');

  // Driver
  String get driver => translate('driver');
  String get online => translate('online');
  String get offline => translate('offline');
  String get acceptRide => translate('accept_ride');
  String get arrivedAtPickup => translate('arrived_at_pickup');
  String get startRide => translate('start_ride');
  String get completeRide => translate('complete_ride');
  String get earnings => translate('earnings');
  String get todayEarnings => translate('today_earnings');
  String get weekEarnings => translate('week_earnings');
  String get monthEarnings => translate('month_earnings');

  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get notifications => translate('notifications');
  String get help => translate('help');
  String get about => translate('about');

  // Errors
  String get errorGeneric => translate('error_generic');
  String get errorNetwork => translate('error_network');
  String get errorAuth => translate('error_auth');
  String get errorInvalidCredentials => translate('error_invalid_credentials');
  String get errorSessionExpired => translate('error_session_expired');

  // Validation
  String get validationRequired => translate('validation_required');
  String get validationEmail => translate('validation_email');
  String get validationPassword => translate('validation_password');
  String get validationPasswordMatch => translate('validation_password_match');
  String get validationPhone => translate('validation_phone');
  String get validationCPF => translate('validation_cpf');

  // Messages
  String get msgRideRequested => translate('msg_ride_requested');
  String get msgRideCancelled => translate('msg_ride_cancelled');
  String get msgRideCompleted => translate('msg_ride_completed');
  String get msgPaymentAdded => translate('msg_payment_added');
  String get msgProfileUpdated => translate('msg_profile_updated');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
