import 'package:country_picker/src/extensions.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_localizations.dart';
import 'country_service.dart';
import 'res/country_codes.dart';
import 'utils.dart';

typedef CustomFlagBuilder = Widget Function(Country country);

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// The already selected before opening the bottomsheet.
  final Country? selectedCountry;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// Custom builder function for flag widget
  final CustomFlagBuilder? customFlagBuilder;

  /// BotomSheet title
  final Widget? title;

  /// Search widget when we tap on textfield
  final Widget? intialSearchWidget;

  /// Search widget when we don't get any result
  final Widget? searchNotFoundWidget;

  const CountryListView({
    Key? key,
    required this.onSelect,
    this.selectedCountry,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.searchAutofocus = false,
    this.showWorldWide = false,
    this.showSearch = true,
    this.customFlagBuilder,
    this.title,
    this.intialSearchWidget,
    this.searchNotFoundWidget,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();

  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;
  final _searchFocusNode = FocusNode();

  Country? currentSelectedCountry;

  @override
  void initState() {
    super.initState();
    currentSelectedCountry = widget.selectedCountry;
    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    final String searchLabel =
        CountryLocalizations.of(context)?.countryName(countryCode: 'search') ??
            'Search';

    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: widget.title ?? const SizedBox(),
        ),
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextField(
              focusNode: _searchFocusNode,
              autofocus: _searchAutofocus,
              controller: _searchController,
              style:
                  widget.countryListTheme?.searchTextStyle ?? _defaultTextStyle,
              cursorColor: const Color(0xFF203066),
              cursorRadius: const Radius.circular(4.0),
              decoration: widget.countryListTheme?.inputDecoration ??
                  InputDecoration(
                    labelText: searchLabel,
                    hintText: searchLabel,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF8C98A8).withOpacity(0.2),
                      ),
                    ),
                  ),
              onChanged: _filterSearchResults,
            ),
          ),
        Expanded(
          child: (_searchFocusNode.hasPrimaryFocus &&
                  _searchController.text.isEmpty)
              ? widget.intialSearchWidget ?? const SizedBox()
              : ListView(
                  children: [
                    if (_favoriteList != null &&
                        !_searchFocusNode.hasPrimaryFocus) ...[
                      ..._favoriteList!
                          .map<Widget>((currency) => _listRow(currency))
                          .toList(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              widget.countryListTheme?.padding?.left ?? 0.0,
                          vertical: 12.0,
                        ),
                        child: const DottedLine(dashColor: Color(0xFFD9DFE9)),
                      ),
                    ],
                    if (_searchController.text.isNotEmpty &&
                        _filteredList.isEmpty)
                      widget.searchNotFoundWidget ?? const SizedBox()
                    else
                      ..._filteredList
                          .map<Widget>((country) => _listRow(country))
                          .toList(),
                  ],
                ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ElevatedButton(
            onPressed: () {
              if (currentSelectedCountry != null) {
                widget.onSelect(currentSelectedCountry!);
                Navigator.pop(context);
              }
            },
            style: ButtonStyle(
              elevation: 0.0.wrapMatProp(),
              shape: const StadiumBorder().wrapMatProp(),
              minimumSize: Size(100.w, 56.0).wrapMatProp(),
              maximumSize: Size(100.w, 56.0).wrapMatProp(),
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0)
                  .wrapMatProp(),
              foregroundColor: Colors.white
                  .wrapMatStateColor(disabledColor: const Color(0xFF909090)),
              backgroundColor: const Color(0xFF203066).wrapMatStateColor(
                disabledColor: const Color(0xFFF9F9F9),
              ),
              overlayColor: Colors.black12.wrapMatProp(),
            ),
            child: Text(
              "Save",
              style: widget.countryListTheme?.saveButtonTextStyle ??
                  const TextStyle(
                    height: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    // final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          country.nameLocalized = CountryLocalizations.of(context)
              ?.countryName(countryCode: country.countryCode)
              ?.replaceAll(RegExp(r"\s+"), " ");

          setState(() {
            currentSelectedCountry = country;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: (currentSelectedCountry != null &&
                      currentSelectedCountry?.countryCode ==
                          country.countryCode)
                  ? const Color(0xFF203066)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: <Widget>[
              Row(
                children: [
                  const SizedBox(width: 20),
                  if (widget.customFlagBuilder == null)
                    _flagWidget(country)
                  else
                    widget.customFlagBuilder!(country),
                  const SizedBox(width: 15),
                ],
              ),
              Expanded(
                child: Text(
                  "${CountryLocalizations.of(context)?.countryName(countryCode: country.countryCode)?.replaceAll(RegExp(r"\s+"), " ") ?? country.name} ${(widget.showPhoneCode && !country.iswWorldWide) ? '(${country.phoneCode})' : ''} ",
                  style: _textStyle.copyWith(
                    color: currentSelectedCountry?.countryCode ==
                            country.countryCode
                        ? const Color(0xFF203066)
                        : null,
                  ),
                ),
              ),
              Radio(
                activeColor: const Color(0xFFFF4321),
                value: country.countryCode,
                groupValue: currentSelectedCountry?.countryCode ?? "",
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: _emojiText(country),
    );
  }

  Widget _emojiText(Country country) => Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : Utils.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: widget.countryListTheme?.flagSize ?? 20,
        ),
      );

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => c.startsWith(query, localizations))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
