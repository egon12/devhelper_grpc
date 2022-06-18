import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import '../../proto/descriptor.pb.dart';

class DynamicMessage extends GeneratedMessage {
  @override
  BuilderInfo info_;

  Map<String, int> fieldTag;

  Map<String, FieldDescriptorProto_Type> fieldType;

  var jsonEncoder = const JsonEncoder.withIndent('  ');

  DynamicMessage(
      {required this.info_, required this.fieldTag, required this.fieldType});

  @override
  DynamicMessage createEmptyInstance() =>
      DynamicMessage(info_: info_, fieldTag: fieldTag, fieldType: fieldType);

  @override
  DynamicMessage clone() =>
      DynamicMessage(info_: info_, fieldTag: fieldTag, fieldType: fieldType);

  dynamic getAt(int index) {
    return $_get(index, '');
  }

  void set(String name, dynamic value) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    setField(tagNumber!, value);
  }

  // TODO maybe need to use clone, so it won't affect real object
  String generateEditableJson() {
    setDefaultToAll();
    var body = toProto3Json();
    return jsonEncoder.convert(body);
  }

  // TODO maybe there are better way by using protobuf function
  void setDefaultToAll() {
    for (var e in fieldType.entries) {
      switch (e.value) {
        case FieldDescriptorProto_Type.TYPE_BOOL:
          set(e.key, false);
          break;
        case FieldDescriptorProto_Type.TYPE_BYTES:
          set(e.key, Uint8List(0));
          break;
        case FieldDescriptorProto_Type.TYPE_DOUBLE:
          set(e.key, 0.0);
          break;
        case FieldDescriptorProto_Type.TYPE_ENUM:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_FIXED32:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_FIXED64:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_FLOAT:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_GROUP:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_INT32:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_INT64:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_MESSAGE:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_SFIXED32:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_SFIXED64:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_SINT32:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_SINT64:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_STRING:
          set(e.key, "");
          break;
        case FieldDescriptorProto_Type.TYPE_UINT32:
          // TODO: Handle this case.
          break;
        case FieldDescriptorProto_Type.TYPE_UINT64:
          break;
      }
    }
  }

  dynamic get(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);

    final type = fieldType[name];
    assert(type != null);

    switch (type) {
      case FieldDescriptorProto_Type.TYPE_DOUBLE:
      case FieldDescriptorProto_Type.TYPE_FLOAT:
        return getDouble(name);

      case FieldDescriptorProto_Type.TYPE_INT64:
      case FieldDescriptorProto_Type.TYPE_UINT64:
      case FieldDescriptorProto_Type.TYPE_INT32:
      case FieldDescriptorProto_Type.TYPE_FIXED64:
      case FieldDescriptorProto_Type.TYPE_FIXED32:
      case FieldDescriptorProto_Type.TYPE_SFIXED32:
      case FieldDescriptorProto_Type.TYPE_SFIXED64:
      case FieldDescriptorProto_Type.TYPE_SINT32:
      case FieldDescriptorProto_Type.TYPE_SINT64:
      case FieldDescriptorProto_Type.TYPE_UINT32:
        return getInt(name);

      case FieldDescriptorProto_Type.TYPE_BOOL:
        return getBool(name);

      case FieldDescriptorProto_Type.TYPE_STRING:
        return getString(name);

      case FieldDescriptorProto_Type.TYPE_BYTES:
        return getBytes(name);

      case FieldDescriptorProto_Type.TYPE_GROUP:
        throw Exception("cannot get value from group");
      case FieldDescriptorProto_Type.TYPE_MESSAGE:
      case FieldDescriptorProto_Type.TYPE_ENUM:

      default:
        throw Exception("Cannot get value");
    }
  }

  bool getBool(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_get(tagNumber!, false);
  }

  List<int> getBytes(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_get(tagNumber!, List<int>.empty());
  }

  double getDouble(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_get(tagNumber!, 0.0);
  }

  int getInt(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_get(tagNumber!, 0);
  }

  String getString(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_get(tagNumber!, '');
  }

  List getList(String name) {
    final tagNumber = fieldTag[name];
    assert(tagNumber != null);
    return $_getList(tagNumber!);
  }

  void setString(int index, String value) {
    return $_setString(index, value);
  }

  DynamicMessage fromBuffer(List<int> i,
      [ExtensionRegistry r = ExtensionRegistry.EMPTY]) {
    mergeFromBuffer(i, r);
    return this;
  }

  factory DynamicMessage.fromDescriptor(DescriptorProto dp, String packageName,
      {FileDescriptorSet? fds}) {
    final info = _fromDescriptor(dp, packageName: packageName, fds: fds);
    final fieldTag = _genMapNumber(dp);
    final fieldType = _genMapType(dp);

    return DynamicMessage(
        info_: info, fieldTag: fieldTag, fieldType: fieldType);
  }
}

