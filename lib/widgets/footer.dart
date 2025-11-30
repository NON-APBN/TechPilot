import 'package:flutter/material.dart';
import '../shared/app_localizations.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-aware colors
    // Light Mode: Soft Purple (as requested)
    // Dark Mode: Deep Dark Purple/Blue (as requested)
    final footerColor = isDark 
        ? const Color(0xFF0F0C29) // Deep dark purple/blue
        : const Color(0xFF9980FA); // Soft purple
    final textColor = Colors.white; // White text works for both
    final subTextColor = Colors.white70;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      width: double.infinity,
      color: footerColor,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center align for mobile/zoomed
              children: [
                _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_about'), textColor: textColor),
                const SizedBox(height: 16),
                _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_suggest'), textColor: textColor),
                const SizedBox(height: 16),
                _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_partner'), textColor: textColor),
                const SizedBox(height: 16),
                _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_contact'), textColor: textColor),
                const SizedBox(height: 40),
                _BrandingSection(textColor: textColor, subTextColor: subTextColor, isMobile: true),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spacer Left to balance the layout
                const Expanded(child: SizedBox()),
                
                // Links Section (Centered)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_about'), textColor: textColor),
                    const SizedBox(width: 32),
                    _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_suggest'), textColor: textColor),
                    const SizedBox(width: 32),
                    _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_partner'), textColor: textColor),
                    const SizedBox(width: 32),
                    _SimpleFooterLink(text: AppLocalizations.of(context).get('footer_contact'), textColor: textColor),
                  ],
                ),

                // Branding Section (Right aligned)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _BrandingSection(textColor: textColor, subTextColor: subTextColor, isMobile: false),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SimpleFooterLink extends StatelessWidget {
  final String text;
  final Color textColor;

  const _SimpleFooterLink({required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (text == AppLocalizations.of(context).get('footer_about')) {
          Navigator.pushNamed(context, '/about');
        } else if (text == AppLocalizations.of(context).get('footer_suggest')) {
          Navigator.pushNamed(context, '/suggestion');
        } else if (text == AppLocalizations.of(context).get('footer_partner')) {
          Navigator.pushNamed(context, '/partnership');
        } else if (text == AppLocalizations.of(context).get('footer_contact')) {
          Navigator.pushNamed(context, '/contact');
        }
      },
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _BrandingSection extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;

  const _BrandingSection({
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "TechPilot",
          style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
      ],
    );
  }
}
