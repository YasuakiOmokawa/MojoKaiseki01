var system = require("system");
var username = system.args[1];
var password = system.args[2];


var page = require("webpage").create();
page.open("https://accounts.google.com/ServiceLogin?service=analytics&passive=true&nui=1&hl=ja&continue=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja&followup=https%3A%2F%2Fwww.google.com%2Fanalytics%2Fweb%2F%3Fhl%3Dja",function(){
    page.onLoadFinished = function(){
        page.render("facebook_login.png");
        phantom.exit();
    }

    page.onConsoleMessage = function(msg){
        console.log(msg);
    }

    page.evaluate(function(arr){
        document.querySelector("#Email").value = arr[0];
        document.querySelector("#Passwd").value = arr[1];
        document.querySelector("#gaia_loginform").submit(); //フォームのID
    },[username,password]);
})