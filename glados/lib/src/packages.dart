class Package {
  Package(this.name, [String gladosName])
      : this.gladosName = gladosName ?? '${name}_glados';

  final name;
  final gladosName;

  String toString() => name;
}

final builtIn = Package('dart:core', '');
final tuple = Package('tuple');

/// This file contains info about which packages to recommend bsaed on the type
final typeNameToPackages = <String, List<Package>>{
  'int': [builtIn],
  'List': [builtIn],
  'Tuple2': [tuple, builtIn],
};
