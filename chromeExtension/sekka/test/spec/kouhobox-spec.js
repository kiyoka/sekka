describe('KouhoBox', function () {
    let kouhobox;

    beforeEach(function () {
        kouhobox = new KouhoBox(
            [
                ["返還", false, "へんかん", 'j', 0],
                ["変換", false, "へんかん", 'j', 1],
                ["変化", false, "へんか", 'j', 2],
                ["Henkan", false, "へんかん", 'j', 3]
            ],
            "漢字Henkanする",
            "漢字",
            "Henkan",
            "する"
        )
    });

    describe('getter', function () {
        it('4つのテキスト', function () {
            expect(kouhobox.getTextSet()).toEqual(["漢字Henkanする", "漢字", "Henkan", "する"]);
        });
    });
    describe('変換候補の返却', function () {
        it('変換候補リスト', function () {
            expect(kouhobox.getKouhoList()).toEqual(["返還", "変換", "変化"])
        });
        it('次の変換候補(1)', function () {
            expect(kouhobox.getNextKouho()).toEqual("変換")
        });
        it('次の変換候補(2)', function () {
            kouhobox.getNextKouho();
            expect(kouhobox.getNextKouho()).toEqual("変化")
        });
        it('次の変換候補(3)', function () {
            kouhobox.getNextKouho();
            kouhobox.getNextKouho();
            expect(kouhobox.getNextKouho()).toEqual("返還")
        });
    });
    describe('カーソル位置の状態調査', function () {
        it('オリジナルテキスト', function () {
            expect(kouhobox.getOrigText()).toEqual("漢字Henkanする");
        });
        it('変換直後の状態か調査(1)', function () {
            expect(kouhobox.isSelectingPos('漢字返還')).toEqual(true);
        });
        it('変換直後の状態か調査(2)', function () {
            expect(kouhobox.isSelectingPos('漢字変換')).toEqual(true);
        });
        it('変換直後の状態か調査(3)', function () {
            expect(kouhobox.isSelectingPos('漢字変化')).toEqual(true);
        });
        it('変換直後の状態か調査(4)', function () {
            expect(kouhobox.isSelectingPos('漢字Henkan')).toEqual(false);
        });
        it('変換直後の状態か調査(5)', function () {
            expect(kouhobox.isSelectingPos('')).toEqual(false);
        });
    });

});
