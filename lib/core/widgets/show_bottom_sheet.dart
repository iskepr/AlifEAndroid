import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "../../constants.dart";
import "../theme/colors.dart";
import "../theme/material.dart";

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({
    super.key,
    required this.child,
    this.bg = true,
    this.reverse = false,
    this.closeButton = false,
    this.actionButtons = const [],
    this.header,
    this.height,
    this.isScrolable = false,
  });

  final Widget child;
  final bool bg;
  final bool reverse;
  final bool closeButton;
  final List<Widget> actionButtons;
  final Widget? header;
  final double? height;
  final bool isScrolable;

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.height ?? 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => MyMaterial(
        width: double.infinity,
        theme: MyMaterialTheme.solid,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kMediumBorderRadius),
          topRight: Radius.circular(kMediumBorderRadius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isScrolable
                  ? _buildScrollableContent(controller)
                  : _buildStaticContent(),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFloatingHeader(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticContent() {
    return Padding(
      padding: const EdgeInsets.only(
        left: kMediumPadding,
        right: kMediumPadding,
        top: kSmallPadding,
      ),
      child: widget.child,
    );
  }

  Widget _buildScrollableContent(ScrollController controller) {
    return ListView(
      controller: controller,
      reverse: widget.reverse,
      padding: const EdgeInsets.only(
        left: kMediumPadding,
        right: kMediumPadding,
        top: 20.0,
        bottom: kMediumPadding,
      ),
      children: [widget.child],
    );
  }

  Widget _buildFloatingHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kMediumBorderRadius),
          topRight: Radius.circular(kMediumBorderRadius),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.background, context.background.withOpacity(0)],
        ),
      ),
      padding: const EdgeInsets.only(
        left: kMediumPadding,
        right: kMediumPadding,
        top: kSmallPadding,
        bottom: kLargePadding,
      ),
      child: widget.header ?? _buildDefaultHeader(context),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    final hasActions = widget.closeButton || widget.actionButtons.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: kSmallPadding),
          decoration: BoxDecoration(
            color: context.secondary,
            borderRadius: BorderRadius.circular(kMediumBorderRadius),
          ),
          height: 5,
          width: 40,
        ),
        if (hasActions)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.closeButton
                  ? IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    )
                  : const SizedBox.shrink(),
              if (widget.actionButtons.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.actionButtons,
                ),
            ],
          ),
      ],
    );
  }
}

Future<T?> showMyBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrolable = false,
  bool reverse = false,
  bool easyClose = true,
  bool? closeButton,
  List<Widget>? actionButtons,
  Widget? header,
  double? height,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: easyClose,
    enableDrag: easyClose,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    // sheetAnimationStyle: const AnimationStyle(
    //   curve: kCurveEaseOutBack,
    //   reverseCurve: kCurveEaseOutBack,
    //   duration: kAnimationDuration,
    //   reverseDuration: kAnimationDuration,
    // ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: kSmallPadding,
          right: kSmallPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MyBottomSheet(
          reverse: reverse,
          isScrolable: isScrolable,
          closeButton: closeButton ?? false,
          actionButtons: actionButtons ?? [],
          header: header,
          height: height,
          child: child,
        ),
      );
    },
  );
}
