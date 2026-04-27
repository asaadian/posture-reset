import 'package:flutter/material.dart';

class ResponsivePageScaffold extends StatelessWidget {
  const ResponsivePageScaffold({
    super.key,
    this.title,
    required this.bodyBuilder,
    this.actions,
    this.floatingActionButton,
    this.maxContentWidth = 1200,
    this.horizontalPadding = 16,
    this.hideAppBar = false,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.bodyTopPadding,
    this.bodyBottomPadding,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget Function(BuildContext context, ResponsivePageInfo pageInfo)
  bodyBuilder;
  final Widget? floatingActionButton;
  final double maxContentWidth;
  final double horizontalPadding;
  final bool hideAppBar;
  final bool extendBodyBehindAppBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double? bodyTopPadding;
  final double? bodyBottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageInfo = ResponsivePageInfo.fromWidth(constraints.maxWidth);

        return Scaffold(
          backgroundColor: backgroundColor,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: hideAppBar
              ? null
              : (title != null ? AppBar(title: title, actions: actions) : null),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: SafeArea(
            bottom: bottomNavigationBar == null,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pageInfo.pagePadding(horizontalPadding),
                    bodyTopPadding ?? pageInfo.verticalPadding,
                    pageInfo.pagePadding(horizontalPadding),
                    bodyBottomPadding ?? pageInfo.verticalPadding,
                  ),
                  child: bodyBuilder(context, pageInfo),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ResponsivePageInfo {
  const ResponsivePageInfo({
    required this.width,
    required this.isCompact,
    required this.isMedium,
    required this.isExpanded,
    required this.columns,
  });

  final double width;
  final bool isCompact;
  final bool isMedium;
  final bool isExpanded;
  final int columns;

  factory ResponsivePageInfo.fromWidth(double width) {
    if (width >= 1100) {
      return ResponsivePageInfo(
        width: width,
        isCompact: false,
        isMedium: false,
        isExpanded: true,
        columns: 3,
      );
    }

    if (width >= 700) {
      return ResponsivePageInfo(
        width: width,
        isCompact: false,
        isMedium: true,
        isExpanded: false,
        columns: 2,
      );
    }

    return ResponsivePageInfo(
      width: width,
      isCompact: true,
      isMedium: false,
      isExpanded: false,
      columns: 1,
    );
  }

  double pagePadding(double compactBase) {
    if (isExpanded) return 32;
    if (isMedium) return 24;
    return compactBase;
  }

  double get verticalPadding {
    if (isExpanded) return 28;
    if (isMedium) return 24;
    return 16;
  }

  double get sectionSpacing {
    if (isExpanded) return 24;
    if (isMedium) return 20;
    return 16;
  }

  double get cardGap {
    if (isExpanded) return 20;
    if (isMedium) return 16;
    return 12;
  }

  double get compactCardRadius {
    if (isExpanded) return 28;
    if (isMedium) return 24;
    return 20;
  }

  int gridColumns({int compact = 1, int medium = 2, int expanded = 3}) {
    if (isExpanded) return expanded;
    if (isMedium) return medium;
    return compact;
  }

  double gridChildAspectRatio({
    double compact = 1.08,
    double medium = 1.18,
    double expanded = 1.28,
  }) {
    if (isExpanded) return expanded;
    if (isMedium) return medium;
    return compact;
  }
}
