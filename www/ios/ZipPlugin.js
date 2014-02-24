var extractzip = {
	unzip: function(file, success, fail){
		cordova.exec(success, fail, "CDVUnzipper", "unzip", file);
	},

	zip: function(folder, success, fail){
		cordova.exec(success, fail, "CDVZipper", "zip", folder);
	}
}

module.exports = extractzip;