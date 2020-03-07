import 'dart:developer';
import 'dart:io';

import 'package:cuba_weather/src/utils/constants.dart';
import 'package:flutter/services.dart';

import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:cuba_weather_dart/cuba_weather_dart.dart';
import 'package:cuba_weather_municipality_dart/cuba_weather_municipality_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuba_weather/src/blocs/blocs.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final CubaWeather api;

  WeatherBloc({@required this.api}) : assert(api != null);

  @override
  WeatherState get initialState => WeatherEmpty();

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is FetchWeather) {
      yield WeatherLoading();
      try {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.municipality, event.municipality);
      } catch (e) {
        log(e.toString());
      }
      try {
        final weather = await api.get(event.municipality);
        yield WeatherLoaded(weather: weather);
      } on SocketException catch (e) {
        log(e.toString());
        yield WeatherError(
          errorMessage: 'No se ha podido establecer conexión con la red '
              'nacional. Por favor, revise su conexión y vuelva a intentarlo.',
        );
      } catch (e) {
        log(e.toString());
        yield WeatherError(errorMessage: e.toString());
      }
    }
    if (event is RefreshWeather) {
      try {
        final weather = await api.get(event.municipality);
        yield WeatherLoaded(weather: weather);
      } on SocketException catch (e) {
        log(e.toString());
        yield WeatherError(
          errorMessage: 'No se ha podido establecer conexión con la red '
              'nacional. Por favor, revise su conexión y vuelva a intentarlo.',
        );
      } catch (e) {
        log(e.toString());
        yield WeatherError(errorMessage: e.toString());
      }
    }
    if (event is FindLocationWeather) {
      yield WeatherFindingLocation();
      try {
        var locator = Geolocator();
        var enabled = await locator.isLocationServiceEnabled();
        if (!enabled) {
          yield WeatherError(
            errorMessage: 'El servicio de localización '
                'del dispositivo se encuentra desactivado.\n\nPor favor '
                'cierre la aplicación, active el servicio y vuelva a '
                'intentarlo.',
          );
          return;
        }
        Position position;
        try {
          position = await locator
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
              .timeout(Duration(seconds: 30));
        } on PlatformException catch (e) {
          if (e.code == 'PERMISSION_DENIED') {
            yield WeatherError(
              errorMessage: 'Ha denegado el permiso a la aplicación para '
                  'obtener la localización del dispositivo.\n\n'
                  'Si desea que la aplicación obtenga la información '
                  'del municipio en que se encuentra debe darle el permiso '
                  'de Ubicación a la aplicación.',
            );
            return;
          } else {
            yield WeatherError(
              errorMessage: 'Ha ocurrido un error durante la obtención de la '
                  'localización. Puede ser porque apagó el servicio de '
                  'localización, entró en una zona de mala cobertura, etc.\n\n'
                  'Por favor cierre la aplicación, active el servicio y '
                  'vuelva a intentarlo.',
            );
            return;
          }
        } catch (e) {
          yield WeatherError(
            errorMessage: 'Ha ocurrido un error durante la obtención de la '
                'localización. Puede ser porque apagó el servicio de '
                'localización, entró en una zona de mala cobertura, etc.\n\n'
                'Por favor cierre la aplicación, active el servicio y '
                'vuelva a intentarlo.',
          );
          return;
        }
        var bestMunicipality = municipalities[0];
        var bestDistance = await locator.distanceBetween(
          position.latitude,
          position.longitude,
          bestMunicipality.lat,
          bestMunicipality.lon,
        );
        for (var i = 1; i < municipalities.length; ++i) {
          var actualMunicipality = municipalities[i];
          var actualDistance = await locator.distanceBetween(
            position.latitude,
            position.longitude,
            actualMunicipality.lat,
            actualMunicipality.lon,
          );
          if (actualDistance < bestDistance) {
            bestDistance = actualDistance;
            bestMunicipality = actualMunicipality;
          }
        }
        try {
          var prefs = await SharedPreferences.getInstance();
          await prefs.setString(Constants.municipality, bestMunicipality.name);
        } catch (e) {
          log(e.toString());
        }
        final weather = await api.get(bestMunicipality.name);
        yield WeatherLoaded(weather: weather);
      } catch (e) {
        log(e.toString());
        yield WeatherError(errorMessage: e.toString());
      }
    }
  }
}
