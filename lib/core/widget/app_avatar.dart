// SvgPicture.asset(AppSvg.avatars[avatarId], height: size, width: size)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.avatarId, required this.size});
  final int avatarId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/svg/avatar$avatarId.svg', height: size, width: size);
  }
}
