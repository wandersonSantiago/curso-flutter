import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=9e0a354b";

void main() async {

  runApp(MaterialApp(home: Home(),
  theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;
  String nameBolsa , locationBolsa, nameNASDAQ, locationNASDAQ ;
  double pointsBolsa, variationBolsa,  pointsNASDAQ, variationNASDAQ;

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0),
                  textAlign: TextAlign.center,) ,
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar dados :(",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0),
                    textAlign: TextAlign.center,) ,
                );
              }else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                nameBolsa = snapshot.data["results"]["stocks"]["IBOVESPA"]["name"];
                locationBolsa = snapshot.data["results"]["stocks"]["IBOVESPA"]["location"];
                pointsBolsa = snapshot.data["results"]["stocks"]["IBOVESPA"]["points"];
                variationBolsa = snapshot.data["results"]["stocks"]["IBOVESPA"]["variation"];

                nameNASDAQ= snapshot.data["results"]["stocks"]["NASDAQ"]["name"];
                locationNASDAQ = snapshot.data["results"]["stocks"]["NASDAQ"]["location"];
                pointsNASDAQ = snapshot.data["results"]["stocks"]["NASDAQ"]["points"];
                variationNASDAQ= snapshot.data["results"]["stocks"]["NASDAQ"]["variation"];


                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                      Divider(),
                      buildTextDolar(
                          snapshot.data["results"]["currencies"]["USD"]["name"],
                          snapshot.data["results"]["currencies"]["USD"]["buy"],
                          snapshot.data["results"]["currencies"]["USD"]["sell"],
                          snapshot.data["results"]["currencies"]["USD"]["variation"]),
                      buildTextDolar(
                          snapshot.data["results"]["currencies"]["EUR"]["name"] + "  ",
                          snapshot.data["results"]["currencies"]["EUR"]["buy"],
                          snapshot.data["results"]["currencies"]["EUR"]["sell"],
                          snapshot.data["results"]["currencies"]["EUR"]["variation"]),
                      Divider(),
                      buildTextTitle(),
                      Divider(),
                      buildTextValues(nameBolsa, locationBolsa, pointsBolsa, variationBolsa ),
                      Divider(),
                      buildTextValues(nameNASDAQ, locationNASDAQ, pointsNASDAQ, variationNASDAQ ),
                    ],
                  ),
                );
              }
          }
        })
    );
  }
}


Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextValues(String name, String location, double points, double variation){

  return  Column(
    crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
                color: Colors.white, fontSize: 15.0
            ),
          ),
          Text(
             location,
            style: TextStyle(
                color: Colors.white, fontSize: 12.0
            ),
          ),

      Text(
        points.toStringAsPrecision(7),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 25.0
        ),
      ),
      Text(
        variation.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.red, fontSize: 25.0
        ),
      )
    ],
  );
}

Widget buildTextTitle(){

  return  Column(
    children: <Widget>[
    Text(
    "Bolsa de Valores" ,
    textAlign: TextAlign.center,
    style: TextStyle(
        color: Colors.white, fontSize: 25.0
    ),
  )
    ],
  );
}

Widget buildTextDolar(String name, double buy, double sell, double variation){

  return  Row(
    children: <Widget>[
      Text(
       name + " :  ",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 12.0
        ),
      ),
      Text(
       "   Compra : R\$: " +  buy.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 10.0
        ),
      ),
      Text(
       "  Venda :  R\$: " + sell.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 10.0
        ),
      ),
      Text(
        "  Variação :" + variation.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 10.0
        ),
      )
    ],
  );
}

Widget buildTextField(String label, String prefix, TextEditingController ctrl, Function function){
  return  TextField(
    controller: ctrl,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

