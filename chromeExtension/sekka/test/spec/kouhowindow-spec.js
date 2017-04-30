describe('KouhoWindow', function () {
    let kouhoWindow;

    beforeEach(function () {
        kouhoWindow = new KouhoWindow();
    });

    describe('proof of singleton', function () {
        it('second instance', function () {
            kouhoWindow2 = new KouhoWindow();
            let dateStr1 = kouhoWindow.getCreateDateString();
            let dateStr2 = kouhoWindow2.getCreateDateString();
            expect(dateStr1).toEqual(dateStr2);
        });
    });
});
