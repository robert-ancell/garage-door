import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class DnsName {
  final List<Uint8List> rawName;

  DnsName(String name)
      : rawName = name
            .split('.')
            .map((label) => Uint8List.fromList(utf8.encode(label)))
            .toList();

  DnsName.fromRaw(Iterable<Uint8List> labels) : rawName = labels.toList();

  @override
  String toString() => rawName.map((label) => utf8.decode(label)).join('.');
}

class DnsText {
  final Uint8List raw;

  DnsText(String text) : raw = Uint8List.fromList(utf8.encode(text));

  DnsText.fromRaw(this.raw);

  @override
  String toString() => utf8.decode(raw);
}

abstract class DnsQuestion {
  final DnsName name;
  int get type;
  final int class_;
  final bool unicastResponse;

  DnsQuestion(this.name, this.class_, this.unicastResponse);
}

class DnsIpv4AddressQuestion extends DnsQuestion {
  @override
  int get type => 1;

  DnsIpv4AddressQuestion(DnsName name,
      {int class_ = 1, bool unicastResponse = false})
      : super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($name, class_: $class_, $unicastResponse: $unicastResponse)';
}

class DnsDomainNameQuestion extends DnsQuestion {
  @override
  int get type => 12;

  DnsDomainNameQuestion(DnsName name,
      {int class_ = 1, bool unicastResponse = false})
      : super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($name, class_: $class_, $unicastResponse: $unicastResponse)';
}

class DnsTextQuestion extends DnsQuestion {
  @override
  int get type => 16;

  DnsTextQuestion(DnsName name, {int class_ = 1, bool unicastResponse = false})
      : super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($name, class_: $class_, $unicastResponse: $unicastResponse)';
}

class DnsIpv6AddressQuestion extends DnsQuestion {
  @override
  int get type => 28;

  DnsIpv6AddressQuestion(DnsName name,
      {int class_ = 1, bool unicastResponse = false})
      : super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($name, class_: $class_, $unicastResponse: $unicastResponse)';
}

class DnsServiceRecordQuestion extends DnsQuestion {
  @override
  int get type => 33;

  DnsServiceRecordQuestion(DnsName name,
      {int class_ = 1, bool unicastResponse = false})
      : super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($name, class_: $class_, $unicastResponse: $unicastResponse)';
}

class DnsUnknownQuestion extends DnsQuestion {
  final int _type;
  @override
  int get type => _type;

  DnsUnknownQuestion(int type, DnsName name,
      {int class_ = 1, bool unicastResponse = false})
      : _type = type,
        super(name, class_, unicastResponse);

  @override
  String toString() =>
      '$runtimeType($type, $name, class_: $class_, $unicastResponse: $unicastResponse)';
}

abstract class DnsResourceRecord {
  final DnsName name;
  int get type;
  final int class_;
  final bool unicastResponse;
  final int ttl;

  DnsResourceRecord(this.name, this.class_, this.unicastResponse, this.ttl);
}

class DnsUnknownResourceRecord extends DnsResourceRecord {
  final DnsName name;
  final int _type;
  @override
  int get type => _type;
  final Uint8List data;

  DnsUnknownResourceRecord(int type, this.name, this.data,
      {int class_ = 1, bool unicastResponse = false, int ttl = 0})
      : _type = type,
        super(name, class_, unicastResponse, ttl);

  @override
  String toString() =>
      '$runtimeType($name, $data, type: $type, class_: $class_, ttl: $ttl)';
}

class DnsIpv4AddressRecord extends DnsResourceRecord {
  final InternetAddress address;
  @override
  int get type => 1;

  DnsIpv4AddressRecord(DnsName name, this.address,
      {int class_ = 1, bool unicastResponse = false, int ttl = 0})
      : super(name, class_, unicastResponse, ttl);

  @override
  String toString() =>
      '$runtimeType($name, $address, class_: $class_, ttl: $ttl)';
}

class DnsDomainNameRecord extends DnsResourceRecord {
  final DnsName domainName;

  @override
  int get type => 12;

  DnsDomainNameRecord(DnsName name, this.domainName,
      {int class_ = 1, bool unicastResponse = false, int ttl = 0})
      : super(name, class_, unicastResponse, ttl);

