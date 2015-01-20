var Read=require('read');
var Promise=require('promise');
var Request = require('request');
var cred={user:'cs1130032',password:false};
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
var regex=/"sessionid".+?value="([^"]+?)">/i;
var sessid='';

(new Promise(function(next){
        Read({ prompt: 'Username: ', silent: false }, function(er, val) {
            cred.user=val;
            next();
        })
    })
)
.then(function(){
    return new Promise(function(next){
        Read({ prompt: 'Password: ', silent: true }, function(er, val) {
            cred.password=val;
            next();
        })
    })}
)
.then(
    function getsessid(){
        console.log("Obtaining Session ID");
        Request({url:'https://proxy22.iitd.ernet.in/cgi-bin/proxy.cgi',timeout:3000}, function (error, response, body) {
            if(error){
                console.log("Error obtaining Session ID.",error,"Retrying in 2s...");
                setTimeout(getsessid,2000);
            }else{
                sessid=regex.exec(body)[1];
                console.log("Session ID:"+sessid);
            }
        })
    }
);