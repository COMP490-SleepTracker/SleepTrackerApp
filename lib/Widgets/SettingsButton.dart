import 'package:flutter/material.dart';

//android style settings button
class SettingsButton extends StatelessWidget
{
  const SettingsButton({Key? key, required this.child, required this.onPressed, this.indent = 0}) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final int indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indent.toDouble()),
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),

      // our button
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class OpenableDrawer extends StatefulWidget
{
  const OpenableDrawer({Key? key, required this.label, required this.child, this.indent = 0}) : super(key: key);

  final Widget label;
  final Widget child;
  final int indent;

  @override
  State<OpenableDrawer> createState() => _OpenableDrawerState();
}

class _OpenableDrawerState extends State<OpenableDrawer>
{
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      padding: EdgeInsets.only(left: widget.indent.toDouble()),
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),

      // our button
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isOpen = !isOpen;
          });
        },
        child: Row(
          children: [
            widget.label,
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );

    Widget drawer = Container(
      padding: EdgeInsets.only(left: widget.indent.toDouble()),
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),

      // our button
      child: widget.child,
    );

    return Column(
      children: [
        button,
        if (isOpen) drawer,
      ],
    );
  }

}