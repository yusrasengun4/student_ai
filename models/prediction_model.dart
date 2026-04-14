class PredictionModel {
  final double predictedScore;
  final String burnoutRisk;
  final double burnoutConfidence;
  final double productivityScore;
  final double focusIndex;

  const PredictionModel({
    required this.predictedScore,
    required this.burnoutRisk,
    required this.burnoutConfidence,
    required this.productivityScore,
    required this.focusIndex,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) => PredictionModel(
    predictedScore:    (json['predicted_score'] as num).toDouble(),
    burnoutRisk:       json['burnout_risk'],
    burnoutConfidence: (json['burnout_confidence'] as num).toDouble(),
    productivityScore: (json['productivity_score'] as num).toDouble(),
    focusIndex:        (json['focus_index'] as num).toDouble(),
  );
}