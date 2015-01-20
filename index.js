var Read=require('read');
var Promise=require('promise');
var Request = require('request');
var cred={user:'cs1130032',password:false};
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
var regex=/<input name="sessionid" type="hidden" value="([^"]+?)">/i;
var sessid='';

(new Promise(function(next){
        Read({ prompt: 'Username: ', silent: false }, function(er, val) {
            cred.user=val;
            console.log('hello '+val);
            next();
        })
    })
)
.then(function(){
    return new Promise(function(next){
        Read({ prompt: 'Password: ', silent: true }, function(er, val) {
            cred.password=val;
            console.log('pass '+val);
            next();
        })
    })}
)
.then(
    function(){
        console.log("Obtaining Session ID");
        Request('https://proxy22.iitd.ernet.in/cgi-bin/proxy.cgi', function status(error, response, body) {
            if (response.statusCode == 200) {
                sessid=regex.exec(body)[1];
                console.log("Session ID:"+sessid);
            }else{
                console.log("Error obtaining Session ID. Retrying in 2s...");
                setTimeout(request('https://proxy22.iitd.ernet.in/cgi-bin/proxy.cgi',status),2000);
            }
        })
    }
);