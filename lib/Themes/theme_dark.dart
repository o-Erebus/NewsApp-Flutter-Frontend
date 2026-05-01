import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff576062),
      surfaceTint: Color(0xff576062),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe9f2f4),
      onPrimaryContainer: Color(0xff656e70),
      secondary: Color(0xff5c5f60),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdee0e0),
      onSecondaryContainer: Color(0xff606364),
      tertiary: Color(0xff3c3b3f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff535256),
      onTertiaryContainer: Color(0xffc8c5ca),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcf9f8),
      onSurface: Color(0xff1b1c1c),
      onSurfaceVariant: Color(0xff434849),
      outline: Color(0xff737879),
      outlineVariant: Color(0xffc3c7c8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303030),
      inversePrimary: Color(0xffbfc8ca),
      primaryFixed: Color(0xffdbe4e6),
      onPrimaryFixed: Color(0xff141d1f),
      primaryFixedDim: Color(0xffbfc8ca),
      onPrimaryFixedVariant: Color(0xff3f484a),
      secondaryFixed: Color(0xffe1e3e3),
      onSecondaryFixed: Color(0xff191c1d),
      secondaryFixedDim: Color(0xffc5c7c7),
      onSecondaryFixedVariant: Color(0xff444748),
      tertiaryFixed: Color(0xffe4e1e6),
      onTertiaryFixed: Color(0xff1b1b1f),
      tertiaryFixedDim: Color(0xffc8c5ca),
      onTertiaryFixedVariant: Color(0xff47464a),
      surfaceDim: Color(0xffdcd9d9),
      surfaceBright: Color(0xfffcf9f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff0eded),
      surfaceContainerHigh: Color(0xffeae7e7),
      surfaceContainerHighest: Color(0xffe4e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff2f3839),
      surfaceTint: Color(0xff576062),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff666f71),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff333737),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6b6d6e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff363639),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff535256),
      onTertiaryContainer: Color(0xfff7f3f8),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf9f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff323738),
      outline: Color(0xff4f5354),
      outlineVariant: Color(0xff696e6f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303030),
      inversePrimary: Color(0xffbfc8ca),
      primaryFixed: Color(0xff666f71),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4d5658),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6b6d6e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff525556),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6e6c70),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff555458),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc8c6c5),
      surfaceBright: Color(0xfffcf9f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffeae7e7),
      surfaceContainerHigh: Color(0xffdfdcdc),
      surfaceContainerHighest: Color(0xffd3d1d1),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff252e2f),
      surfaceTint: Color(0xff576062),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff424b4d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff292d2d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff464a4a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2c2c2f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff49494c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf9f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff282d2e),
      outlineVariant: Color(0xff454a4b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303030),
      inversePrimary: Color(0xffbfc8ca),
      primaryFixed: Color(0xff424b4d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2b3436),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff464a4a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff303334),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff49494c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff333236),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbab8b8),
      surfaceBright: Color(0xfffcf9f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f0f0),
      surfaceContainer: Color(0xffe4e2e1),
      surfaceContainerHigh: Color(0xffd6d4d3),
      surfaceContainerHighest: Color(0xffc8c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbfc8ca),
      onPrimary: Color(0xff293234),
      primaryContainer: Color(0xffdbe4e6),
      onPrimaryContainer: Color(0xff5d6668),
      secondary: Color(0xffc5c7c7),
      onSecondary: Color(0xff2e3132),
      secondaryContainer: Color(0xff494c4d),
      onSecondaryContainer: Color(0xffbabcbd),
      tertiary: Color(0xffc8c5ca),
      onTertiary: Color(0xff303034),
      tertiaryContainer: Color(0xff535256),
      onTertiaryContainer: Color(0xffc8c5ca),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff131313),
      onSurface: Color(0xffe4e2e1),
      onSurfaceVariant: Color(0xffc3c7c8),
      outline: Color(0xff8d9192),
      outlineVariant: Color(0xff434849),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e1),
      inversePrimary: Color(0xff576062),
      primaryFixed: Color(0xffdbe4e6),
      onPrimaryFixed: Color(0xff141d1f),
      primaryFixedDim: Color(0xffbfc8ca),
      onPrimaryFixedVariant: Color(0xff3f484a),
      secondaryFixed: Color(0xffe1e3e3),
      onSecondaryFixed: Color(0xff191c1d),
      secondaryFixedDim: Color(0xffc5c7c7),
      onSecondaryFixedVariant: Color(0xff444748),
      tertiaryFixed: Color(0xffe4e1e6),
      onTertiaryFixed: Color(0xff1b1b1f),
      tertiaryFixedDim: Color(0xffc8c5ca),
      onTertiaryFixedVariant: Color(0xff47464a),
      surfaceDim: Color(0xff131313),
      surfaceBright: Color(0xff393939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1b1c1c),
      surfaceContainer: Color(0xff1f2020),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353535),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbfc8ca),
      onPrimary: Color(0xff293234),
      primaryContainer: Color(0xffdbe4e6),
      onPrimaryContainer: Color(0xff41494b),
      secondary: Color(0xffdbdddd),
      onSecondary: Color(0xff232627),
      secondaryContainer: Color(0xff8e9192),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdedbe0),
      onTertiary: Color(0xff262529),
      tertiaryContainer: Color(0xff929094),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd9ddde),
      outline: Color(0xffaeb3b4),
      outlineVariant: Color(0xff8d9192),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e1),
      inversePrimary: Color(0xff41494b),
      primaryFixed: Color(0xffdbe4e6),
      onPrimaryFixed: Color(0xff0a1214),
      primaryFixedDim: Color(0xffbfc8ca),
      onPrimaryFixedVariant: Color(0xff2f3839),
      secondaryFixed: Color(0xffe1e3e3),
      onSecondaryFixed: Color(0xff0e1212),
      secondaryFixedDim: Color(0xffc5c7c7),
      onSecondaryFixedVariant: Color(0xff333737),
      tertiaryFixed: Color(0xffe4e1e6),
      onTertiaryFixed: Color(0xff111114),
      tertiaryFixedDim: Color(0xffc8c5ca),
      onTertiaryFixedVariant: Color(0xff363639),
      surfaceDim: Color(0xff131313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1d1e1e),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffbfc8ca),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffdbe4e6),
      onPrimaryContainer: Color(0xff232b2d),
      secondary: Color(0xffeef0f1),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc1c3c3),
      onSecondaryContainer: Color(0xff090c0c),
      tertiary: Color(0xfff2eff4),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc4c2c6),
      onTertiaryContainer: Color(0xff0b0b0e),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff131313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffedf1f1),
      outlineVariant: Color(0xffbfc3c4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e1),
      inversePrimary: Color(0xff41494b),
      primaryFixed: Color(0xffdbe4e6),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffbfc8ca),
      onPrimaryFixedVariant: Color(0xff0a1214),
      secondaryFixed: Color(0xffe1e3e3),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc5c7c7),
      onSecondaryFixedVariant: Color(0xff0e1212),
      tertiaryFixed: Color(0xffe4e1e6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc8c5ca),
      onTertiaryFixedVariant: Color(0xff111114),
      surfaceDim: Color(0xff131313),
      surfaceBright: Color(0xff505050),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1f2020),
      surfaceContainer: Color(0xff303030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff474746),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
