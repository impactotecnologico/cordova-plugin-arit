var exec = require('cordova/exec');

function plugin() {

}

plugin.prototype.ARActivity = function(layout) {
    console.log(layout);
    exec(function(res){}, function(err){}, "ARPlugin", layout, []);
}

module.exports = new plugin();
