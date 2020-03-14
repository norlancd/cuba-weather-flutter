import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuba_weather_dart/cuba_weather_dart.dart';

import 'package:cuba_weather/src/utils/utils.dart';

class ForecastPage extends StatefulWidget {
  final String forecastType;
  final String pageTitle;

  ForecastPage({
    Key key,
    @required this.forecastType,
    @required this.pageTitle,
  })  : assert(forecastType != null),
        super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  InsmetForecastModel _forecast;
  var client = Client();
  bool showImage = false;
  bool error = false;
  String errorMessage;

  Future<bool> recoverValueShowImage() async {
    var prefs = await SharedPreferences.getInstance();
    var value = prefs.getBool(Constants.showImageForecastPage) ?? false;
    this.showImage = value;
    return value;
  }

  Future<void> setValueShowImage(bool newValue) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.showImageForecastPage, newValue);
    this.showImage = newValue;
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Provider.of<AppStateNotifier>(context).isDarkModeOn;
    recoverValueShowImage();
    if (_forecast == null && !error) {
      switch (widget.forecastType) {
        case 'today':
          CubaWeather().getInsmetTodayForecast().then((onValue) {
            setState(() {
              _forecast = onValue;
            });
          }).catchError((onError) {
            setState(() {
              if (onError is BadRequestException) {
                errorMessage = Constants.errorMessageBadRequestException;
                error = true;
              } else {
                errorMessage = onError.toString();
                error = true;
              }
            });
          });
          break;
        case 'tomorrow':
          CubaWeather().getInsmetTomorrowForecast().then((onValue) {
            setState(() {
              _forecast = onValue;
            });
          }).catchError((onError) {
            setState(() {
              if (onError is BadRequestException) {
                errorMessage = Constants.errorMessageBadRequestException;
                error = true;
              } else if (onError is ParseException) {
                errorMessage = Constants.errorMessageParseException;
                error = true;
              } else {
                errorMessage = onError.toString();
                error = true;
              }
            });
          });
          break;
        case 'perspectives':
          CubaWeather().getInsmetPerspectiveForecast().then((onValue) {
            setState(() {
              _forecast = onValue;
            });
          }).catchError((onError) {
            setState(() {
              if (onError is BadRequestException) {
                errorMessage = Constants.errorMessageBadRequestException;
                error = true;
              } else if (onError is ParseException) {
                errorMessage = Constants.errorMessageParseException;
                error = true;
              } else {
                errorMessage = onError.toString();
                error = true;
              }
            });
          });
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pageTitle,
        ),
      ),
      body: error
          ? ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: Icon(
                    Icons.error_outline,
                    color: darkMode ? Colors.white : Colors.blue,
                    size: 150,
                  ),
                ),
                Text(
                  Constants.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: darkMode ? Colors.white : Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _forecast == null
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _forecast.centerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                                Text(
                                  _forecast.forecastName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                                Text(
                                  _forecast.forecastDate,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                ),
                                Divider(),
                                _forecast.forecastTitle != ""
                                    ? SizedBox(height: 5.0)
                                    : Container(),
                                _forecast.forecastTitle != ""
                                    ? Text(
                                        _forecast.forecastTitle,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Container(),
                                _forecast.forecastTitle != ""
                                    ? SizedBox(height: 8.0)
                                    : Container(),
                                Text(
                                  _forecast.forecastText,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Text(
                                  'Autores',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ),
                              ),
                              Card(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: _buildAuthors(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'Fuente: ${_forecast.dataSource}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _forecast.imageUrl != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text('Mostrar imagen',
                                      style: TextStyle(
                                        color: darkMode
                                            ? Colors.white
                                            : Colors.blue,
                                      )),
                                  Switch(
                                    value: showImage,
                                    onChanged: (value) {
                                      setState(() {
                                        setValueShowImage(value);
                                      });
                                    },
                                    activeTrackColor: darkMode
                                        ? Colors.white
                                        : Colors.lightBlueAccent,
                                    activeColor:
                                        darkMode ? Colors.white : Colors.blue,
                                  ),
                                ],
                              )
                            : Container(),
                        _forecast.imageUrl != null
                            ? showImage
                                ? FadeInImage.assetNetwork(
                                    placeholder: Constants.loadingPlaceholder,
                                    image: _forecast.imageUrl,
                                  )
                                : Container()
                            : Container()
                      ],
                    ),
                  ),
                ),
    );
  }

  List<Widget> _buildAuthors() {
    var darkMode = Provider.of<AppStateNotifier>(context).isDarkModeOn;
    return _forecast.authors[0] != ""
        ? [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _forecast.authors[0] != ""
                      ? CircleAvatar(
                          backgroundImage:
                              meteorologistImg(_forecast.authors[0]) != null
                                  ? NetworkImage(
                                      meteorologistImg(_forecast.authors[0]))
                                  : ExactAssetImage(Constants
                                      .authorsPlaceHolderImageAssetURL),
                          radius: 30.0,
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _forecast.authors[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkMode ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: meteorologistImg(_forecast.authors[1]) !=
                            null
                        ? NetworkImage(meteorologistImg(_forecast.authors[1]))
                        : ExactAssetImage(
                            Constants.authorsPlaceHolderImageAssetURL),
                    radius: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _forecast.authors[1],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkMode ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        : [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: meteorologistImg(_forecast.authors[1]) !=
                            null
                        ? NetworkImage(meteorologistImg(_forecast.authors[1]))
                        : ExactAssetImage(
                            Constants.authorsPlaceHolderImageAssetURL),
                    radius: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _forecast.authors[1],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
  }

  String meteorologistImg(String name) {
    name = name.replaceAll(' ', '');
    name = name.replaceAll('.', '');
    String url = Constants.insmetUrlAuthorsImg;
    switch (name) {
      case 'AVarela':
        return url + 'A.Varela.jpg';
        break;
      case 'YBermúdez':
        return url + 'Yinelis.jpg';
        break;
      case 'MAHernández':
        return url + 'MAHernandez.jpg';
        break;
      case 'MAHernandez':
        return url + 'MAHernandez.jpg';
        break;
      case 'AJustiz':
        return url + 'A.Justiz.jpg';
        break;
      case 'YArias':
        return url + 'Y.Arias.jpg';
        break;
      case 'JRubiera':
        return url + 'JRubiera.jpg';
        break;
      case 'GAcosta':
        return url + 'G.Acosta.jpg';
        break;
      case 'ACaymares':
        return url + 'ACaymares.jpg';
        break;
      case 'ASanchez':
        return url + 'ASanchez.jpg';
        break;
      case 'ALima':
        return url + 'ALima.jpg';
        break;
      case 'JASerrano':
        return url + 'JASerrano.jpg';
        break;
      case 'GAguilar':
        return url + 'GAguilar.jpg';
        break;
      case 'NFournier':
        return url + 'NFournier.jpg';
        break;
      case 'JGonzález':
        return url + 'JGonzález.jpg';
        break;
      case 'Amengana':
        return url + 'Amengana.jpg';
        break;
      case 'Miri':
        return url + 'Miri.jpg';
        break;
      case 'Yinelis':
        return url + 'Yinelis.jpg';
        break;
      case 'GEstevez':
        return url + 'GEstevez.jpg';
        break;
      case 'YCedeno':
        return url + 'YCedeno.jpg';
        break;
      case 'JPalacios':
        return url + 'JPalacios.jpg';
        break;
      case 'AEspinosa':
        return url + 'A.Espinosa.jpg';
        break;
      case 'YMartinez':
        return url + 'Y.Martinez.jpg';
        break;
      case 'EVázquez':
        return url + 'E. Vázquez.JPG';
        break;
      case 'AOtero':
        return url + 'A.Otero.jpg';
        break;
      case 'AMiro':
        return url + 'A.Miro.jpg';
        break;
      case 'AWong':
        return url + 'A.Wong.jpg';
        break;
      default:
        return null;
    }
  }
}
