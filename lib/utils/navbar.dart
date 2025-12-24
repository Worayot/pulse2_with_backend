import 'package:flutter/material.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  const CustomAnimatedBottomBar({
    super.key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.itemCornerRadius = 20,
    this.containerHeight = 70,
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  }) : assert(items.length >= 2 && items.length <= 5);

  final int selectedIndex;
  final double iconSize;
  final Color? backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xff3362CC);
    return SafeArea(
      bottom: false,
      top: false,
      child: Container(
        decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)), color: bgColor),
        width: double.infinity,
        height: containerHeight,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children:
              items.map((item) {
                var index = items.indexOf(item);
                return GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: _ItemWidget(
                    item: item,
                    iconSize: iconSize,
                    isSelected: index == selectedIndex,
                    backgroundColor: bgColor,
                    itemCornerRadius: itemCornerRadius,
                    animationDuration: animationDuration,
                    curve: curve,
                    boxWidth: item.boxWidth,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final Curve curve;
  final double boxWidth;

  const _ItemWidget({
    required this.item,
    required this.isSelected,
    required this.backgroundColor,
    required this.animationDuration,
    required this.itemCornerRadius,
    required this.iconSize,
    required this.boxWidth, // Accept boxWidth from parent
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        width: isSelected ? boxWidth : size.width * 0.1,
        height: double.maxFinite,
        duration: animationDuration,
        curve: curve,
        decoration: BoxDecoration(color: isSelected ? item.activeColor.withOpacity(0.2) : backgroundColor, borderRadius: BorderRadius.circular(itemCornerRadius)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: IconTheme(
                    data: IconThemeData(size: iconSize, color: isSelected ? item.activeColor.withOpacity(1) : item.inactiveColor ?? item.activeColor),
                    child: item.icon,
                  ),
                ),
                if (isSelected) SizedBox(width: size.width * 0.025), // Space between icon and text
                if (isSelected)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: item.activeColor, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: item.textAlign,
                        child: item.title,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({required this.icon, required this.title, this.activeColor = const Color(0xff407BFF), this.textAlign, this.inactiveColor, required this.boxWidth});

  final Widget icon;
  final Widget title;
  final Color activeColor;
  final Color? inactiveColor;
  final TextAlign? textAlign;
  final double boxWidth;
}
