class Socket {
    __New() {
        this.socket := 0
        this.ws2_32 := DllCall("LoadLibrary", "Str", "ws2_32.dll", "Ptr")
        if !this.ws2_32
            throw {Message: "Error 1: Failed to load ws2_32.dll", What: "SocketInitFailed"}
        wsaData := Buffer(400)
        result := DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsaData.Ptr, "Int")
        if result != 0
            throw {Message: "Error 2: WSAStartup failed", What: "SocketInitFailed"}

        this.socket := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UInt")
        if this.socket = 0xFFFFFFFF || !this.socket
            throw {Message: " Error 3: Failed to create socket", What: "SocketCreationFailed"}
    }
    
    SetOption(option, value) {
        if (option = "reuseaddr") {
            if !this.socket || this.socket = -1
                throw {Message: "Error 4: Invalid socket handle", What: "SocketOptionFailed"}
            
            optval := Buffer(4)
            NumPut("Int", value ? 1 : 0, optval)
            result := DllCall("ws2_32\setsockopt", "UInt", this.socket, "UInt", 0xFFFF, "Int", 0x0004, "Ptr", optval.Ptr, "Int", 4, "Int")
            if result = -1 {
                errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
                throw {Message: "Error 5: setsockopt failed with error code: " errorCode, What: "SocketOptionFailed"}
            }
        }
    }
    
    Bind(host, port) {
        addr := Buffer(16, 0)
        NumPut("UShort", 2, addr, 0)
        
        portNet := DllCall("ws2_32\htons", "UShort", port, "UShort")
        NumPut("UShort", portNet, addr, 2)

        if (host = "0.0.0.0" || host = "" || host = "*") {
            ip := 0
        } else if (host = "localhost") {
            ip := DllCall("ws2_32\inet_addr", "Str", "127.0.0.1", "UInt")
            if ip = 0xFFFFFFFF {
                throw {Message: "Error: Failed to convert 127.0.0.1 to IP address", What: "IPConversionFailed"}
            }
        } else {
            ip := DllCall("ws2_32\inet_addr", "Str", host, "UInt")
            if ip = 0xFFFFFFFF {
                hostent := DllCall("ws2_32\gethostbyname", "Str", host, "Ptr")
                if !hostent {
                    errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
                    throw {Message: "Error: Failed to resolve hostname '" . host . "' (error code: " . errorCode . ")", What: "HostnameResolutionFailed"}
                } else {
                    addrList := NumGet(hostent, A_PtrSize * 3, "Ptr")
                    ip := NumGet(addrList, 0, "UInt")
                }
            }
        }
        NumPut("UInt", ip, addr, 4)
        
        result := DllCall("ws2_32\bind", "UInt", this.socket, "Ptr", addr.Ptr, "Int", 16, "Int")
        if result = -1 {
            errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            if (errorCode = 10049 && ip != 0) {
                NumPut("UInt", 0, addr, 4) 
                result := DllCall("ws2_32\bind", "UInt", this.socket, "Ptr", addr.Ptr, "Int", 16, "Int")
                if result = -1 {
                    errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
                    throw {Message: "Error 6: bind failed with error code: " errorCode " (even with INADDR_ANY)", What: "SocketBindFailed"}
                }
            } else {
                throw {Message: "Error 7: bind failed with error code: " errorCode, What: "SocketBindFailed"}
            }
        }
    }
    
    Listen(backlog := 5) {
        result := DllCall("ws2_32\listen", "UInt", this.socket, "Int", backlog, "Int")
        if result = -1 {
            errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            throw {Message: "Error 8: listen failed with error code: " errorCode, What: "SocketListenFailed"}
        }
    }
    
    Accept() {
        addr := Buffer(16)
        addrLen := Buffer(4)
        NumPut("Int", 16, addrLen)
        
        clientSocket := DllCall("ws2_32\accept", "UInt", this.socket, "Ptr", addr.Ptr, "Ptr", addrLen.Ptr, "UInt")
        if clientSocket = 0xFFFFFFFF {
            errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            if errorCode = 10035
                return 0
            return 0
        }
        
        if !clientSocket
            return 0

        client := {Base: Socket}
        client.socket := clientSocket
        client.ws2_32 := this.ws2_32
        try {
            mode := Buffer(4)
            NumPut("UInt", 0, mode)
            DllCall("ws2_32\ioctlsocket", "UInt", clientSocket, "UInt", 0x8004667E, "Ptr", mode.Ptr, "Int")
        } catch {
        }
        
        return client
    }
    
    Recv(buffer) {
        bytes := DllCall("ws2_32\recv", "UInt", this.socket, "Ptr", buffer.Ptr, "Int", buffer.Size, "Int", 0, "Int")
        if bytes = -1 {
            errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            if errorCode = 10035 || errorCode = 10054
                return 0
            return -1
        }
        if bytes = 0 {
            return 0
        }
        return bytes
    }
    
    Send(data) {
        if Type(data) = "String" {
            bufSize := StrPut(data, "UTF-8")
            buf := Buffer(bufSize)
            StrPut(data, buf, "UTF-8")
            bytes := DllCall("ws2_32\send", "UInt", this.socket, "Ptr", buf.Ptr, "Int", bufSize - 1, "Int", 0, "Int")
            if bytes = -1 {
                errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
                throw {Message: "Error 10: send failed with error code: " . errorCode, What: "SocketSendFailed"}
            }
            return bytes
        } else {
            bytes := DllCall("ws2_32\send", "UInt", this.socket, "Ptr", data.Ptr, "Int", data.Size, "Int", 0, "Int")
            if bytes = -1 {
                errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
                throw {Message: "Error 10: send failed with error code: " . errorCode, What: "SocketSendFailed"}
            }
            return bytes
        }
    }
    
    Close() {
        if this.socket {
            DllCall("ws2_32\closesocket", "UInt", this.socket, "Int")
            this.socket := 0
        }
    }
    
    __Delete() {
        this.Close()
    }
}

