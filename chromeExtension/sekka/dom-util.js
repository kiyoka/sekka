
function DomUtil() {

}

DomUtil.prototype.moveForward = function (target) {
    this.moveOffset(target, 1)
}

DomUtil.prototype.moveBackward = function (target) {
    this.moveOffset(target, -1)
}

DomUtil.prototype.moveOffset = function (target, offset) {
    let cursorPosition = $(target).prop("selectionStart");
    let elem = target[0];
    let targetPosition = cursorPosition + offset;
    this.moveToPos(target, targetPosition);
}

DomUtil.prototype.moveToPos = function (target, targetPosition) {
    let cursorPosition = $(target).prop("selectionStart");
    let elem = target[0];
    if (elem.setSelectionRange) {
        elem.setSelectionRange(targetPosition, targetPosition);
    } else if (elem.selectionStart) {
        elem.selectionStart = targetPosition;
        elem.selectionEnd = targetPosition;
    } else if (elem.createTextRange) {
        var range = elem.createTextRange();
        range.collapse(true);
        range.moveEnd('character', targetPosition);
        range.moveStart('character', targetPosition);
        range.select();
    }
}
