import 'package:flutter/material.dart';
import 'package:granterre/components/description.dart';
import 'package:granterre/components/header.dart';
import 'package:granterre/components/title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    
    return const SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppTitle(text: "Home"),
              SizedBox(height: 20),
              AppHeader(
                text: 'Progetto: Analisi dati Industria 4.0',
                big: true,
              ),
              SizedBox(height: 10),
              AppDescription(
                text: "Il nostro obiettivo è sviluppare un sistema innovativo e altamente efficiente per monitorare e visualizzare i dati provenienti da una serie di macchinari all'interno di un impianto industriale. L'intento è fornire una soluzione che permetta di raccogliere informazioni in tempo reale su vari parametri operativi, come la produzione, il consumo energetico, e le performance delle macchine. Grazie a questa piattaforma, l'azienda potra ottimizzare i processi, migliorare la manutenzione predittiva e prendere decisioni piu informate per ridurre i costi e aumentare l'affidabilita dell'impianto.",
              ),
              SizedBox(height: 20),
              AppHeader(
                text: 'Passaggi principali:',
                big: false,
              ),
              SizedBox(height: 10),
              AppDescription(
                text: '1. Acquisizione dati: Leggeremo i file di log dei macchinari (lettura/scrittura) tramite un client, che invierà i dati a una cloud function a intervalli regolari. I dati saranno poi salvati su un database Firestore.',
              ),
              SizedBox(height: 10),
              AppDescription(
                text: '2. Dashboard: Una seconda cloud function interroga il database Firestore e genera una dashboard. La dashboard consente di selezionare un macchinario e un intervallo temporale, mostrando i dati in un grafico integrato.',
              ),
              SizedBox(height: 20),
              AppDescription(
                text: 'Proseguite pure nelle pagine successive',
                italic: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}  