; SysGetIPAddresses() is a built-in function in AutoHotkey v2
; No need to implement it manually - just use: addresses := SysGetIPAddresses()


class WebServe {
    __New(port := 8080, host := "localhost", rootDir := "") {
        this.port := port
        this.host := host
        this.rootDir := rootDir
        this.routes := Map()
        this.running := false
    }

    AddRoute(path, handler) {
        this.routes[path] := handler
    }

    Serve() {
        if this.running
            return
        this.running := true
        server := this

        try {
            sock := Socket()
            if !IsObject(sock) || !sock {
                throw {Message: "Error 11: Socket() returned no value. Socket creation failed.", What: "SocketCreationFailed"}
            }
        } catch as err {
            this.running := false
            throw {Message: "Error 12: Failed to create socket: " . (HasProp(err, "Message") ? err.Message : String(err)), What: "SocketError"}
        }

        try {
            sock.SetOption("reuseaddr", true)
        } catch as err {
            this.running := false
            throw {Message: "Error setting socket option: " . (HasProp(err, "Message") ? err.Message : String(err)), What: "SocketOptionError"}
        }

        try {
            mode := Buffer(4)
            NumPut("UInt", 1, mode)
            result := DllCall("ws2_32\ioctlsocket", "UInt", sock.socket, "UInt", 0x8004667E, "Ptr", mode.Ptr, "Int")
            if result = -1 {
                errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            }
        } catch {
        }

        try {
            sock.Bind(this.host, this.port)
        } catch as err {
            this.running := false
            throw {Message: "Error binding to " . this.host . ":" . this.port . ": " . (HasProp(err, "Message") ? err.Message : String(err)), What: "SocketBindError"}
        }

        try {
            sock.Listen()
        } catch as err {
            this.running := false
            throw {Message: "Error listening on socket: " . (HasProp(err, "Message") ? err.Message : String(err)), What: "SocketListenError"}
        }

        this.listener := sock
        this.acceptTimer := ObjBindMethod(this, "_acceptLoop")
        SetTimer(this.acceptTimer, 1)
    }

    Stop() {
        this.running := false
        if HasProp(this, "acceptTimer") && this.acceptTimer
            SetTimer(this.acceptTimer, 0)
        if this.listener
            this.listener.Close()
    }

