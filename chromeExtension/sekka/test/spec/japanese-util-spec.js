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
      expect(jutil.takeLastAscii('xxx/abc')).toEqual('/abc');
    });
    it('/ あり(2)', function () {
      expect(jutil.takeLastAscii('xxx/Ka-do')).toEqual('/Ka-do');
    });
    it('alphabetなし', function () {
      expect(jutil.takeLastAscii('あいう')).toEqual('');
    });
  });

  describe('trimSlash used', function () {
    it('/ なし', function () {
      expect(jutil.trimSlash('abc')).toEqual('abc');
    });
    it('/ あり', function () {
      expect(jutil.trimSlash('/abc')).toEqual('abc');
    });
  });

  describe('takePrevCursorAscii used', function () {
    it('/ なし(1)', function () {
      expect(jutil.takePrevCursorAscii('000abc   ', 6)).toEqual(['000', 'abc', 3, 6]);
    });
    it('/ なし(2)', function () {
      expect(jutil.takePrevCursorAscii("あいうabc \n  ", 6)).toEqual(['あいう', 'abc', 3, 6]);
    });
    it('alphabetなし', function () {
      expect(jutil.takePrevCursorAscii('あいう    ', 3)).toEqual(['あいう', '', 3, 3]);
    });
  });

  describe('replaceString used', function () {
    it('文字列の最後を置換', function () {
      expect(jutil.replaceString('000Kanji', '漢字', 3, 8)).toEqual('000漢字');
    });
    it('文字列の最初を置換', function () {
      expect(jutil.replaceString("Nihongo\n  ", "日本語", 0, 7)).toEqual("日本語\n  ");
    });
    it('文字の真ん中を置換', function () {
      expect(jutil.replaceString('   a   ', 'あ', 3, 4)).toEqual('   あ   ');
    });
    it('1文字を1文字に置換', function () {
      expect(jutil.replaceString('a', 'あ', 0, 1)).toEqual('あ');
    });
  });

  describe('takePrevNextString used', function () {
    it('前後あり', function () {
      expect(jutil.takePrevNextString('000abc', 3)).toEqual(['000', 'abc']);
    });
    it('行頭', function () {
      expect(jutil.takePrevNextString('あいうabc', 0)).toEqual(['', 'あいうabc']);
    });
    it('行末', function () {
      expect(jutil.takePrevNextString('abcdef', 6)).toEqual(['abcdef', '']);
    });
  });

});