  @override
  String toString() =>
      '$runtimeType($name, $domainName, class_: $class_, ttl: $ttl)';
}

class DnsTextRecord extends DnsResourceRecord {
  final DnsText text;

  @override
  int get type => 16;

  DnsTextRecord(DnsName name, this.text,
      {int class_ = 1, bool unicastResponse = false, int ttl = 0})
      : super(name, class_, unicastResponse, ttl);

  @override
  String toString() => '$runtimeType($name, $text, class_: $class_, ttl: $ttl)';
}

class DnsIpv6AddressRecord extends DnsResourceRecord {
  final InternetAddress address;
  @override
  int get type => 28;

  DnsIpv6AddressRecord(DnsName name, this.address,
      {int class_ = 1, bool unicastResponse = false, int ttl = 0})
      : super(name, class_, unicastResponse, ttl);

  @override
  String toString() =>
      '$runtimeType($name, $address, class_: $class_, ttl: $ttl)';
}

class DnsServiceRecord extends DnsResourceRecord {
  final int priority;
  final int weight;
  final int port;
  final DnsName target;

  @override
  int get type => 33;

  DnsServiceRecord(DnsName name,
      {this.priority = 0,
      this.weight = 0,
      required this.port,
      required this.target,
      int class_ = 1,
      bool unicastResponse = false,
      int ttl = 0})
      : super(name, class_, unicastResponse, ttl);

  @override
  String toString() =>
      '$runtimeType($name, priority: $priority, weight: $weight, port: $port, target: $target, class_: $class_, ttl: $ttl)';
}

class DnsMessage {
  final InternetAddress? source;
  final int id;
  final bool isResponse;
  final int opcode;
  final int responseCode;
  final List<DnsQuestion> questions;
  final List<DnsResourceRecord> answers;
  final List<DnsResourceRecord> authorities;
  final List<DnsResourceRecord> additionalRecords;

  DnsMessage(
      {this.source,
      this.id = 0,
      this.isResponse = false,
      this.opcode = 0,
      this.responseCode = 0,
      this.questions = const [],
      this.answers = const [],
      this.authorities = const [],
      this.additionalRecords = const []});

  @override
  String toString() =>
      '$runtimeType(source: $source, id: $id, isResponse: $isResponse, opcode: $opcode, responseCode: $responseCode, questions: $questions, answers: $answers, authorities: $authorities, additionalRecords: $additionalRecords)';
}

class DnsMessageDecoder {
  final InternetAddress? _source;
  final Uint8List _data;
  var _offset = 0;
  int get _remaining => _data.length - _offset;

  DnsMessageDecoder(this._source, this._data);

  DnsMessage decode() {
    if (_remaining < 12) {
      throw ('Too short for header');
    }

    var id = _readUint16();
    var flags = _readUint16();
    var isResponse = (flags & 0xf0) != 0;
    var opcode = (flags >> 11) & 0xf;
    var responseCode = flags & 0xf;
    var questionCount = _readUint16();
    var answerCount = _readUint16();
    var authorityCount = _readUint16();
    var additionalRecordCount = _readUint16();
    var questions = <DnsQuestion>[];
    for (var i = 0; i < questionCount; i++) {
      questions.add(_readQuestion());
    }
    var answers = <DnsResourceRecord>[];
    for (var i = 0; i < answerCount; i++) {
      answers.add(_readResourceRecord());
    }
    var authorities = <DnsResourceRecord>[];
    for (var i = 0; i < authorityCount; i++) {
      authorities.add(_readResourceRecord());
    }
    var additionalRecords = <DnsResourceRecord>[];
    for (var i = 0; i < additionalRecordCount; i++) {
      additionalRecords.add(_readResourceRecord());
    }

    if (_remaining > 0) {
      throw ('$_remaining unused octets');
    }

    return DnsMessage(
        source: _source,
        id: id,
        isResponse: isResponse,
        opcode: opcode,
        responseCode: responseCode,
        questions: questions,
        answers: answers,
        authorities: authorities,
        additionalRecords: additionalRecords);
  }

