var backgroundimageprocess = {
	backgroundimageprocess: function(success, fail){
		cordova.exec(success, fail, "BackgroundImageProcess", "backgroundimageprocess",[]);
	},

}

module.exports = backgroundimageprocess;