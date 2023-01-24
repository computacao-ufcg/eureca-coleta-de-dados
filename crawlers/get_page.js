var request = require('request');
var fs = require('fs');
var proc = require('process');

var argv = require('minimist')(process.argv.slice(2));

// parsing arguments
if (!("login" in argv)) {
    console.log('missing login properties file!');
    console.log('usage: node get_page.js --l=link --p=periodo --o=output.html --login=login.properties');
    console.log('example of login.properties: login,password,CoordenacaoLogin');
    proc.exit();
}
else {
    login_properties = argv['login'];
}

var output_file = "main.html";
if (!("o" in argv)) {
    console.log("missing --o option. content will be save on ./main.html.");
} else {
     output_file = argv['o'];
}

var periodo = "2018.2";
if (!("p" in argv)) {
    console.log("Using default term 2018.2.");
} else {
     periodo = argv['p'];
}

var page = "";
if (!("l" in argv)) {
    console.log("missing --l option. what page should I get?");
    console.log("usage: node get_page.js --l=link --p=periodo --o=output.html --login=login.properties");
    proc.exit();
} else {
     page = argv['l'];
}


// isso que faz ele nao rejeitar uma requisicao com erro de certificado
var request = request.defaults({
  strictSSL: false,
  rejectUnauthorized: false
});

properties = fs.readFileSync(login_properties, 'utf8');
data = properties.split(',');

const user = data[0];
const password = data[1];
const command_str = data[2].replace('\n', '');

var options = { method: 'POST',
                url: 'https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador',
                jar: true,
                headers: 
                { 'content-type': 'application/x-www-form-urlencoded',
                  'postman-token': '42a2ce0c-350e-630f-1956-54f2da81e305',
                  'cache-control': 'no-cache' },
                  form: { login: user  , senha: password, command: command_str },
              };

// post em 

request(options, function (error, response, body) {
    var op = { method: 'POST',
                url: 'https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador',
                jar: true,
                form: {
                  "command": "PeriodoSelecionar",
                  "selectPeriodo" : periodo,
                },
                headers:
                {
                  'content-type': 'application/x-www-form-urlencoded',
                  'postman-token': '42a2ce0c-350e-630f-1956-54f2da81e305',
                  'cache-control': 'no-cache'
                }
              };
    
    var res = {};
    
    request(op, function (erro, resposta, corpo) {
              
                
                var op = { method: 'GET',
                  url: page,
                  jar: true,

                headers:
                {
                  'content-type': 'application/x-www-form-urlencoded',
                  'postman-token': '42a2ce0c-350e-630f-1956-54f2da81e305',
                  'cache-control': 'no-cache'
                }
              };
    
              var res = {};
              request(op, function (erro, resposta, corpo) {
                          fs.writeFileSync(output_file, corpo, 'ascii');
                          proc.exit();
              });
              


    });
    
});