  int _readUint8() {
    if (_remaining < 1) {
      throw ('Insufficient space');
    }
    var value = _data[_offset];
    _offset += 1;
    return value;
  }

  int _readUint16() {
    if (_remaining < 2) {
      throw ('Insufficient space');
    }
    var value = _data[_offset] << 8 | _data[_offset + 1];
    _offset += 2;
    return value;
  }

  int _readUint32() {
    if (_remaining < 4) {
      throw ('Insufficient space');
    }
    var value = _data[_offset] << 24 |
        _data[_offset + 1] << 16 |
        _data[_offset + 2] << 8 |
        _data[_offset + 3];
    _offset += 4;
    return value;
  }

  Uint8List _readBytes(int count) {
    if (_remaining < count) {
      throw ('Insufficient space for bytes of length $count');
    }
    var value = Uint8List.sublistView(_data, _offset, _offset + count);
    _offset += count;
    return value;
  }

  DnsQuestion _readQuestion() {
    var name = _readName();
    var type = _readUint16();
    var class_ = _readUint16();
    var unicastResponse = false;
    if (class_ & 0x8000 != 0) {
      unicastResponse = true;
      class_ &= 0x7fff;
    }
    switch (type) {
      case 1:
        return DnsIpv4AddressQuestion(name,
            class_: class_, unicastResponse: unicastResponse);
      case 12:
        return DnsDomainNameQuestion(name,
            class_: class_, unicastResponse: unicastResponse);
      case 16:
        return DnsTextQuestion(name,
            class_: class_, unicastResponse: unicastResponse);
      case 28:
        return DnsIpv6AddressQuestion(name,
            class_: class_, unicastResponse: unicastResponse);
      case 33:
        return DnsServiceRecordQuestion(name,
            class_: class_, unicastResponse: unicastResponse);
      default:
        return DnsUnknownQuestion(type, name,
            class_: class_, unicastResponse: unicastResponse);
    }
  }

  DnsResourceRecord _readResourceRecord() {
    var name = _readName();
    var type = _readUint16();
    var class_ = _readUint16();
    var unicastResponse = false;
    if (class_ & 0x8000 != 0) {
      unicastResponse = true;
      class_ &= 0x7fff;
    }
    var ttl = _readUint32();
    var dataLength = _readUint16();
    switch (type) {
      case 1:
        if (dataLength != 4) {
          throw ('Invalid IPv4 address data');
        }
        return DnsIpv4AddressRecord(
            name,
            InternetAddress.fromRawAddress(_readBytes(dataLength),
                type: InternetAddressType.IPv4),
            class_: class_,
            unicastResponse: unicastResponse,
            ttl: ttl);
      case 12:
        var endOffset = _offset + dataLength;
        var domainName = _readName();
        if (_offset != endOffset) {
          throw ('Invalid domain name record');
        }
        return DnsDomainNameRecord(name, domainName,
            class_: class_, unicastResponse: unicastResponse, ttl: ttl);
      case 16:
        return DnsTextRecord(name, DnsText.fromRaw(_readBytes(dataLength)),
            class_: class_, unicastResponse: unicastResponse, ttl: ttl);
      case 28:
        if (dataLength != 16) {
          throw ('Invalid IPv6 address data');
        }
        return DnsIpv6AddressRecord(
            name,
            InternetAddress.fromRawAddress(_readBytes(dataLength),
                type: InternetAddressType.IPv6),
            class_: class_,
            unicastResponse: unicastResponse,
            ttl: ttl);
      case 33:
        var endOffset = _offset + dataLength;
        var priority = _readUint16();
        var weight = _readUint16();
        var port = _readUint16();
        var target = _readName();
        if (_offset != endOffset) {
          throw ('Invalid domain name record');
        }
        return DnsServiceRecord(name,
            priority: priority,
            weight: weight,
            port: port,
            target: target,
            class_: class_,
            unicastResponse: unicastResponse,
            ttl: ttl);
      default:
        return DnsUnknownResourceRecord(type, name, _readBytes(dataLength),
            class_: class_, unicastResponse: unicastResponse, ttl: ttl);
    }
  }

