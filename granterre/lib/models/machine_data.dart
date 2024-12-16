class MachineData {
  final int index;
  final double startTime;
  final double stopTime;
  final String ordineDiLavoro;
  final String lotto;
  final String codiceProdotto;
  final int codiceRicettaUtilizzata;
  final int numeroConfezioni;
  final int velocitaMedia;
  final String centroLavoro;
  final int status;
  final String lottoRichiesto;
  final String codiceProdottoRichiesto;
  final int codiceRicettaRichiesta;

  MachineData({
    required this.index,
    required this.startTime,
    required this.stopTime,
    required this.ordineDiLavoro,
    required this.lotto,
    required this.codiceProdotto,
    required this.codiceRicettaUtilizzata,
    required this.numeroConfezioni,
    required this.velocitaMedia,
    required this.centroLavoro,
    required this.status,
    required this.lottoRichiesto,
    required this.codiceProdottoRichiesto,
    required this.codiceRicettaRichiesta,
  });

  factory MachineData.fromJson(Map<String, dynamic> json) {
    return MachineData(
      index: json['index'] ?? -1,
      startTime: (json['StartTime'] as num?)?.toDouble() ?? 0.0,
      stopTime: (json['StopTime'] as num?)?.toDouble() ?? 0.0,
      ordineDiLavoro: json['OrdineDiLavoro'] ?? '',
      lotto: json['Lotto'] ?? '',
      codiceProdotto: json['CodiceProdotto'] ?? '',
      codiceRicettaUtilizzata: json['CodiceRicettaUtilizzata'] ?? -1,
      numeroConfezioni: json['NumeroConfezioni'] ?? -1,
      velocitaMedia: json['VelocitaMedia'] ?? -1,
      centroLavoro: json['CentroLavoro'] ?? 'Nessun centro di lavoro',
      status: json['Status'] ?? -1,
      lottoRichiesto: json['LottoRichiesto'] ?? '',
      codiceProdottoRichiesto: json['CodiceProdottoRichiesto'] ?? '',
      codiceRicettaRichiesta: json['CodiceRicettaRichiesta'] ?? -1,
    );
  }
}