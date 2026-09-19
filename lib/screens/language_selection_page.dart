import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../widgets/common_widgets.dart';

bool _isDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _pageBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF101418) : AppColors.softGrey;
}

Color _cardBackground(BuildContext context) {
  return _isDark(context) ? const Color(0xFF1B2229) : Colors.white;
}

Color _primaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFFF4F7F9) : AppColors.blackText;
}

Color _secondaryText(BuildContext context) {
  return _isDark(context) ? const Color(0xFF9EA9B2) : AppColors.greyText;
}

Color _borderColor(BuildContext context) {
  return _isDark(context) ? const Color(0xFF2B343C) : const Color(0xFFE5E8ED);
}

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final TextEditingController searchController = TextEditingController();

  String selectedLanguage = 'English / United States';

  String searchText = '';

  final List<_LanguageOption> languages = const [
    _LanguageOption(name: 'العربية / السعودية', flagCode: 'sa'),
    _LanguageOption(name: 'English / United States', flagCode: 'us'),
    _LanguageOption(name: 'English / United Kingdom', flagCode: 'gb'),
    _LanguageOption(name: 'Français / France', flagCode: 'fr'),
    _LanguageOption(name: 'Deutsch / Deutschland', flagCode: 'de'),
    _LanguageOption(name: 'Español / España', flagCode: 'es'),
    _LanguageOption(name: 'Italiano / Italia', flagCode: 'it'),
    _LanguageOption(name: 'Português / Portugal', flagCode: 'pt'),
    _LanguageOption(name: 'Português / Brasil', flagCode: 'br'),
    _LanguageOption(name: 'Türkçe / Türkiye', flagCode: 'tr'),
    _LanguageOption(name: 'Русский / Россия', flagCode: 'ru'),
    _LanguageOption(name: 'Українська / Україна', flagCode: 'ua'),
    _LanguageOption(name: '中文 / China', flagCode: 'cn'),
    _LanguageOption(name: '日本語 / Japan', flagCode: 'jp'),
    _LanguageOption(name: '한국어 / South Korea', flagCode: 'kr'),
    _LanguageOption(name: 'हिन्दी / India', flagCode: 'in'),
    _LanguageOption(name: 'اردو / Pakistan', flagCode: 'pk'),
    _LanguageOption(name: 'বাংলা / Bangladesh', flagCode: 'bd'),
    _LanguageOption(name: 'Bahasa Indonesia / Indonesia', flagCode: 'id'),
    _LanguageOption(name: 'Bahasa Melayu / Malaysia', flagCode: 'my'),
    _LanguageOption(name: 'ไทย / Thailand', flagCode: 'th'),
    _LanguageOption(name: 'Tiếng Việt / Vietnam', flagCode: 'vn'),
    _LanguageOption(name: 'Nederlands / Nederland', flagCode: 'nl'),
    _LanguageOption(name: 'Svenska / Sverige', flagCode: 'se'),
    _LanguageOption(name: 'Norsk / Norge', flagCode: 'no'),
    _LanguageOption(name: 'Dansk / Danmark', flagCode: 'dk'),
    _LanguageOption(name: 'Polski / Polska', flagCode: 'pl'),
    _LanguageOption(name: 'Ελληνικά / Ελλάδα', flagCode: 'gr'),
    _LanguageOption(name: 'עברית / Israel', flagCode: 'il'),
    _LanguageOption(name: 'فارسی / Iran', flagCode: 'ir'),
    _LanguageOption(name: 'Kiswahili / Kenya', flagCode: 'ke'),
    _LanguageOption(name: 'Filipino / Philippines', flagCode: 'ph'),
  ];

  List<_LanguageOption> get filteredLanguages {
    final String query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return languages;
    }

    return languages.where((language) {
      return language.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void saveLanguage() {
    Navigator.pop(
      context,
      selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _pageBackground(context);

    return Scaffold(
      backgroundColor: pageColor,
      body: PhonePage(
        backgroundColor: pageColor,
        child: SafeArea(
          child: Column(
            children: [
              _LanguageHeader(
                onBack: () {
                  Navigator.pop(context);
                },
                onDone: saveLanguage,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 20),
                  decoration: BoxDecoration(
                    color: _cardBackground(context),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _borderColor(context),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 11,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search languages',
                          hintStyle: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 10,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: _secondaryText(context),
                                    size: 18,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: _isDark(context)
                              ? const Color(0xFF252D34)
                              : const Color(0xFFF7F9FC),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _borderColor(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredLanguages.isEmpty
                            ? Center(
                                child: Text(
                                  'No languages found',
                                  style: TextStyle(
                                    color: _secondaryText(context),
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filteredLanguages.length,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 1,
                                    indent: 47,
                                    color: _borderColor(context),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final language = filteredLanguages[index];

                                  final bool selected =
                                      selectedLanguage == language.name;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedLanguage = language.name;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: _isDark(context)
                                                  ? const Color(0xFF252D34)
                                                  : const Color(0xFFF5F7FA),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _borderColor(context),
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: Image.network(
                                                'https://flagcdn.com/w80/${language.flagCode}.png',
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return const Icon(
                                                    Icons.language_rounded,
                                                    color:
                                                        AppColors.primaryBlue,
                                                    size: 17,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              language.name,
                                              style: TextStyle(
                                                color: _primaryText(context),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          _SelectionCircle(
                                            selected: selected,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: 165,
                        child: PrimaryButton(
                          text: 'Continue',
                          onPressed: saveLanguage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.name,
    required this.flagCode,
  });

  final String name;
  final String flagCode;
}

class _LanguageHeader extends StatelessWidget {
  const _LanguageHeader({
    required this.onBack,
    required this.onDone,
  });

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: _cardBackground(context),
                shape: const CircleBorder(),
              ),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _primaryText(context),
                size: 17,
              ),
            ),
            Expanded(
              child: Text(
                'Select Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onDone,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? AppColors.primaryBlue
              : _isDark(context)
                  ? const Color(0xFF52606B)
                  : const Color(0xFFD8DCE2),
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 15,
            )
          : null,
    );
  }
}