  DnsName _readName() {
    var endOffset = _offset;
    var inPointer = false;
    var labels = <Uint8List>[];
    while (true) {
      var length = _readUint8();
      if (length == 0) {
        if (inPointer) {
          _offset = endOffset;
        }
        return DnsName.fromRaw(labels);
      }

      if (length <= 63) {
        labels.add(_readBytes(length));
      } else if (length & 0xc0 == 0xc0) {
        // FIXME: Check for loops
        var pointerOffset = ((length & 0x3f) << 8) | _readUint8();
        if (pointerOffset >= _data.length) {
          throw ('Pointer outside of message');
        }
        if (!inPointer) {
          endOffset = _offset;
        }
        inPointer = true;
        _offset = pointerOffset;
      } else {
        throw ('Unknown label');
      }
    }
  }
}

class DnsMessageEncoder {
  Uint8List encode(DnsMessage message) {
    var builder = BytesBuilder();

    _writeUint16(builder, message.id);
    var flags = 0;
    if (message.isResponse) {
      flags |= 0x8000;
    }
    flags |= (message.opcode & 0xf) << 11;
    _writeUint16(builder, flags);
    _writeUint16(builder, message.questions.length);
    _writeUint16(builder, message.answers.length);
    _writeUint16(builder, message.authorities.length);
    _writeUint16(builder, message.additionalRecords.length);
    for (var record in message.questions) {
      _writeQuestion(builder, record);
    }
    for (var record in message.answers) {
      _writeResourceRecord(builder, record);
    }
    for (var record in message.authorities) {
      _writeResourceRecord(builder, record);
    }
    for (var record in message.additionalRecords) {
      _writeResourceRecord(builder, record);
    }

    return builder.takeBytes();
  }

  void _writeUint16(BytesBuilder builder, int value) {
    builder.addByte((value >> 8) & 0xff);
    builder.addByte(value & 0xff);
  }

  void _writeQuestion(BytesBuilder builder, DnsQuestion record) {
    _writeName(builder, record.name);
    _writeUint16(builder, record.type);
    _writeUint16(builder, record.class_);
  }

  void _writeResourceRecord(BytesBuilder builder, DnsResourceRecord record) {
    _writeName(builder, record.name);
    _writeUint16(builder, record.type);
    _writeUint16(builder, record.class_);
    _writeUint16(builder, record.ttl);
    _writeUint16(builder, 0); // data length
  }

  void _writeName(BytesBuilder builder, DnsName name) {
    for (var label in name.rawName) {
      builder.addByte(label.length);
      builder.add(label);
    }
    builder.addByte(0);
  }
}

class MulticastDnsClient {
  RawDatagramSocket? socket;
  final address = InternetAddress('224.0.0.251');
  final int port = 5353;

  Future<Stream<DnsMessage>> start() async {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    socket!.joinMulticast(address);
    return socket!
        .map((event) => event == RawSocketEvent.read ? socket!.receive() : null)
        .where((datagram) => datagram != null)
        .map((datagram) =>
            DnsMessageDecoder(datagram!.address, datagram.data).decode());
  }

  void send(DnsMessage message) {
    var data = DnsMessageEncoder().encode(message);
    var n_sent = socket?.send(data, address, port);
    assert(n_sent == data.length);
  }

  void stop() {
    socket?.close();
  }
}

class ServiceAddress {
  final InternetAddress address;
  final int port;

  ServiceAddress(this.address, this.port);
}

Future<ServiceAddress?> lookupLocalServiceAddress(String name,
    {int timeoutSeconds = 5}) async {
  var client = MulticastDnsClient();
  var messages = await client.start();
  var completer = Completer<ServiceAddress?>();
  var timeoutSubscription =
      Stream.periodic(Duration(seconds: timeoutSeconds)).listen((v) {
    completer.complete(null);
  });
  var messageSubscription = messages.listen((message) {
    for (var record in message.answers) {
      if (message.source != null &&
          record is DnsServiceRecord &&
          record.name.toString() == name) {
        completer.complete(ServiceAddress(message.source!, record.port));
      }
    }
  });
  client.send(DnsMessage(questions: [DnsServiceRecordQuestion(DnsName(name))]));
  var address = await completer.future;
  timeoutSubscription.cancel();
  messageSubscription.cancel();
  return address;
}
