#library('start');

#import('dart:isolate');
#import('message.dart');
#import('server.dart');

class Start {
  ReceivePort _statusPort;
  SendPort _serverPort;
  Server _server;
  
  Start.createServer(String hostAddress, int tcpPort)
    : _statusPort = new ReceivePort(),
      _serverPort = null,
      _server = new Server() {
    _server.spawn().then((SendPort port) {
      _serverPort = port;
      _statusPort.receive((var message, SendPort replyTo) {
        String status = message;
        print("Received status: $status");
      });
      var message = new Message.start(hostAddress, tcpPort);
      _serverPort.send(message, _statusPort.toSendPort());
    });
  }
  
  noSuchMethod (String name, List args) {
    var message = new Message('add', {
      'method': name,
      'route': args[0],
      'handler': null
    });
    _serverPort.send(message, _statusPort.toSendPort());
  }
}
