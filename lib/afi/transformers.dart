class TransformerPreprocessor {
  final Map<String, String> rawTransformers;
  Map<String, List<Segment>> preprocessed;
  static final RegExp _exp = RegExp(r'{([^}]*)}');

  TransformerPreprocessor(this.rawTransformers)
      : preprocessed = _preprocess(rawTransformers);

  void update(String key, String? newValue) {
    if (newValue == null || newValue.isEmpty) {
      preprocessed.remove(key);
    } else {
      preprocessed[key] = _preprocess({key: newValue})[key]!;
    }
  }

  static Map<String, List<Segment>> _preprocess(
      Map<String, String> transformers) {
    final result = <String, List<Segment>>{};
    for (var entry in transformers.entries) {
      String transform = entry.value;

      if (transform.isEmpty) {
        result[entry.key] = [];
        continue;
      }

      if (transform.startsWith('{') && transform.endsWith('}')) {
        result[entry.key] = [
          Segment(true, transform.substring(1, transform.length - 1))
        ];
        continue;
      }

      if (transform.contains('|') && !_exp.hasMatch(transform)) {
        result[entry.key] =
            transform.split('|').map((s) => Segment(true, s.trim())).toList();
        continue;
      }

      List<Segment> segments = [];
      int lastEnd = 0;
      for (var match in _exp.allMatches(transform)) {
        if (match.start > lastEnd) {
          segments
              .add(Segment(false, transform.substring(lastEnd, match.start)));
        }
        segments.add(Segment(true, match.group(1)!));
        lastEnd = match.end;
      }
      if (lastEnd < transform.length) {
        segments.add(Segment(false, transform.substring(lastEnd)));
      }
      result[entry.key] =
          segments.isEmpty ? [Segment(false, transform)] : segments;
    }
    return result;
  }
}

class Segment {
  final bool isExpression;
  final String value;

  Segment(this.isExpression, this.value);
}

class Transformer {
  final Map<String, dynamic> original;
  final Map<String, List<Segment>> preprocessed;

  static final Map<String, Function> methods = {
    'greet': () => 'Hello from static method',
    'double': (int x) => x * 2,
    'concat': (dynamic a, dynamic b) => '$a$b',
  };

  Transformer(this.original, this.preprocessed);

  Map<String, dynamic> digest() {
    final result = <String, dynamic>{};
    for (var entry in preprocessed.entries) {
      if (entry.value.isEmpty) {
        if (original.containsKey(entry.key)) {
          result[entry.key] = original[entry.key];
        }
        continue;
      }
      var transformed = _transform(entry.value);
      if (transformed != null) {
        result[entry.key] = transformed;
      }
    }
    return result;
  }

  dynamic _transform(List<Segment> segments) {
    if (segments.length == 1 && !segments[0].isExpression) {
      var val = segments[0].value;
      return num.tryParse(val) ?? val;
    }

    if (segments.every((s) => s.isExpression)) {
      if (segments.length == 1) {
        return _evaluate(segments[0].value);
      }
      for (var segment in segments) {
        var value = _evaluate(segment.value);
        if (value != null) return value;
      }
      return null;
    }

    String result = '';
    for (var segment in segments) {
      var value =
          segment.isExpression ? _evaluate(segment.value) : segment.value;
      if (value != null) {
        result += value.toString();
      }
    }
    return result.isEmpty ? null : result;
  }

  dynamic _evaluate(String expr) {
    if (expr.isEmpty) return original;

    if (expr.contains('|')) {
      var options = expr.split('|').map((s) => s.trim()).toList();
      for (var opt in options) {
        var value = _evaluateSingle(opt);
        if (value != null) return value;
      }
      return null;
    }

    return _evaluateSingle(expr);
  }

  dynamic _evaluateSingle(String expr) {
    // New feature: Handle {$} to embed all of original map
    if (expr == r'$') {
      return original;
    }

    if (expr.endsWith(')')) {
      var parts = expr.split('(');
      if (parts.length == 2 && parts[1].endsWith(')')) {
        var methodName = parts[0].trim();
        var argsStr = parts[1].substring(0, parts[1].length - 1).trim();
        if (methods.containsKey(methodName)) {
          var method = methods[methodName]!;
          if (argsStr.isEmpty) {
            return method();
          }
          var args =
              argsStr.split(',').map((s) => _evaluateSingle(s.trim())).toList();
          if (args.any((arg) => arg == null)) return null;
          if (args.length == 1) return method(args[0]);
          if (args.length == 2) return method(args[0], args[1]);
          return null;
        }
      }
      return null;
    }

    var value = _getValue(expr);
    if (value != null) return value;
    return _arithmetic(expr);
  }

  dynamic _getValue(String path) {
    var parts = path.split('.');
    dynamic current = original;
    for (var part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else if (current is List && RegExp(r'^\d+$').hasMatch(part)) {
        int i = int.parse(part);
        if (i >= 0 && i < current.length) {
          current = current[i];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }

  num? _arithmetic(String expr) {
    try {
      var terms = expr.split(RegExp(r'\s*\+\s*'));
      if (terms.length > 1) {
        num sum = 0;
        for (var term in terms) {
          term = term.trim();
          var val = _getValue(term) ?? num.tryParse(term);
          if (val is num) {
            sum += val;
          } else {
            return null;
          }
        }
        return sum;
      }
      terms = expr.split(RegExp(r'\s*-\s*'));
      if (terms.length > 1) {
        var first = _getValue(terms[0]) ?? num.tryParse(terms[0]);
        if (first == null || first is! num) return null;
        num result = first;
        for (var term in terms.skip(1)) {
          term = term.trim();
          var sub = _getValue(term) ?? num.tryParse(term);
          if (sub is num) {
            result -= sub;
          } else {
            return null;
          }
        }
        return result;
      }
      return num.tryParse(expr);
    } catch (e) {
      return null;
    }
  }
}
