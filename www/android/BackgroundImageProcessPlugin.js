var backgroundimageprocess = {
	uploadPhotos: function(success, fail, params){
		cordova.exec(success, fail, "UploadFile", "upload",params);
	},
    downloadPhotos: function(success, fail, params){
        cordova.exec(success, fail, "DownloadFile", "download",params);
    }
}

module.exports = backgroundimageprocess;