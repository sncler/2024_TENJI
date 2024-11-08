const subNode = $.subNode("textObj");

const updatePerSec = 1; //何秒に一度チェックするか？
const distance = 3; //何ｍ以内に来たらあいさつするか？

function initProc() {
  $.state.isInitialized = true;
  $.state.tick = 0;
}

$.onUpdate((deltaTime) => {
  //初期化処理
  if (!$.state.isInitialized) {
    initProc();
  }

  //一定間隔でしか更新しない
  $.state.tick += deltaTime;
  if($.state.tick < updatePerSec) return;
  $.state.tick -= updatePerSec;

  let str = "";
  //近くのプレイヤーの一覧を取得
  $.getPlayersNear($.getPosition(), distance).forEach((player) => {
    //そのユーザーの名前＋あいさつをstrに追加していく
    let userDisplayName = player.userDisplayName;
    str += userDisplayName + "\nおはよう～(≧▽≦)";
  });

  subNode.setText(str);

});