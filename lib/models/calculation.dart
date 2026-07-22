class CalculationInput {
  double temp;
  double humidity;
  double? pressure;
  double? rarefaction;
  double? airSpeed;
  String channelShape;
  double? channelWidth;
  double? channelHeight;
  double? channelDiameter;
  double roomLength;
  double roomWidth;
  double roomHeight;

  CalculationInput({
    this.temp = 21.0,
    this.humidity = 50.0,
    this.pressure,
    this.rarefaction,
    this.airSpeed,
    this.channelShape = 'rectangular',
    this.channelWidth = 15.0,
    this.channelHeight = 15.0,
    this.channelDiameter = 15.0,
    this.roomLength = 4.5,
    this.roomWidth = 6.0,
    this.roomHeight = 2.7,
  });
}

class CalculationResult {
  final double temp;
  final double humidity;
  final double? pressure;
  final double rarefaction;
  final String rarefactionNorm;
  final double airSpeed;
  final String channelShape;
  final String channelDescription;
  final double? channelWidth;
  final double? channelHeight;
  final double? channelDiameter;
  final double channelArea;
  final double L;
  final double roomLength;
  final double roomWidth;
  final double roomHeight;
  final double roomArea;
  final double Vpom;
  final double n;
  final String ventNorm;

  CalculationResult({
    required this.temp,
    required this.humidity,
    required this.pressure,
    required this.rarefaction,
    required this.rarefactionNorm,
    required this.airSpeed,
    required this.channelShape,
    required this.channelDescription,
    required this.channelWidth,
    required this.channelHeight,
    required this.channelDiameter,
    required this.channelArea,
    required this.L,
    required this.roomLength,
    required this.roomWidth,
    required this.roomHeight,
    required this.roomArea,
    required this.Vpom,
    required this.n,
    required this.ventNorm,
  });
}