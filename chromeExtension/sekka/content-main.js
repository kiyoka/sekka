

function domAddEventListener(element) {
    if (element.addEventListener) {
        element.addEventListener("keydown", keyDownHandler);
    } else if (element.attachEvent) {
        element.attachEvent("onkeydown", keyDownHandler);
    }
}

// add EventListener to oinput/textarea
var g_names = [];
var g_ids = [];
function hookToTextArea() {
    $('input[type=text], textarea').each(
        function (index) {
            var input = $(this);
            var name = input.attr('name');
            var id = input.attr('id');
            if (null != name) {
                g_names.push(name);
            }
            if (null != id) {
                g_ids.push(id);
            }

            domAddEventListener(input.get(0));
        }
    );
}
hookToTextArea();

// call status api on sekka server.
function sekkaRequest_status() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "http://sekka.example.com:12929/status", true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            let text = xhr.responseText;
            if (text.match(/^OK/)) {
                alert("text:" + text);
            }
        }
    };
    xhr.send();
}

function henkanResponseHandler(target, resp, startPos, endPos) {
    let first_entry = resp[0];
    let kanji = first_entry[0];
    let textOfTextarea = $(target).val();
    jutil = new JapaneseUtil();
    let replacedString = jutil.replaceString(textOfTextarea, kanji, startPos, endPos);
    $(target).val(replacedString);

    domutil = new DomUtil();
    domutil.moveToPos(target, startPos + kanji.length);
    //alert("kanji:" + kanji + " startPos:" + startPos + " endPos:" + endPos + "repalced:" + replacedString);
}

// call api on sekka server.
function sekkaRequest(target, apiName, argHash, startPos, endPos) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "http://sekka.example.com:12929/" + apiName, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            let text = xhr.responseText;
            var resp = JSON.parse(text);
            henkanResponseHandler(target, resp, startPos, endPos);
        }
    };

    var formData = new FormData();
    for (key in argHash) {
        formData.append(key, argHash[key]);
    }
    xhr.send(formData);
}

function henkanAction(target, ctrl_key, key_code) {
    domutil = new DomUtil();

    var consumeFlag = false;
    if (ctrl_key && key_code == 74) { // CTRL+J
        jutil = new JapaneseUtil();
        console.log("ctrl+j");
        consumeFlag = true;
        let textOfTextarea = $(target).val();
        let cursorPosition = $(target).prop("selectionStart");
        let [yomi, startPos, endPos] = jutil.takeBeforeCursorAscii(textOfTextarea, cursorPosition);
        sekkaRequest(target,
            'henkan',
            { 'userid': 'kiyoka', 'format': 'json', 'yomi': yomi, 'method': 'normal', 'limit': '0' },
            startPos,
            endPos
        );
    }
    else if (ctrl_key && key_code == 70) { // CTRL+F
        console.log("ctrl+f");
        consumeFlag = true;
        domutil.moveForward(target);
    }
    else if (ctrl_key && key_code == 66) { // CTRL+B
        console.log("ctrl+b");
        consumeFlag = true;
        domutil.moveBackward(target);
    }
    return consumeFlag;
}

// key down handing for input/textare
function keyDownHandler(e) {
    let hit = false;
    let target = $(e.target);

    $.each(g_names, function () {
        if (this == target.attr('name')) {
            //alert("hit:" + this);
            hit = true;
        }
    });
    $.each(g_ids, function () {
        if (this == target.attr('id')) {
            //alert("hit:" + this);
            hit = true;
        }
    });

    if (hit) {
        var key_code = e.keyCode;
        var shift_key = e.shiftKey;
        var ctrl_key = e.ctrlKey;
        var alt_key = e.altKey;

        if (false) {
            console.log("code:" + key_code);
            console.log("shift:" + shift_key);
            console.log("ctrl" + ctrl_key);
            console.log("alt:" + alt_key);
        }

        if (henkanAction(target, ctrl_key, key_code)) {
            e.preventDefault();
            e.stopPropagation();
        }
    }
}
