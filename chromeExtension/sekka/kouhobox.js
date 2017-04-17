
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

// コンストラクタ
var KouhoBox = function (jsonObject, origText, headText, yomi, tailText, origPos) {
    this.jsonObject = jsonObject;
    this.origText = origText; // for Undo
    this.headText = headText;
    this.yomi = yomi;
    this.tailText = tailText;
    this.origPos = origPos;

    this.index = 0; // 第一候補を指しておく
}

// 変換候補の文字列リストを返す(但し、アルファベットの候補は外す)
KouhoBox.prototype.getKouhoList = function () {
    const reString = /^[0-9a-zA-Z.?,-]+$/;
    let list = [];
    for (entry of this.jsonObject) {
        let nihongo = entry[0];
        if (!nihongo.match(reString)) {
            list.push(nihongo);
        }
    }
    return list;
}

// 変換前のテキスト全体を返す
KouhoBox.prototype.getOrigText = function () {
    return this.origText;
}

// 変換前のカーソル位を返す
KouhoBox.prototype.getOrigPos = function () {
    return this.origPos;
}

// 変換直後の状態かどうかを返す
KouhoBox.prototype.isSelectingPos = function (prevText) {
    let kouhoList = this.getKouhoList();
    let found = false;
    jQuery.each(kouhoList, function (i, kouho) {
        //console.log('kouho:' + kouho)
        let re = new RegExp(kouho + '$');
        if (re.test(prevText)) {
            found = true;
        }
    });
    return found;
}

// オリジナルテキスト、前方、読み、後方の4つのテキストを返す
KouhoBox.prototype.getTextSet = function () {
    return [this.origText, this.headText, this.yomi, this.tailText];
}

// 次の候補文字列を返す
KouhoBox.prototype.getNextKouho = function () {
    this.index++;
    let list = this.getKouhoList();
    if (list.length <= this.index) {
        this.index = 0;
    }
    return list[this.index];
}

// 現在選択中の候補番号を取得する
KouhoBox.prototype.getIndex = function () {
    return this.index;
}

