import 'clothing_item.dart';

/// Defines the valid attribute keys and values for each clothing type.
/// Used in upload form and for display.
class ClothingAttributes {
  static const Map<ClothingType, Map<String, List<String>>> schema = {
    ClothingType.top: {
      'sleeve': ['Short', 'Long', '3/4', 'Sleeveless'],
      'collar': [
        'Crew',
        'V-Neck',
        'Polo',
        'Turtleneck',
        'Button-Up',
        'Hoodie',
      ],
      'fit': ['Regular', 'Slim', 'Oversized', 'Boxy', 'Cropped'],
    },
    ClothingType.bottom: {
      'cut': [
        'Straight',
        'Slim',
        'Wide',
        'Bootcut',
        'Skinny',
        'Relaxed',
        'Flare',
      ],
      'rise': ['Low', 'Mid', 'High'],
      'inseam': ['Short', 'Regular', 'Long'],
    },
    ClothingType.dress: {
      'length': ['Mini', 'Midi', 'Maxi'],
      'sleeve': ['Sleeveless', 'Short', 'Long'],
      'style': ['Casual', 'Formal', 'Cocktail', 'Boho', 'Wrap', 'Shirt'],
    },
    ClothingType.outerwear: {
      'style': [
        'Jacket',
        'Coat',
        'Vest',
        'Hoodie',
        'Blazer',
        'Bomber',
        'Parka',
      ],
      'fill_weight': ['Light', 'Medium', 'Heavy'],
    },
    ClothingType.shoes: {
      'shoe_size': [
        '35',
        '36',
        '37',
        '38',
        '39',
        '40',
        '41',
        '42',
        '43',
        '44',
        '45',
        '46',
      ],
      'style': [
        'Sneakers',
        'Boots',
        'Heels',
        'Flats',
        'Sandals',
        'Loafers',
        'Running',
      ],
    },
    ClothingType.accessory: {
      'style': [
        'Bag',
        'Hat',
        'Belt',
        'Scarf',
        'Jewelry',
        'Sunglasses',
        'Watch',
        'Backpack',
      ],
    },
  };
}
