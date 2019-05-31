bool alpha(int c) {
  if (c == null) {
    throw ArgumentError.notNull('c');
  }

  if (c >= 65 && c <= 90 || c >= 97 && c <= 122) {
    return true;
  }

  return false;
}

bool alphanum(int c) {
  if (c == null) {
    throw ArgumentError.notNull('c');
  }

  if (c >= 48 && c <= 57 || c >= 65 && c <= 90 || c >= 97 && c <= 122) {
    return true;
  }

  return false;
}

String camelizeIdentifier(String ident) {
  if (ident == null) {
    throw ArgumentError.notNull('ident');
  }

  if (ident.isEmpty) {
    return ident;
  }

  var pos = 0;
  var sb = StringBuffer();
  while (pos < ident.length) {
    var c = ident.codeUnitAt(pos);
    if (c == 95) {
      sb.write('_');
      pos++;
    } else {
      break;
    }
  }

  var needCapitalize = false;
  for (; pos < ident.length; pos++) {
    var c = ident.codeUnitAt(pos);
    var s = ident[pos];
    if (c == 95) {
      if (pos + 1 < ident.length) {
        if (ident.codeUnitAt(pos + 1) == 95) {
          sb.write(s);
        } else {
          needCapitalize = true;
        }
      } else {
        needCapitalize = true;
        if (pos + 1 == ident.length) {
          sb.write(s);
        }
      }
    } else {
      if (needCapitalize) {
        needCapitalize = false;
        sb.write(s.toUpperCase());
      } else {
        sb.write(s);
      }
    }
  }

  return sb.toString();
}

String capitalizeIdentifier(String ident) {
  if (ident == null) {
    throw ArgumentError.notNull('ident');
  }

  if (ident.isEmpty) {
    return ident;
  }

  var prefix = <String>[];
  var rest = ident;
  var pos = 0;
  while (pos < ident.length) {
    var c = ident.codeUnitAt(pos);
    if (c == 36 || c == 95) {
      prefix.add(ident[pos++]);
    } else {
      break;
    }
  }

  rest = ident.substring(pos);
  var result = prefix.join();
  if (rest.isNotEmpty) {
    result = result + rest[0].toUpperCase() + rest.substring(1);
  }

  return result;
}

String convertToIdentifier(String str, String replacement) {
  if (str == null) {
    throw ArgumentError.notNull('str');
  }

  if (str.isEmpty) {
    throw ArgumentError.value(str, 'str', 'Must not be empty');
  }

  if (replacement == null) {
    throw ArgumentError.notNull('replacement');
  }

  var pos = 0;
  var sb = StringBuffer();
  while (pos < str.length) {
    var c = str.codeUnitAt(pos);
    if (!(alpha(c) || c == 95)) {
      sb.write(replacement);
      pos++;
    } else {
      break;
    }
  }

  for (; pos < str.length; pos++) {
    var c = str.codeUnitAt(pos);
    var s = str[pos];
    if (alphanum(c) || c == 95) {
      sb.write(s);
    } else {
      sb.write(replacement);
    }
  }

  var result = sb.toString();
  return result;
}

String makePublicIdentifier(String ident, String option) {
  if (ident == null) {
    throw ArgumentError.notNull('ident');
  }

  if (option == null) {
    throw ArgumentError.notNull('option');
  }

  if (ident.isEmpty) {
    return option;
  }

  var suffix = <String>[];
  var pos = 0;
  while (pos < ident.length) {
    var c = ident.codeUnitAt(pos);
    if (c == 95) {
      suffix.add('_');
      pos++;
    } else {
      break;
    }
  }

  var rest = ident.substring(pos);
  if (rest.isEmpty) {
    rest = option;
  }

  var result = rest + suffix.join('');
  return result;
}
