import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{


  late AnimationController _controller;
  late Animation<Offset> _logoController;// should be logoAnimatin
  late Animation<Offset> _textController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
  }


  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
