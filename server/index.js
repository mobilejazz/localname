// constants
var HttpPort = 3000
var SocketIOPort = 1235

var app = require('express')();
var net = require('net');
var http = require('http').Server(app);
var io = require('socket.io')(http);
var uuid = require("uuid");
var validator = require('validator');
 
var clients = {}
var sockets = {}

var tcpServer = net.createServer(function(socket) {
  var domain = null;
  var socketio = null;
  var id = uuid.v4();
  var buffer = Buffer(0);
  socket.on('data', function(data){
    if(domain == null) {
      buffer = Buffer.concat([buffer, data]);
      var matches = buffer.toString().match(/\r\nHost\: ?([^:]+)(:\d+)?\r\n/);
      if(matches == null) {
        return;
      }
      domain = matches[1];
      sockets[id] = socket;
      console.log('incoming http request for: <' + domain+'>');
      socketio = clients[domain];
      if(!socketio) {
	  console.log('domain is unknown, ignoring: <'+domain+'>');
          socket.end();
          return;
      }
      socketio.emit('socket-connect', {"domain": domain, "id": id});
      console.log('sending first data to: ' + domain);
      socketio.emit('socket-send', {"id": id, "data": buffer});
    } else {
      if(socketio == null) {
          socket.end();
          return;
      }
      console.log('sending data to: ' + domain);
      socketio.emit('socket-send', {"id": id, "data": data});
    }
  });
  socket.on('end', function() { // we got a FIN
    if(socketio != null) {
      console.log('socket disconnecting: ' + domain);
      socketio.emit('socket-fin', {"id": id});
    }
  });
  socket.on('error', function(e) {
    console.log('error on socket:', e);
  });
});
tcpServer.listen(HttpPort, "localhost", function(){
  console.log('listening for http clients on *:'+HttpPort);
});

http.listen(SocketIOPort, function(){
  console.log('socket.io on *:'+SocketIOPort);
});

io.on('connection', function(socketio){
  var clientRegistrations = {};
  console.log('a client connected');
  socketio.on('disconnect', function(reason){
    console.log('socketio disconnected: '+reason);
    for (var c in clientRegistrations) {
      if(clientRegistrations.hasOwnProperty(c)) {
        if(clients[c]) {
          console.log('socketio disconnected, unregistering: '+c);
          delete clients[c];
        }
      }
    }
  });
  socketio.on('login', function(cmd, ack){
    if(cmd.protocol_version > 1) {
      socketio.emit("server-message", { text: "Sorry, your client seems to be too modern" });
    }
    ack();
  });
  socketio.on('register', function(cmd, ack){
    var valid = validator.isFQDN(cmd.domain);
    if(valid) {
        clients[cmd.domain] = socketio;
        clientRegistrations[cmd.domain] = true;
        console.log('client registered for domain: ' + cmd.domain);
        ack();
    }
  });
  socketio.on('unregister', function(cmd){
    if(clients[cmd.domain] == socketio) {
      console.log('client unregistered for domain: ' + cmd.domain);
      delete clients[cmd.domain];
    }
  });
  socketio.on('is-available', function(cmd, ack){
    var available = validator.isFQDN(cmd.domain) && !clients[cmd.domain];
    ack({available: available});
  });
  socketio.on('socket-send', function(cmd){
    console.log('received data from: ' + cmd.id);
    sockets[cmd.id].write(cmd.data);
  });
  socketio.on('socket-fin', function(cmd){
    console.log('socketio sending FIN: ' + cmd.id);
    sockets[cmd.id].end()
  });
  socketio.on('error', function(e) {
    console.log('error on socketio:', e);
  });
});
