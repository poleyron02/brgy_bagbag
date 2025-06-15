import 'package:flutter/material.dart';

class ShowImageListTile extends StatelessWidget {
  const ShowImageListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: const Text('Show image'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ImageDialog(
            label: label,
            url: url,
          ),
        );
      },
    );
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog({
    super.key,
    required this.label,
    required this.url,
  });

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(label),
        ),
        body: SizedBox.expand(
          child: InteractiveViewer(
            child: Image.network(url),
          ),
        ),
      ),
    );
  }
}
