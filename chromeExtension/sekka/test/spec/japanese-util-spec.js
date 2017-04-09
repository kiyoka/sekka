describe('JapaneseUtil', function () {
  var jutil;

  beforeEach(function () {
    jutil = new JapaneseUtil();
  });

  describe('takeLastAscii used', function () {
    it('/ なし(1)', function () {
      expect(jutil.takeLastAscii('000abc')).toEqual('abc');
    });
    it('/ なし(2)', function () {
      expect(jutil.takeLastAscii('あいうabc')).toEqual('abc');
    });
    it('/ なし(3)', function () {
      expect(jutil.takeLastAscii('あいう.')).toEqual('.');
    });
    it('/ あり(1)', function () {
      expect(jutil.takeLastAscii('xxx/abc')).toEqual('abc');
    });
    it('/ あり(2)', function () {
      expect(jutil.takeLastAscii('xxx/Ka-do')).toEqual('Ka-do');
    });
    it('alphabetなし', function () {
      expect(jutil.takeLastAscii('あいう')).toEqual('');
    });
  });

  describe('takeBeforeCursorAscii used', function () {
    it('/ なし(1)', function () {
      expect(jutil.takeBeforeCursorAscii('000abc   ', 6)).toEqual(['abc',3,6]);
    });
    it('/ なし(2)', function () {
      expect(jutil.takeBeforeCursorAscii("あいうabc \n  ", 6)).toEqual(['abc',3,6]);
    });
    it('alphabetなし', function () {
      expect(jutil.takeBeforeCursorAscii('あいう    ', 3)).toEqual(['',3,3]);
    });
  });

  describe('replaceString used', function () {
    it('文字列の最後を置換', function () {
      expect(jutil.replaceString('000Kanji','漢字',3,8)).toEqual('000漢字');
    });
    it('文字列の最初を置換', function () {
      expect(jutil.replaceString("Nihongo\n  ","日本語",0,7)).toEqual("日本語\n  ");
    });
    it('文字の真ん中を置換', function () {
      expect(jutil.replaceString('   a   ','あ',3,4)).toEqual('   あ   ');
    });
    it('1文字を1文字に置換', function () {
      expect(jutil.replaceString('a','あ',0,1)).toEqual('あ');
    });
  });

});
