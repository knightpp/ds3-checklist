// automatically generated by the FlatBuffers compiler, do not modify
// ignore_for_file: unused_import, unused_field, unused_element, unused_local_variable

library ds3_c;

import 'dart:typed_data' show Uint8List;
import 'package:flat_buffers/flat_buffers.dart' as fb;


class ArmorCategory {
  ArmorCategory._(this._bc, this._bcOffset);
  factory ArmorCategory(List<int> bytes) {
    final rootRef = fb.BufferContext.fromBytes(bytes);
    return reader.read(rootRef, 0);
  }

  static const fb.Reader<ArmorCategory> reader = _ArmorCategoryReader();

  final fb.BufferContext _bc;
  final int _bcOffset;

  String? get category => const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 4);
  List<Gear>? get gears => const fb.ListReader<Gear>(Gear.reader).vTableGetNullable(_bc, _bcOffset, 6);

  @override
  String toString() {
    return 'ArmorCategory{category: $category, gears: $gears}';
  }
}

class _ArmorCategoryReader extends fb.TableReader<ArmorCategory> {
  const _ArmorCategoryReader();

  @override
  ArmorCategory createObject(fb.BufferContext bc, int offset) => 
    ArmorCategory._(bc, offset);
}

class ArmorCategoryBuilder {
  ArmorCategoryBuilder(this.fbBuilder);

  final fb.Builder fbBuilder;

  void begin() {
    fbBuilder.startTable(2);
  }

  int addCategoryOffset(int? offset) {
    fbBuilder.addOffset(0, offset);
    return fbBuilder.offset;
  }
  int addGearsOffset(int? offset) {
    fbBuilder.addOffset(1, offset);
    return fbBuilder.offset;
  }

  int finish() {
    return fbBuilder.endTable();
  }
}

class ArmorCategoryObjectBuilder extends fb.ObjectBuilder {
  final String? _category;
  final List<GearObjectBuilder>? _gears;

  ArmorCategoryObjectBuilder({
    String? category,
    List<GearObjectBuilder>? gears,
  })
      : _category = category,
        _gears = gears;

  /// Finish building, and store into the [fbBuilder].
  @override
  int finish(fb.Builder fbBuilder) {
    final int? categoryOffset = _category == null ? null
        : fbBuilder.writeString(_category!);
    final int? gearsOffset = _gears == null ? null
        : fbBuilder.writeList(_gears!.map((b) => b.getOrCreateOffset(fbBuilder)).toList());
    fbBuilder.startTable(2);
    fbBuilder.addOffset(0, categoryOffset);
    fbBuilder.addOffset(1, gearsOffset);
    return fbBuilder.endTable();
  }

  /// Convenience method to serialize to byte list.
  @override
  Uint8List toBytes([String? fileIdentifier]) {
    final fbBuilder = fb.Builder(deduplicateTables: false);
    fbBuilder.finish(finish(fbBuilder), fileIdentifier);
    return fbBuilder.buffer;
  }
}
class Gear {
  Gear._(this._bc, this._bcOffset);
  factory Gear(List<int> bytes) {
    final rootRef = fb.BufferContext.fromBytes(bytes);
    return reader.read(rootRef, 0);
  }

  static const fb.Reader<Gear> reader = _GearReader();

  final fb.BufferContext _bc;
  final int _bcOffset;

  int get id => const fb.Uint32Reader().vTableGet(_bc, _bcOffset, 4, 0);
  String? get name => const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 6);

  @override
  String toString() {
    return 'Gear{id: $id, name: $name}';
  }
}

class _GearReader extends fb.TableReader<Gear> {
  const _GearReader();

  @override
  Gear createObject(fb.BufferContext bc, int offset) => 
    Gear._(bc, offset);
}

class GearBuilder {
  GearBuilder(this.fbBuilder);

  final fb.Builder fbBuilder;

  void begin() {
    fbBuilder.startTable(2);
  }

  int addId(int? id) {
    fbBuilder.addUint32(0, id);
    return fbBuilder.offset;
  }
  int addNameOffset(int? offset) {
    fbBuilder.addOffset(1, offset);
    return fbBuilder.offset;
  }

  int finish() {
    return fbBuilder.endTable();
  }
}

class GearObjectBuilder extends fb.ObjectBuilder {
  final int? _id;
  final String? _name;

  GearObjectBuilder({
    int? id,
    String? name,
  })
      : _id = id,
        _name = name;

  /// Finish building, and store into the [fbBuilder].
  @override
  int finish(fb.Builder fbBuilder) {
    final int? nameOffset = _name == null ? null
        : fbBuilder.writeString(_name!);
    fbBuilder.startTable(2);
    fbBuilder.addUint32(0, _id);
    fbBuilder.addOffset(1, nameOffset);
    return fbBuilder.endTable();
  }

  /// Convenience method to serialize to byte list.
  @override
  Uint8List toBytes([String? fileIdentifier]) {
    final fbBuilder = fb.Builder(deduplicateTables: false);
    fbBuilder.finish(finish(fbBuilder), fileIdentifier);
    return fbBuilder.buffer;
  }
}
class ArmorRoot {
  ArmorRoot._(this._bc, this._bcOffset);
  factory ArmorRoot(List<int> bytes) {
    final rootRef = fb.BufferContext.fromBytes(bytes);
    return reader.read(rootRef, 0);
  }

  static const fb.Reader<ArmorRoot> reader = _ArmorRootReader();

  final fb.BufferContext _bc;
  final int _bcOffset;

  List<ArmorCategory>? get items => const fb.ListReader<ArmorCategory>(ArmorCategory.reader).vTableGetNullable(_bc, _bcOffset, 4);

  @override
  String toString() {
    return 'ArmorRoot{items: $items}';
  }
}

class _ArmorRootReader extends fb.TableReader<ArmorRoot> {
  const _ArmorRootReader();

  @override
  ArmorRoot createObject(fb.BufferContext bc, int offset) => 
    ArmorRoot._(bc, offset);
}

class ArmorRootBuilder {
  ArmorRootBuilder(this.fbBuilder);

  final fb.Builder fbBuilder;

  void begin() {
    fbBuilder.startTable(1);
  }

  int addItemsOffset(int? offset) {
    fbBuilder.addOffset(0, offset);
    return fbBuilder.offset;
  }

  int finish() {
    return fbBuilder.endTable();
  }
}

class ArmorRootObjectBuilder extends fb.ObjectBuilder {
  final List<ArmorCategoryObjectBuilder>? _items;

  ArmorRootObjectBuilder({
    List<ArmorCategoryObjectBuilder>? items,
  })
      : _items = items;

  /// Finish building, and store into the [fbBuilder].
  @override
  int finish(fb.Builder fbBuilder) {
    final int? itemsOffset = _items == null ? null
        : fbBuilder.writeList(_items!.map((b) => b.getOrCreateOffset(fbBuilder)).toList());
    fbBuilder.startTable(1);
    fbBuilder.addOffset(0, itemsOffset);
    return fbBuilder.endTable();
  }

  /// Convenience method to serialize to byte list.
  @override
  Uint8List toBytes([String? fileIdentifier]) {
    final fbBuilder = fb.Builder(deduplicateTables: false);
    fbBuilder.finish(finish(fbBuilder), fileIdentifier);
    return fbBuilder.buffer;
  }
}