Map<String, int> _genMapNumber(DescriptorProto dp) {
  Map<String, int> m = {};
  for (var fd in dp.field) {
    m[fd.name] = fd.number;
  }
  return m;
}

Map<String, FieldDescriptorProto_Type> _genMapType(DescriptorProto dp) {
  Map<String, FieldDescriptorProto_Type> m = {};
  for (var fd in dp.field) {
    m[fd.name] = fd.type;
  }
  return m;
}

BuilderInfo _fromDescriptor(DescriptorProto dp,
    {String packageName = '', FileDescriptorSet? fds}) {
  final info = BuilderInfo(dp.name,
      package: PackageName(packageName), createEmptyInstance: null);

  var valueOfFuncs = <String, ValueOfFunc>{};
  var enumValues = <String, List<ProtobufEnum>>{};

  for (var e in dp.enumType) {
    var values = e.value.map((e) => ProtobufEnum(e.number, e.name));
    enumValues[".$packageName.${dp.name}.${e.name}"] = values.toList();
    valueOfFuncs[".$packageName.${dp.name}.${e.name}"] =
        (value) => values.firstWhere((element) => element.value == value);
  }

  // dummy so index = fd.number
  info.add(0, '', null, null, null, null, null);

  for (var fd in dp.field) {
    switch (fd.type) {
      case FieldDescriptorProto_Type.TYPE_DOUBLE:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<double>(fd.number, fd.name, PbFieldType.OD);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<double>(fd.number, fd.name, PbFieldType.QD);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<double>(fd.number, fd.name, PbFieldType.PD);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_FLOAT:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<double>(fd.number, fd.name, PbFieldType.OF);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<double>(fd.number, fd.name, PbFieldType.QF);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<double>(fd.number, fd.name, PbFieldType.PF);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_INT64:
        info.aInt64(fd.number, fd.name);
        break;
      case FieldDescriptorProto_Type.TYPE_UINT64:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<Uint64>(fd.number, fd.name, PbFieldType.OU6);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<Uint64>(fd.number, fd.name, PbFieldType.QU6);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<Uint64>(fd.number, fd.name, PbFieldType.PU6);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_INT32:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<Int32>(fd.number, fd.name, PbFieldType.O3);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<Int32>(fd.number, fd.name, PbFieldType.Q3);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<Int32>(fd.number, fd.name, PbFieldType.P3);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_FIXED64:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OF6);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QF6);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PF6);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_FIXED32:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OF3);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QF3);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PF3);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_BOOL:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.aOB(fd.number, fd.name);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<bool>(fd.number, fd.name, PbFieldType.QB);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<bool>(fd.number, fd.name, PbFieldType.PB);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_STRING:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.aOS(fd.number, fd.name);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.aQS(fd.number, fd.name);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.pPS(fd.number, fd.name);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_GROUP:
        throw Exception("Still don't handle " + fd.type.name);
      case FieldDescriptorProto_Type.TYPE_MESSAGE:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.aOM(fd.number, fd.name);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.aQM(fd.number, fd.name);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<GeneratedMessage>(fd.number, fd.name, PbFieldType.PM);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_BYTES:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<List<int>>(fd.number, fd.name, PbFieldType.OY);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<List<int>>(fd.number, fd.name, PbFieldType.QY);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<List<int>>(fd.number, fd.name, PbFieldType.PY);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_UINT32:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a<Uint32>(fd.number, fd.name, PbFieldType.OU3);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a<Uint32>(fd.number, fd.name, PbFieldType.QU3);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p<Uint32>(fd.number, fd.name, PbFieldType.PU3);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_ENUM:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.e(fd.number, fd.name, PbFieldType.OE,
                defaultOrMaker: fd.defaultValue,
                valueOf: valueOfFuncs[fd.typeName],
                enumValues: enumValues[fd.typeName]);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QE,
                defaultOrMaker: fd.defaultValue);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PE);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_SFIXED32:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OSF3);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QSF3);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PSF3);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_SFIXED64:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OSF6);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QSF6);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PSF6);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_SINT32:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OS3);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QS3);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PS3);
            break;
        }
        break;
      case FieldDescriptorProto_Type.TYPE_SINT64:
        switch (fd.label) {
          case FieldDescriptorProto_Label.LABEL_OPTIONAL:
            info.a(fd.number, fd.name, PbFieldType.OS6);
            break;
          case FieldDescriptorProto_Label.LABEL_REQUIRED:
            info.a(fd.number, fd.name, PbFieldType.QS6);
            break;
          case FieldDescriptorProto_Label.LABEL_REPEATED:
            info.p(fd.number, fd.name, PbFieldType.PS6);
            break;
        }
        break;

      default:
        throw Exception("Still don't handle " + fd.type.name);
    }
  }

  return info;
}