    _acceptLoop() {
        if !this.running
            return
        
        try {
            if !this.listener || !HasProp(this.listener, "Accept")
                return
            
            client := this.listener.Accept()
            if client && client != 0 {
                clientHandler := ObjBindMethod(this, "_handleClient", client)
                SetTimer(clientHandler, -1)
            }
        } catch as err {
            errorCode := DllCall("ws2_32\WSAGetLastError", "Int")
            if (errorCode != 10035) {
            }
            return
        }
    }

    _handleClient(client) {
        try {
            if !client || !HasProp(client, "Recv")
                return
            
            requestData := ""
            buf := Buffer(4096)
            totalBytes := 0
            maxReads := 20
            reads := 0
            
            bytes := client.Recv(buf)
            if (bytes > 0) {
                requestData := StrGet(buf, bytes, "UTF-8")
                totalBytes := bytes
                
                if !InStr(requestData, "`r`n`r`n") && reads < maxReads {
                    while (reads < maxReads - 1) {
                        bytes := client.Recv(buf)
                        if (bytes <= 0)
                            break
                        chunk := StrGet(buf, bytes, "UTF-8")
                        requestData .= chunk
                        totalBytes += bytes
                        if InStr(requestData, "`r`n`r`n")
                            break
                        reads++
                    }
                }
            } else {
                return
            }
            
            if (totalBytes <= 0 || requestData = "")
                return
            
            lines := StrSplit(requestData, "`n")
            if (lines.Length < 1)
                return
                
            requestLine := lines[1]
            requestLine := StrSplit(requestLine, "`r")[1]
            requestParts := StrSplit(requestLine, " ")
            
            if (requestParts.Length < 2)
                return
                
            method := requestParts[1]
            url := StrSplit(requestParts[2], "?")[1]
            
            if (url = "" || url = "/")
                url := "/"

            if this.routes.Has(url) {
                handler := this.routes[url]
                response := handler(url, method)
                this._sendResponse(client, 200, "application/json", response)
            } else {
                this._serveFile(client, url)
            }
        } catch as err {
            try {
                this._sendResponse(client, 500, "text/plain", "Error 13: Internal Server Error: " . (HasProp(err, "Message") ? err.Message : String(err)))
            } catch {
            }
        } finally {
            Sleep(100)
            try {
                if client && HasProp(client, "Close")
                    client.Close()
            } catch {
            }
        }
    }

    _serveFile(client, url) {
        if (url = "/")
            url := "/index.html"

        filePath := this.rootDir . url
        if !FileExist(filePath) {
            this._sendResponse(client, 404, "text/plain", "Error 14: 404 Not Found")
            return
        }

        ext := RegExReplace(filePath, ".*\.", "")
        mime := this._getMime(ext)

        file := FileOpen(filePath, "r")
        content := file.Read()
        file.Close()

        this._sendResponse(client, 200, mime, content)
    }

    _sendResponse(client, status, contentType, body) {
        if !client || !HasProp(client, "Send")
            return
        
        try {
            bodyBytes := StrPut(body, "UTF-8") - 1
            
            statusText := (status = 200 ? "OK" : status = 404 ? "Not Found" : status = 500 ? "Internal Server Error" : "OK")
            headers := "HTTP/1.1 " . status . " " . statusText . "`r`n"
            headers .= "Content-Type: " . contentType . "; charset=utf-8`r`n"
            headers .= "Content-Length: " . bodyBytes . "`r`n"
            headers .= "Connection: close`r`n"
            headers .= "`r`n"
            
            response := headers . body
            sentBytes := client.Send(response)
            
            Sleep(100)
        } catch as err {
        }
    }

    _getMime(ext) {
        static m := Map(
            "html", "text/html",
            "htm", "text/html",
            "js", "application/javascript",
            "css", "text/css",
            "json", "application/json",
            "png", "image/png",
            "jpg", "image/jpeg",
            "jpeg", "image/jpeg",
            "gif", "image/gif",
            "txt", "text/plain"
        )
        return m.Has(ext) ? m[ext] : "application/octet-stream"
    }
}