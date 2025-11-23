import 'package:flutter/material.dart';

class SocialLogin extends StatelessWidget {
  final Color subtle;
  final Color inputBg;
  final Color secondary;
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  const SocialLogin({
    super.key,
    required this.subtle,
    required this.inputBg,
    required this.secondary,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  });

    @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40, 
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: inputBg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: onGooglePressed,
              icon: const Icon(Icons.g_mobiledata, size: 18, color: Colors.red),
              label: const Text("Google", style: TextStyle(fontSize: 11)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 40, 
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: onFacebookPressed,
              icon: const Icon(Icons.facebook, size: 16, color: Colors.white),
              label: const Text("Facebook", style: TextStyle(fontSize: 11)),
            ),
          ),
        ),
      ],
    );
  }
}
