var Read=require('read');
var Promise=require('promise');
var Request = require('request');
var cred={};
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

new Promise(function(next){
    Read({ prompt: 'Username: ', silent: false }, function(er, val) {
        cred.user=val;
        next();
    })
})
.then(function(){
    return new Promise(function(next){
        Read({ prompt: 'Password: ', silent: true }, function(er, val) {
            cred.password=val;
            next();
        });
    });
})
.then(function(){
    return new Promise(function getsessid(next){
        console.log("Obtaining Session ID");
        Request({url:'https://proxy22.iitd.ernet.in/cgi-bin/proxy.cgi',timeout:3000}, function (error, response, body) {
            if(error){
                console.log(error,"\nRetrying in 2s...");
                setTimeout(getsessid(next),2000);
            }else{
                cred.sessid=/"sessionid".+?value="([^"]+?)">/i.exec(body)[1];
                console.log("Session ID:"+sessid);
                next();
            }
        });
    });
})
.then(function(){
    return new Promise(function login(next){
        next();
    });
});