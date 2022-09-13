import 'package:flutter/material.dart';
import 'package:universally/universally.dart';

class BasicScaffold extends ExtendedScaffold {
  BasicScaffold(
      {super.key,
      Widget? child,

      /// [children].length > 0 [child] invalid
      super.children,

      /// [children].length > 0 && [isStack]=false invalid;
      super.mainAxisAlignment = MainAxisAlignment.start,

      /// [children].length > 0 && [isStack]=false invalid;
      super.crossAxisAlignment = CrossAxisAlignment.center,

      /// [children].length > 0 && [isStack]=false invalid;
      super.direction = Axis.vertical,
      super.safeLeft = false,
      super.safeTop = false,
      super.safeRight = false,
      super.safeBottom = false,
      super.isScroll = false,
      super.isStack = false,
      super.resizeToAvoidBottomInset = false,
      Widget? title,
      String? appBarTitle,
      Widget? appBarRightWidget,
      Color? appBarBackgroundColor,
      Widget? appBarLeftWidget,
      super.padding,
      super.bottomNavigationBar,
      super.endDrawer,
      Color? backgroundColor,
      super.floatingActionButton,
      super.floatingActionButtonAnimator,
      super.floatingActionButtonLocation,
      VoidCallback? onRefresh,
      VoidCallback? onLoading,
      super.onWillPopOverlayClose = false,
      super.onWillPop,
      double? elevation,
      bool? titleCenter,
      super.decoration,
      bool isMaybePop = false,
      super.useSingleChildScrollView = true,
      List<Widget>? actions,
      PreferredSizeWidget? appBarBottom})
      : super(
            backgroundColor:
                backgroundColor ?? GlobalConfig().config.scaffoldBackground,
            refreshConfig: (onRefresh != null || onLoading != null)
                ? RefreshConfig(
                    footer: GlobalConfig().config.pullUpFooter,
                    header: GlobalConfig().config.pullDownHeader,
                    onLoading:
                        onLoading == null ? null : () async => onLoading.call(),
                    onRefresh:
                        onRefresh == null ? null : () async => onRefresh.call())
                : null,
            body: child,
            appBar: title == null &&
                    appBarTitle == null &&
                    appBarBottom == null &&
                    appBarRightWidget == null
                ? null
                : BasicAppBar(
                    actions: actions,
                    isMaybePop: isMaybePop,
                    bottom: appBarBottom,
                    text: appBarTitle,
                    title: title,
                    elevation:
                        elevation ?? GlobalConfig().config.appBarElevation,
                    right: appBarRightWidget,
                    backgroundColor: appBarBackgroundColor,
                    leading: appBarLeftWidget));
}

class BasicAppBar extends AppBar {
  BasicAppBar(
      {super.key,
      String? text,
      Widget? title,
      Widget? right,
      List<Widget>? actions,
      bool isMaybePop = false,
      double? elevation,
      Widget? leading,
      Color? backgroundColor,
      super.centerTitle = true,
      super.systemOverlayStyle = const SystemUiOverlayStyleDark(),
      super.iconTheme = const IconThemeData.fallback(),
      super.bottom})
      : super(
            title: title ?? TextLarge(text),
            leading: leading ?? BackIcon(isMaybePop: isMaybePop),
            elevation: elevation ?? GlobalConfig().config.appBarElevation,
            actions: actions ??
                <Widget>[
                  if (right != null)
                    Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(right: 16),
                        child: right)
                ],
            backgroundColor: backgroundColor ?? UCS.white);
}

class BackIcon extends IconButton {
  const BackIcon(
      {super.key,
      VoidCallback? onPressed,
      bool isMaybePop = false,
      super.icon = const Icon(UIS.androidBack),
      super.padding = EdgeInsets.zero,
      super.color = UCS.black})
      : super(onPressed: onPressed ?? (isMaybePop ? maybePop : pop));
}
