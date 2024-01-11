import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo for country picker package',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: [
        const Locale('en'),
        const Locale('ar'),
        const Locale('es'),
        const Locale('de'),
        const Locale('fr'),
        const Locale('el'),
        const Locale('et'),
        const Locale('nb'),
        const Locale('nn'),
        const Locale('pl'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('hi'),
        const Locale('ne'),
        const Locale('uk'),
        const Locale('hr'),
        const Locale('tr'),
        const Locale('lv'),
        const Locale('lt'),
        const Locale('ku'),
        const Locale('nl'),
        const Locale('it'),
        const Locale('ko'),
        const Locale('ja'),
        const Locale('id'),
        const Locale('cs'),
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
        const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant'), // Generic traditional Chinese 'zh_Hant'
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo for country picker')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showCountryPicker(
              context: context,
              //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
              exclude: <String>['KN', 'MF'],
              favorite: <String>['SE'],
              //Optional. Shows phone code before the country name.
              showPhoneCode: true,
              onSelect: (Country country) {
                print('Select country: ${country.toJson()}');
              },
              title: Text("This is title"),
              // Optional. Sets the theme for the country list picker.
              intialSearchWidget: Container(
                padding: const EdgeInsets.fromLTRB(
                  40.0,
                  24.0,
                  40.0,
                  0.0,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.public,
                      size: 80.0,
                      color: Colors.blue[50],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "Search for your country to select the country code.",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            height: 1.42,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              searchNotFoundWidget: Container(
                padding: const EdgeInsets.fromLTRB(
                  40.0,
                  24.0,
                  40.0,
                  0.0,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.public,
                      size: 80.0,
                      color: Colors.blue[50],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "No results found",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            height: 1.42,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              countryListTheme: CountryListThemeData(
                bottomSheetHeight: 600,
                // Optional. Sets the border radius for the bottomsheet.
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                // Optional. Styles the search field.

                padding: const EdgeInsets.fromLTRB(
                  8.0,
                  16.0,
                  8.0,
                  8.0,
                ),
                margin: EdgeInsets.zero,
                backgroundColor: Colors.white,
                inputDecoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Start typing to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8C98A8).withOpacity(0.2),
                    ),
                  ),
                ),
                // Optional. Styles the text in the search field
                searchTextStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            );
          },
          child: const Text('Show country picker'),
        ),
      ),
    );
  }
}
