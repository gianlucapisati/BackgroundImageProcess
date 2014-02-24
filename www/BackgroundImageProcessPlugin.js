var extractzip = {
	unzip: function(file, success, fail){
		cordova.exec(success, fail, "ExtractZipFilePlugin", "unzip", file);
	},

	zip: function(folder, success, fail){
		cordova.exec(success, fail, "CreateZipFilePlugin", "zip", folder);
	}
}

module.exports = extractzip;