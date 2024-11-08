const requestMeta = "Question2"; // 文字列いれておく （requestTextInputを識別するために使う）
let output = "問題です!! OITVL研のVL研は正式名で言うとなんというでしょうか？(「わからない」でヒント)";  //問題文となるところ
const StartBottom = ["バーチャルライブ研究会","わからない","helpme"];  //回答を入れる場所

$.onTextInput((text, meta, status) => {
    switch (status) {
        case TextInputStatus.Success:
            if (meta === requestMeta) {
                // 「バーチャルライブ研究会」と完全一致するか、「バーチャルライブ」が部分一致している場合に正解
                if (text === StartBottom[0] || text.includes("バーチャルライブ")) {
                    $.sendSignalCompat("owner", "Quiz2");
                    $.sendSignalCompat("owner", "Nice");
                    $.sendSignalCompat("this", "tap2");
                } else if (text === StartBottom[1] || text === StartBottom[2]) {
                    // 「わからない」または「helpme」の場合
                    $.sendSignalCompat("owner", "HelpBottom");
                    $.sendSignalCompat("this", "tap2");
                } else {
                    // 不正解の場合
                    $.sendSignalCompat("owner", "Bad");
                    $.sendSignalCompat("this", "tap2");
                }
            }     
        break;
        
        case TextInputStatus.Busy:
            // プレイヤーが文字列の入力ができない場合
            $.log('現在文字入力ができません。');
            $.sendSignalCompat("this", "tap2");
        break;
        
        case TextInputStatus.Refused:
            // 拒否された場合
            $.log('Text入力が拒否されました。');
            $.sendSignalCompat("this", "tap2");
        break;
    }
});

$.onInteract(player => {
    $.sendSignalCompat("this", "tap2");
    let count = $.getStateCompat("global","count2","integer");
        try {
            $.state.player = player; // プレイヤーオブジェクトを保存
            player.requestTextInput(requestMeta, output);
            $.log(`あなたの入力は全体で、${count}回目です。`);
        } catch (e) {
            $.log(e); // エラーをログ出力
        }
});
