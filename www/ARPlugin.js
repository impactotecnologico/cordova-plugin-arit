var exec = require('cordova/exec');

function plugin() {

}

plugin.prototype.ARActivity = function(layout,jsonURL) {
    console.log(layout);
    console.log(jsonURL);
    exec(function(res){}, function(err){}, "ARPlugin", layout, [jsonURL]);
}

module.exports = new plugin();
