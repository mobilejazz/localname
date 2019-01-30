/*
Copyright (c) <2014>, skysent
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
must display the following acknowledgement:
This product includes software developed by skysent.
4. Neither the name of the skysent nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY skysent ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL skysent BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation

@_silgen_name("ytcpsocket_connect") func c_ytcpsocket_connect(host:UnsafePointer<Int8>,port:Int32,timeout:Int32) -> Int32
@_silgen_name("ytcpsocket_shutdownwr") func c_ytcpsocket_shutdownwr(fd:Int32) -> Int32
@_silgen_name("ytcpsocket_close") func c_ytcpsocket_close(fd:Int32) -> Int32
@_silgen_name("ytcpsocket_send") func c_ytcpsocket_send(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@_silgen_name("ytcpsocket_pull") func c_ytcpsocket_pull(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,timeout:Int32) -> Int32
@_silgen_name("ytcpsocket_listen") func c_ytcpsocket_listen(addr:UnsafePointer<Int8>,port:Int32)->Int32
@_silgen_name("ytcpsocket_accept") func c_ytcpsocket_accept(onsocketfd:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32

public class TCPClient {
    var addr:String
    var port:Int
    var fd:Int32?

    init(){
        self.addr=""
        self.port=0
    }
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }

    /*
     * connect to server
     * return success or fail with message
     */
    public func connect(timeout t:Int)->(Bool,String){
        let rs:Int32=c_ytcpsocket_connect(host: self.addr, port: Int32(self.port), timeout: Int32(t))
        if rs>0{
            self.fd=rs
            return (true,"connect success")
        }else{
            switch rs{
            case -1:
                return (false,"qeury server fail")
            case -2:
                return (false,"connection closed")
            case -3:
                return (false,"connect timeout")
            default:
                return (false,"unknow err.")
            }
        }
    }
    /*
    * close socket
    * return success or fail with message
    */
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            let status = c_ytcpsocket_close(fd: fd)
            if status != 0 {
                return (false, "error when closing")
            }
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * send data
    * return success or fail with message
    */
    public func send(data d:[UInt8])->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd: fd, buff: d, len: Int32(d.count))
            if Int(sendsize)==d.count{
               return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * send string
    * return success or fail with message
    */
    public func send(str s:String)->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd: fd, buff: s, len: Int32(strlen(s)))
            if sendsize==Int32(strlen(s)){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    *
    * send nsdata
    */
    public func send(data d:NSData)->(Bool,String){
        if let fd:Int32=self.fd{
            var buff:[UInt8] = [UInt8](repeating:0x0, count:d.length)
            d.getBytes(&buff, length: d.length)
            let sendsize:Int32=c_ytcpsocket_send(fd: fd, buff: buff, len: Int32(d.length))
            if sendsize==Int32(d.length){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * read data with expect length
    * return success or fail with message
    */
    public func read(expectlen:Int)->[UInt8]?{
        if let fd:Int32 = self.fd{
            var buff:[UInt8] = [UInt8](repeating:0x0,count:expectlen)
            let readLen:Int32=c_ytcpsocket_pull(fd: fd, buff: &buff, len: Int32(expectlen), timeout: 60)
            if readLen<=0{
                return nil
            }
            let rs=buff[0...Int(readLen-1)]
            let data:[UInt8] = Array(rs)
            return data
        }
       return nil
    }
    
    public func shutdown()->Bool {
        if let fd = self.fd{
            return c_ytcpsocket_shutdownwr(fd: fd) == 0
        }
        return false
    }
    
    class DataListener:Thread {
        var socket:TCPClient
        var dataCallback:((NSData)->Void)?
        var closeCallback:(()->Void)?
        init (socket: TCPClient) {
            self.socket = socket
        }
        override func main() {
            var result: [UInt8]?
            repeat {
                result = socket.read(expectlen: 1024)
                if let bytes = result {
                    if let dataCallback = self.dataCallback {
                        let data = NSData(bytes:bytes, length:bytes.count)
                        dataCallback(data)
                    }
                }
            } while (result != nil)
            if let cb = closeCallback {
                cb()
            }
        }
    }
    var dataListener: DataListener?
    
    public func onData(callback: @escaping (NSData)->Void) {
        if dataListener == nil {
            dataListener = DataListener(socket: self)
            dataListener!.start()
        }
        dataListener!.dataCallback = callback
    }
    
    public func onClose(callback: @escaping ()->Void) {
        if dataListener == nil {
            dataListener = DataListener(socket: self)
            dataListener!.start()
        }
        dataListener!.closeCallback = callback
    }
}

public class TCPServer {
    var addr:String
    var port:Int
    var fd:Int32?
    init(){
        self.addr=""
        self.port=0
    }
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }
    public func listen()->(Bool,String){
        
        let fd:Int32=c_ytcpsocket_listen(addr: self.addr, port: Int32(self.port))
        if fd>0{
            self.fd=fd
            return (true,"listen success")
        }else{
            return (false,"listen fail")
        }
    }
    public func accept()->TCPClient?{
        if let serferfd=self.fd{
            var buff:[Int8] = [Int8](repeating:0x0, count:16)
            var port:Int32=0
            let clientfd:Int32=c_ytcpsocket_accept(onsocketfd: serferfd, ip: &buff,port: &port)
            if clientfd<0{
                return nil
            }
            let tcpClient:TCPClient=TCPClient()
            tcpClient.fd=clientfd
            tcpClient.port=Int(port)
            if let addr=String(cString: buff, encoding: String.Encoding.utf8){
               tcpClient.addr=addr
            }
            return tcpClient
        }
        return nil
    }
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            let status = c_ytcpsocket_close(fd: fd)
            if status != 0 {
                return (false, "error when closing")
            }
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
}


