var backgroundimageprocess = {
	uploadPhotos: function(success, fail){
		cordova.exec(success, fail, "BackgroundImageProcess", "uploadPhotos",[]);
	},
    downloadPhotos: function(success, fail){
        cordova.exec(success, fail, "BackgroundImageProcess", "downloadPhotos",[]);
    }

}

module.exports = backgroundimageprocess;