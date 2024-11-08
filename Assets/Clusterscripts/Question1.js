const requestMeta = "Question1"; // 文字列いれておく （requestTextInputを識別するために使う）
let output = "OITVL研のX(旧Twitter)アイコンにいるボーカロイドは誰でしょうか？(「わからない」でヒント)";  //問題文となるところ
const StartBottom = ["初音ミク","わからない","helpme"];  //回答を入れる場所

$.onTextInput((text, meta, status) => {
    switch (status) {
        case TextInputStatus.Success:
            if (meta === requestMeta) {
                // 「初音ミク」と完全一致するか、「みく」「ミク」「miku」が部分一致している場合に正解
                if (text === StartBottom[0] || text.includes("みく") || text.includes("ミク") || text.toLowerCase().includes("miku")) {
                    $.sendSignalCompat("owner", "Quiz1");
                    $.sendSignalCompat("owner", "Nice");
                    $.sendSignalCompat("this", "tap1");
                } else if (text === StartBottom[1] || text === StartBottom[2]) {
                    // 「わからない」または「helpme」の場合
                    $.sendSignalCompat("owner", "HelpBottom");
                    $.sendSignalCompat("this", "tap1");
                } else {
                    // 不正解の場合
                    $.sendSignalCompat("owner", "Bad");
                    $.sendSignalCompat("this", "tap1");
                }
            }
        break;
        
        case TextInputStatus.Busy:
            // プレイヤーが文字列の入力ができない場合
            $.log('現在文字入力ができません。');
            $.sendSignalCompat("this", "tap1");
        break;
        
        case TextInputStatus.Refused:
            // 拒否された場合
            $.log('Text入力が拒否されました。');
            $.sendSignalCompat("this", "tap1");
        break;
    }
});

$.onInteract(player => {
    $.sendSignalCompat("this", "tap1");
    let count = $.getStateCompat("global","count1","integer");  // ここでcountを定義
        try {
            $.state.player = player; // プレイヤーオブジェクトを保存
            player.requestTextInput(requestMeta, output);
            $.log(`あなたの入力は全体で、${count}回目です。`);
        } catch (e) {
            $.log(e); // エラーをログ出力
        }
});
