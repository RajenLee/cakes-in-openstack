
Aodh alarm NOTIFIER
===================

::
  
  alarm_actions URL: http://<host>/<action>
  
NOTIFIER will resolve the URL and post the data to **http server**
    
setup a Http server
-------------------

* HttpServer: SimpleHTTPServer

  ::
    
    python -m SimpleHTTPServer 8000
  
  link: https://docs.python.org/2/library/simplehttpserver.html
      
  NOTE: this case only receive the posted data, but not handle it.

* HttpServer: HttpServer
  
  ::
    
    stack@stack:~$ cat reflect.py 
    #!/usr/bin/env python
    # Reflects the requests from HTTP methods GET, POST, PUT, and DELETE
    # Written by Nathan Hamiel (2010)
    
    from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
    from optparse import OptionParser
    
    class RequestHandler(BaseHTTPRequestHandler):
        
        def do_GET(self):
            
            request_path = self.path
            
            print("\n----- Request Start ----->\n")
            print(request_path)
            print(self.headers)
            print("<----- Request End -----\n")
            
            self.send_response(200)
            self.send_header("Set-Cookie", "foo=bar")
            
        def do_POST(self):
            
            request_path = self.path
            
            print("\n----- Request Start ----->\n")
            print(request_path)
            
            request_headers = self.headers
            content_length = request_headers.getheaders('content-length')
            length = int(content_length[0]) if content_length else 0
            
            print(request_headers)
            print(self.rfile.read(length))
            print("<----- Request End -----\n")
            
            self.send_response(200)
        
        do_PUT = do_POST
        do_DELETE = do_GET
            
    def main():
        port = 8000
        print('Listening on localhost:%s' % port)
        server = HTTPServer(('0.0.0.0', port), RequestHandler)
        server.serve_forever()
    
            
    if __name__ == "__main__":
        parser = OptionParser()
        parser.usage = ("Creates an http-server that will echo out any GET or POST parameters\n"
                        "Run:\n\n"
                        "   reflect")
        (options, args) = parser.parse_args()
        
        main()
