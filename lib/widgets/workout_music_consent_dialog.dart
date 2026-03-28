import 'package:flutter/material.dart';

Future<bool> showWorkoutMusicConsentDialog(BuildContext context) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('Workout music'),
        content: const SingleChildScrollView(
          child: Text(
            'For a more immersive session, you can use Duria’s preset background music. '
            'It keeps playing in the background so you can switch to other apps during training '
            'without losing your rhythm.\n\n'
            'Use preset music?',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Use music'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
