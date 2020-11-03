class Package {
  Package(this.name, [String gladosName])
      : gladosName = gladosName ?? '${name}_glados';

  final name;
  final gladosName;

  @override
  String toString() => name;
}

final builtIn = Package('dart:core', '');
final tuple = Package('tuple');

/// This file contains info about which packages to recommend bsaed on the type
final typeNameToPackages = <String, List<Package>>{
  'Null': [builtIn],
  'bool': [builtIn],
  'int': [builtIn],
  'double': [builtIn],
  'num': [builtIn],
  'BigInt': [builtIn],
  'DateTime': [builtIn],
  'Duration': [builtIn],
  'List': [builtIn],
  'Set': [builtIn],
  'Map': [builtIn],
  'Tuple2': [tuple],
  'Tuple3': [tuple],
  'Tuple4': [tuple],
  'Tuple5': [tuple],
  'Tuple6': [tuple],
  'Tuple7': [tuple],
};
