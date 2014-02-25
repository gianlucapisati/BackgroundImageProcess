var backgroundimageprocess = {
	backgroundimageprocess: function(success, fail){
		cordova.exec(success, fail, "CDVBackgroundImageProcess", "backgroundimageprocess");
	},

}

module.exports = backgroundimageprocess;