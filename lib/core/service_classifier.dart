/// Suggests a service category from the customer's own words.
///
/// This is a simple keyword scorer (English + Roman Urdu), not a diagnosis.
/// It only ever SUGGESTS a category. If it is not sure, it returns null and
/// the app asks the customer to choose.
class ServiceGuess {
  final String categoryId;
  final String categoryName;

  /// 'Urgent', 'Emergency', or null when nothing special was detected.
  final String? urgency;

  const ServiceGuess({
    required this.categoryId,
    required this.categoryName,
    this.urgency,
  });
}

class ServiceClassifier {
  ServiceClassifier._();

  // categoryId -> (display name, keywords)
  // Single words must match a whole word. Phrases (with a space) match anywhere.
  static const Map<String, (String, List<String>)> _categories = {
    'plumbing': (
      'Plumbing',
      [
        'nal', 'nalka', 'tap', 'pipe', 'pipes', 'leak', 'leaks', 'leaking',
        'leakage', 'tanki', 'tank', 'water', 'paani', 'pani', 'drain',
        'drainage', 'sink', 'basin', 'toilet', 'commode', 'flush',
        'bathroom', 'washroom', 'sewerage', 'gutter', 'blocked', 'choke',
        'geyser', 'plumber', 'tonti',
      ],
    ),
    'electrical': (
      'Electrical',
      [
        'bijli', 'light', 'lights', 'bulb', 'switch', 'socket', 'wiring',
        'wire', 'wires', 'fan', 'spark', 'sparking', 'sparks', 'short',
        'circuit', 'current', 'meter', 'breaker', 'mcb', 'electric',
        'electrical', 'electrician', 'ups', 'inverter', 'tripping',
      ],
    ),
    'ac_repair': (
      'AC Repair',
      [
        'ac', 'a/c', 'conditioner', 'cooling', 'thanda', 'thandak',
        'compressor', 'split', 'air conditioner', 'gas filling',
      ],
    ),
    'carpentry': (
      'Carpentry',
      [
        'wood', 'wooden', 'door', 'doors', 'darwaza', 'darwaze', 'window',
        'khirki', 'cupboard', 'almari', 'wardrobe', 'furniture', 'table',
        'chair', 'bed', 'drawer', 'carpenter', 'lakri', 'shelf', 'hinge',
      ],
    ),
    'painting': (
      'Painting',
      [
        'paint', 'painting', 'painter', 'rang', 'colour', 'color', 'wall',
        'walls', 'deewar', 'whitewash', 'distemper', 'putty', 'roller',
      ],
    ),
    'cleaning': (
      'Cleaning',
      [
        'clean', 'cleaning', 'cleaner', 'safai', 'dust', 'mop', 'carpet',
        'sofa', 'maid', 'jhadu', 'sweep', 'deep clean', 'dirty',
      ],
    ),
    'locksmith': (
      'Locksmith',
      [
        'lock', 'locked', 'key', 'keys', 'chabi', 'chaabi', 'taala', 'tala',
        'latch', 'locksmith', 'duplicate key', 'safe', 'door lock',
      ],
    ),
    'appliance': (
      'Appliance',
      [
        'washing machine', 'machine', 'fridge', 'refrigerator', 'freezer',
        'oven', 'microwave', 'dryer', 'dishwasher', 'iron', 'blender',
        'stove', 'chulha', 'cooker', 'appliance',
      ],
    ),
    'mobile_repair': (
      'Mobile Repair',
      [
        'mobile', 'phone', 'screen', 'display', 'battery', 'charging',
        'charger', 'touch', 'iphone', 'samsung', 'cracked', 'smartphone',
      ],
    ),
    'tutor': (
      'Tutor',
      [
        'tutor', 'tuition', 'teach', 'teacher', 'homework', 'math', 'maths',
        'physics', 'chemistry', 'english', 'exam', 'matric', 'olevel',
        'alevel', 'quran', 'lesson',
      ],
    ),
    'mason': (
      'Masonry',
      [
        'mason', 'mistri', 'brick', 'bricks', 'cement', 'plaster', 'tiles',
        'tile', 'floor', 'concrete', 'construction', 'renovation', 'seepage',
        'crack', 'cracks', 'roof',
      ],
    ),
  };

  static const List<String> _emergencyWords = [
    'emergency', 'flood', 'flooding', 'fire', 'sparking', 'short circuit',
    'gas leak', 'locked out', 'burning', 'shock',
  ];

  static const List<String> _urgentWords = [
    'urgent', 'urgently', 'jaldi', 'fori', 'foran', 'abhi', 'asap',
    'immediately', 'today',
  ];

  static ServiceGuess? classify(String input) {
    final text = input.toLowerCase().trim();
    if (text.length < 4) return null;

    final words = RegExp(r'[a-z0-9/]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toSet();

    String? bestId;
    int bestScore = 0;
    int secondScore = 0;

    _categories.forEach((id, entry) {
      var score = 0;
      for (final keyword in entry.$2) {
        final hit = keyword.contains(' ')
            ? text.contains(keyword)
            : words.contains(keyword);
        if (hit) score++;
      }
      if (score > bestScore) {
        secondScore = bestScore;
        bestScore = score;
        bestId = id;
      } else if (score > secondScore) {
        secondScore = score;
      }
    });

    // Not sure: nothing matched, or two categories are tied.
    if (bestId == null || bestScore == 0 || bestScore == secondScore) {
      return null;
    }

    String? urgency;
    if (_emergencyWords.any(text.contains)) {
      urgency = 'Emergency';
    } else if (_urgentWords.any(words.contains)) {
      urgency = 'Urgent';
    }

    return ServiceGuess(
      categoryId: bestId!,
      categoryName: _categories[bestId!]!.$1,
      urgency: urgency,
    );
  }
}
