const http = require('http');
http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('Hello World from Node.js');
}).listen(3000, '0.0.0.0');
