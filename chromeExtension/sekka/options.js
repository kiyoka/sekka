// save options to chrome.storage

function save_options() {
    let url1 = document.getElementById('url1').value;
    let url2 = document.getElementById('url2').value;
    let url3 = document.getElementById('url3').value;
    let username = document.getElementById('username').value;
    let index = 0;
    if (document.getElementById('radiourl1').checked) { index = 0; }
    if (document.getElementById('radiourl2').checked) { index = 1; }
    if (document.getElementById('radiourl3').checked) { index = 2; }
    chrome.storage.sync.set({
        url1: url1,
        url2: url2,
        url3: url3,
        username: username,
        index: index,
    }, function () {
        let status = document.getElementById('status');
        status.textContent = 'Options saved.';
        setTimeout(function () {
            status.textContent = '';
        }, 1000);
    });
}

function restore_options() {
    chrome.storage.sync.get({
        url1: "http://localhost:12929/",
        url2: "http://sekka.example.com:12929/",
        url3: "",
        username: "chrome",
        index: 0
    }, function (items) {
        document.getElementById('url1').value = items.url1;
        document.getElementById('url2').value = items.url2;
        document.getElementById('url3').value = items.url3;
        document.getElementById('username').value = items.username;
        switch (items.index) {
            case 0:
                document.getElementById('radiourl1').checked = true;
                break;
            case 1:
                document.getElementById('radiourl2').checked = true;
                break;
            case 2:
                document.getElementById('radiourl3').checked = true;
                break;
        }
    });
}

// call status api on sekka server.
function sekkaRequest_status() {
    let url = "";
    if (document.getElementById('radiourl1').checked) { url = document.getElementById('url1').value; }
    if (document.getElementById('radiourl2').checked) { url = document.getElementById('url2').value; }
    if (document.getElementById('radiourl3').checked) { url = document.getElementById('url3').value; }
    let status = document.getElementById('status');
    status.textContent = 'connecting...';
    chrome.runtime.sendMessage({ baseUrl: url, api: "status" }, function (response) {
        if (null == response) {
            status.textContent = 'NG';
            setTimeout(function () { status.textContent = '';}, 1000);
        }
        else {
            status.textContent = 'OK';
            setTimeout(function () { status.textContent = '';}, 1000);
        }
    });
}

document.addEventListener('DOMContentLoaded', restore_options);
document.getElementById('save').addEventListener('click', save_options);
document.getElementById('connect').addEventListener('click', sekkaRequest_status);
