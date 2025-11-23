import 'package:flutter/material.dart';

class FasilitasIcon {
  static IconData get(int fasilitasId) {
    switch (fasilitasId) {
      case 1: 
        return Icons.checkroom;
      case 2: 
        return Icons.wc;
      case 3: 
        return Icons.restaurant;
      case 4: 
        return Icons.local_parking;
      case 5: 
        return Icons.chair;
      case 6:
        return Icons.wifi;
      case 7: 
        return Icons.shower;
      case 8: 
        return Icons.mosque;
      case 9: 
        return Icons.smoking_rooms;
      case 10: 
        return Icons.restaurant_menu;
      case 11: 
        return Icons.add_road;
      default:
        return Icons.help_outline;
    }
  }
}
