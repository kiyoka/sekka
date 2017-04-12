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

function JapaneseUtil() {

}

// 文字列の最後のアスキー文字列を取得する
JapaneseUtil.prototype.takeLastAscii = function (srcString) {
    let reString = /([/]?[0-9a-zA-Z.?,-]+)$/;
    let arrayString = srcString.match(reString)
    if (arrayString) {
        return arrayString[1]
    }
    else {
        return ""
    }
}

// 文字列せ先の '/' を取る
JapaneseUtil.prototype.trimSlash = function (srcString) {
    let reString = /^[/]/;
    let arrayString = srcString.match(reString)
    if (arrayString) {
        return srcString.substring(1)
    }
    else {
        return srcString;
    }
}

// カーソルの直前のアスキー文字列を取得する
// ret = ['ASCIIよりも前の文字列', 'ASCII文字列',開始位置,終了位置]
JapaneseUtil.prototype.takePrevCursorAscii = function (srcString, cursorPosition) {
    let prevCursorString = srcString.substring(0, cursorPosition);
    let ascii = this.takeLastAscii(prevCursorString);
    let prevAsciiString = prevCursorString.substring(0, prevCursorString.length - ascii.length);
    return [prevAsciiString, ascii, prevCursorString.length - ascii.length, prevCursorString.length];
}

// origStringのstartPosからendPosまでの文字列をreplaceStringで置換する
JapaneseUtil.prototype.replaceString = function (origString, replaceString, startPos, endPos) {
    let prevStr = origString.substring(0, startPos);
    let nextStr = origString.substring(endPos, origString.length);
    let ret = prevStr + replaceString + nextStr;
    return ret;
}

// カーソル位置の前と後ろの２つの文字列を返す
JapaneseUtil.prototype.takePrevNextString = function (srcString, cursorPosition) {
    let prevString = srcString.substring(0, cursorPosition);
    let nextString = srcString.substring(cursorPosition)
    return [prevString, nextString];
}
