import 'package:flutter/material.dart';


class CustomImageWithProgress extends StatefulWidget {
  final String imageUrl;

  CustomImageWithProgress({required this.imageUrl});

  @override
  _CustomImageWithProgressState createState() =>
      _CustomImageWithProgressState();
}

class _CustomImageWithProgressState extends State<CustomImageWithProgress> {
  late Image _image;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _image = Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print("Error loading image: $error");
        return Icon(Icons.error);
      },
    );

    _image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (info, call) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          print('Error loading image: $exception');
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _image,
        if (_loading)
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              value: null,
              semanticsLabel: 'Image loading',
              semanticsValue: 'loading',
            ),
          ),
      ],
    );
  }
}
