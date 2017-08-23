//
//   Copyright (c) 2017  Kiyoka Nishiyama  <kiyoka@sumibi.org>
//
//   Redistribution and use in source and binary forms, with or without
//   modification, are permitted provided that the following conditions
//   are met:
//
//   1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//   3. Neither the name of the authors nor the names of its contributors
//      may be used to endorse or promote products derived from this
//      software without specific prior written permission.
//
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

// 疎通確認
function httpRequest_status(baseUrl) {
    let ret;
    jQuery.ajax({
        type: 'GET',
        url: baseUrl + 'status',
        success: function (result) {
            ret = { api: 'status', result: result }
        },
        async: false
    });
    return ret;
}

// api呼び出し
function httpRequest_api(baseUrl, apiname, argHash, sendResponse) {
    let formData = new FormData();
    for (key in argHash) {
        formData.append(key, argHash[key]);
    }
    let starttime = new Date();
    let ret;
    jQuery.ajax({
        type: 'POST',
        url: baseUrl + apiname,
        success: function (result) {
            let obj = JSON.parse(result);
            ret = { api: apiname, result: obj }
        },
        data: formData,
        contentType: false,
        processData: false,
        async: false
    });
    let endime = new Date();
    console.log("httpRequest_api(" + baseUrl + apiname + ") " + (endime - starttime) + "ms")
    return ret;
}

chrome.runtime.onMessage.addListener(
    function (request, sender, sendResponse) {
        console.log(sender.tab ?
            "from a content script:" + sender.tab.url :
            "from the extension");
        if (request.api == "henkan") {
            let result = httpRequest_api(request.baseUrl, request.api, request.argHash);
            sendResponse(result);
        }
        else if (request.api == "kakutei") {
            let result = httpRequest_api(request.baseUrl, request.api, request.argHash);
            sendResponse(result);
        }
        else if (request.api == "status") {
            let result = httpRequest_status(request.baseUrl);
            sendResponse(result);
        }
    });
