
const SEKKA_URL = 'http://sekka.example.com:12929/';

function httpRequest_status() {
    var ret;
    jQuery.ajax({
        url: SEKKA_URL + 'status',
        success: function (result) {
            ret = { api: 'status', result: result }
        },
        async: false
    });
    return ret;
}

function httpRequest_api(apiname, argHash, sendResponse) {
    var formData = new FormData();
    for (key in argHash) {
        formData.append(key, argHash[key]);
    }

    var ret;
    jQuery.ajax({
        type: 'POST',
        url: SEKKA_URL + apiname,
        success: function (result) {
            var obj = JSON.parse(result);
            ret = { api: apiname, result: obj }
        },
        data: formData,
        contentType: false,
        processData: false,
        async: false
    });
    return ret;
}

chrome.runtime.onMessage.addListener(
    function (request, sender, sendResponse) {
        console.log(sender.tab ?
            "from a content script:" + sender.tab.url :
            "from the extension");
        if (request.api == "henkan") {
            let result = httpRequest_api(request.api, request.argHash);
            sendResponse(result);
        }
        else if (request.api == "status") {
            let result = httpRequest_status();
            sendResponse(result);
        }
    });
