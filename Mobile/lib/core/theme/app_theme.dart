import 'package:flutter/material.dart';

class AppTheme {
  // Colores base de Latinoamérica Comparte
  static const Color _primaryPurple     = Color(0xFF7B2CBF); // morado principal
  static const Color _darkPurple        = Color(0xFF5A189A); // morado oscuro
  static const Color _lightPurpleTint   = Color(0xFFF5F0FB); // fondo claro con tinte morado
  static const Color _surfaceDark       = Color(0xFF1A0D2E); // fondo oscuro con tinte morado
  static const Color _cardDark          = Color(0xFF271040); // cards en modo oscuro
  static const Color _cardDarker        = Color(0xFF1F0D35); // inputs en modo oscuro

  // ── Tema claro ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor:  _primaryPurple,
      brightness: Brightness.light,
    ).copyWith(
      primary:          _primaryPurple,
      onPrimary:        Colors.white,
      primaryContainer: const Color(0xFFE8D5F5),
      secondary:        _darkPurple,
      onSecondary:      Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  base,
      scaffoldBackgroundColor: _lightPurpleTint,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor:       Colors.white,
        foregroundColor:       base.onSurface,
        elevation:             0,
        scrolledUnderElevation: 1,
        shadowColor:           _primaryPurple.withOpacity(0.10),
        titleTextStyle: const TextStyle(
          color:      Color(0xFF1A0D2E),
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation:         0,
        color:             Colors.white,
        surfaceTintColor:  Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _primaryPurple.withOpacity(0.12)),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: const Color(0xFFF0E8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: _primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: base.error, width: 1.5),
        ),
        labelStyle:  TextStyle(color: _primaryPurple.withOpacity(0.8)),
        prefixIconColor: _primaryPurple.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Botones rellenos
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryPurple,
        ),
      ),

      // Botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryPurple,
          side: BorderSide(color: _primaryPurple),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFFE8D5F5),
        labelStyle: TextStyle(color: _darkPurple, fontWeight: FontWeight.w600),
      ),

      // Navigation Drawer
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor:  Colors.white,
        indicatorColor:   Color(0xFFE8D5F5),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: _primaryPurple.withOpacity(0.12),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor:  WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _primaryPurple : Colors.grey,
        ),
        trackColor:  WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _primaryPurple.withOpacity(0.4)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  // ── Tema oscuro ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor:  _primaryPurple,
      brightness: Brightness.dark,
    ).copyWith(
      primary:          const Color(0xFFCB9EF5), // morado claro sobre fondo oscuro
      onPrimary:        const Color(0xFF3A0878),
      primaryContainer: const Color(0xFF5A189A),
      secondary:        const Color(0xFFB07EEA),
      surface:          _surfaceDark,
      surfaceContainerHighest: _cardDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  base,
      scaffoldBackgroundColor: _surfaceDark,

      appBarTheme: AppBarTheme(
        backgroundColor:       _cardDark,
        foregroundColor:       base.onSurface,
        elevation:             0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color:      base.onSurface,
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation:         0,
        color:             _cardDark,
        surfaceTintColor:  Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFCB9EF5).withOpacity(0.15)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: _cardDarker,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: Color(0xFFCB9EF5), width: 2),
        ),
        labelStyle:      const TextStyle(color: Color(0xFFCB9EF5)),
        prefixIconColor: const Color(0xFFCB9EF5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9D4EDD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFCB9EF5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFCB9EF5),
          side: const BorderSide(color: Color(0xFFCB9EF5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9D4EDD),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFF5A189A),
        labelStyle: const TextStyle(
            color: Color(0xFFE8D5F5), fontWeight: FontWeight.w600),
      ),

      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor:  _cardDark,
        indicatorColor:   const Color(0xFF5A189A),
      ),

      dividerTheme: DividerThemeData(
        color: const Color(0xFFCB9EF5).withOpacity(0.15),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFFCB9EF5)
              : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF9D4EDD).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}