import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load saved theme
class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

/// Event to change theme
class ChangeTheme extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Event to toggle between light and dark
class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}
