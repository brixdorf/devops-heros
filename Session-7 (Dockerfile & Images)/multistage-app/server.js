const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('Hello World from Docker multi-stage build');
});
server.listen(3000, '0.0.0.0');
