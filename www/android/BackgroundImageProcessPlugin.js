var backgroundimageprocess = {
	uploadPhotos: function(success, fail, params){
		cordova.exec(success, fail, "BackgroundImageProcess", "upload",params);
	},
    downloadPhotos: function(success, fail, params){
        cordova.exec(success, fail, "BackgroundImageProcess", "download",params);
    }
}

module.exports = backgroundimageprocess;