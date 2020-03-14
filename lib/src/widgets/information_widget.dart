import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:getflutter/components/button/gf_button.dart';
import 'package:getflutter/getflutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cuba_weather/src/utils/utils.dart';
import 'package:cuba_weather/src/widgets/widgets.dart';

class InformationWidget extends StatefulWidget {
  const InformationWidget();

  @override
  State<StatefulWidget> createState() => InformationWidgetState();
}

class InformationWidgetState extends State<InformationWidget> {
  String appName = '';
  String version = '';

  InformationWidgetState() {
    start();
  }

  void start() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Provider.of<AppStateNotifier>(context).isDarkModeOn;
    return Scaffold(
      appBar: AppBar(
        title: Text('Información'),
      ),
      body: GradientContainerWidget(
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      '$appName',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$version',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      Constants.appLogo,
                      width: 180,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'Está aplicación obtiene datos de las siguientes fuentes:\n\n'
                    '1. Buscador cubano RedCuba (https://www.redcuba.cu)\n'
                    '2. Sitio web del Instituto de Meteorología '
                    '(http://www.insmet.cu)\n\n'
                    'Debido a que todas las fuentes son nacionales solo es '
                    'necesario conexión a la red nacional (utiliza el bono '
                    'nacional de 300 mb).\n\n'
                    'Los desarrolladores son personas independientes sin '
                    'ánimo de lucro.\n\n'
                    'Para situaciones de tiempo peligrosas consultar las '
                    'fuentes oficiales de información.',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Center(
                    child: Text(
                      'Para dudas, problemas o sugerencias puede:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: GFButton(
                    text: 'Escribir correo al desarrollador',
                    textColor: Colors.white,
                    color: Colors.white,
                    size: GFSize.large,
                    shape: GFButtonShape.pills,
                    type: GFButtonType.outline2x,
                    fullWidthButton: true,
                    onPressed: () async {
                      const url = 'mailto:leynier41@gmail.com';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        log('Could not launch $url');
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: GFButton(
                    text: 'Visitar repositorio en GitHub',
                    textColor: Colors.white,
                    color: Colors.white,
                    size: GFSize.large,
                    shape: GFButtonShape.pills,
                    type: GFButtonType.outline2x,
                    fullWidthButton: true,
                    onPressed: () async {
                      const url =
                          'https://github.com/cuba-weather/cuba-weather-flutter';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        log('Could not launch $url');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
