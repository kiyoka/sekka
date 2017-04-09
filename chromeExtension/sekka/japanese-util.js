function JapaneseUtil() {

}

// 文字列の最後のアスキー文字列を取得する
JapaneseUtil.prototype.takeLastAscii = function (srcString) {
    let reString = /([a-zA-Z.-]+)$/;
    let arrayString = srcString.match(reString)
    if (arrayString) {
        return arrayString[1]
    }
    else {
        return ""
    }
}

// カーソルの直前のアスキー文字列を取得する
// ret = ['ASCII文字列',開始位置,終了位置]
JapaneseUtil.prototype.takeBeforeCursorAscii = function (srcString, cursorPosition) {
    let beforeCursorString = srcString.substring(0, cursorPosition);
    let ascii = this.takeLastAscii(beforeCursorString);
    return [ascii, beforeCursorString.length - ascii.length, beforeCursorString.length];
}

// origStringのstartPosからendPosまでの文字列をreplaceStringで置換する
JapaneseUtil.prototype.replaceString = function (origString, replaceString, startPos, endPos) {
    let prevStr = origString.substring(0, startPos);
    let nextStr = origString.substring(endPos, origString.length);
    let ret = prevStr + replaceString + nextStr;
    return ret;
}


