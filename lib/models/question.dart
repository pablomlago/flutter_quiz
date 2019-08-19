import 'package:flutter/material.dart';

class Question {
  final String question;
  final List<String> options;
  final double winnersPercentage;

  Question(this.question, this.options, this.winnersPercentage);

  String get difficulty {
    if(winnersPercentage >= 0 && winnersPercentage < 25) {
      return 'Extrema';
    } else if(winnersPercentage >= 25 && winnersPercentage < 50) {
      return 'Dificil';
    } else if(winnersPercentage >= 50 && winnersPercentage < 75) {
      return 'Media';
    } else if(winnersPercentage >= 75 && winnersPercentage <= 100) {
      return 'Facil';
    } else {
      return '...';
    }
  }

  Color get difficultyColor {
    if(winnersPercentage >= 0 && winnersPercentage < 25) {
      return Colors.red;
    } else if(winnersPercentage >= 25 && winnersPercentage < 50) {
      return Colors.orange;
    } else if(winnersPercentage >= 50 && winnersPercentage < 75) {
      return Colors.yellow;
    } else if(winnersPercentage >= 75 && winnersPercentage <= 100) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  int get experiencePoints {
    return 100 - winnersPercentage.round();
  }
}