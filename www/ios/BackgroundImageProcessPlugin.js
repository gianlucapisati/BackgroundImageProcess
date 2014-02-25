var backgroundimageprocess = {
	uploadPhotos: function(success, fail){
		cordova.exec(success, fail, "BackgroundImageProcess", "uploadPhotos",[]);
	},

}

module.exports = backgroundimageprocess;