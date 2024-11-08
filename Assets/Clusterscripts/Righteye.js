const force = 30;
const maxDistance = 10;  // 最大距離
const minDistance = 1;   // 最小距離
const maxAngleY = 25;    // Y軸（左右）のオブジェクト回転制御範囲
const maxAngleZ = 20;    // Z軸（上下）のオブジェクト回転制御範囲
const maxDetectionAngleY = 60;  // プレイヤーのY軸（左右）判定範囲
const maxDetectionAngleZ = 60;  // プレイヤーのZ軸（上下）判定範囲
const rotationSpeed = 5; // 回転速度（アニメーションのスピード）
const resetDelay = 2;    // 判定外に出た後に回転をリセットするまでの時間（秒）

const rad2deg = (rad) => rad * 180 / Math.PI;

let currentRotationY = 0; // 現在のY軸回転角度
let currentRotationZ = 0; // 現在のZ軸回転角度
let lastDetectedTime = 0; // 最後にプレイヤーが検出された時間

// プレイヤーが現在の方向の左右方向かどうかを判定する関数（Y軸）
const isPlayerInDetectionRangeY = (angle) => {
    return angle >= -maxDetectionAngleY && angle <= maxDetectionAngleY;
};

// プレイヤーが現在の方向の上下方向かどうかを判定する関数（Z軸）
const isPlayerInDetectionRangeZ = (angle) => {
    return angle >= -maxDetectionAngleZ && angle <= maxDetectionAngleZ;
};

// オブジェクトが回転するべきかを判定する関数（Y軸）
const isRotationNeededY = (angle) => {
    return angle >= -maxAngleY && angle <= maxAngleY;
};

// オブジェクトが回転するべきかを判定する関数（Z軸）
const isRotationNeededZ = (angle) => {
    return angle >= -maxAngleZ && angle <= maxAngleZ;
};

$.onUpdate(deltaTime => {
    let position = $.getPosition();
    let players = $.getPlayersNear(position, maxDistance);

    let targetPlayer = null;
    let targetDistance = Infinity;

    players.forEach(player => {
        let playerPosition = player.getPosition();
        let direction = playerPosition.clone().sub(position);
        let angleY = rad2deg(Math.atan2(direction.x, direction.z)); // Y軸回転角度（左右）
        let angleZ = rad2deg(Math.atan2(direction.y * -1, direction.z)); // Z軸回転角度（上下）

        let distance = direction.length();
        $.log(`距離: ${distance}`);

        // プレイヤーが判定範囲内かつ距離条件を満たすかどうかをチェック
        if (isPlayerInDetectionRangeY(angleY) && isPlayerInDetectionRangeZ(angleZ) && distance >= minDistance && distance <= maxDistance) {
            if (distance < targetDistance) {
                targetDistance = distance;
                targetPlayer = player;
                lastDetectedTime = Date.now(); // プレイヤーが検出された時間を更新
            }
        }else{
            $.log(`Nan`);
            $.log(`距離: ${angleY}`);
            $.log(`距離: ${angleZ}`);
        }
    });

    if (targetPlayer) {
        let targetPosition = targetPlayer.getPosition();
        let direction = targetPosition.clone().sub(position).normalize();

        // 左右（Y軸）ターゲット角度を計算
        let targetRotationY = rad2deg(Math.atan2(direction.x, direction.z));

        // 上下（Z軸）ターゲット角度を計算
        let targetRotationZ = rad2deg(Math.atan2(direction.y * -1, direction.z));

        $.log(`Before Z: ${targetRotationZ}`);

        // Z軸に関しては、20度を基準に制御
        if (targetRotationZ > 20 && targetRotationZ < 30) {
            targetRotationZ = (targetRotationZ - 20) * 0.2; // 上昇する場合は1/5倍
        } else if (targetRotationZ <= 20) {
            targetRotationZ = (targetRotationZ - 20); // 減少する場合はそのまま反転
            if (targetRotationZ < -20) {
                targetRotationZ = -20; // 下限を-20に設定
            }
        } else if (targetRotationZ >= 30) {
            targetRotationZ = -(targetRotationZ - 30) * 0.2; // 30以上の場合は反転して1/5倍
        }

        $.log(`After Z: ${targetRotationZ}`);

        // Y軸の回転処理
        if (isRotationNeededY(targetRotationY)) {
            currentRotationY = currentRotationY + (targetRotationY - currentRotationY) * Math.min(rotationSpeed * deltaTime, 1);
        }

        // Z軸の回転処理
        if (isRotationNeededZ(targetRotationZ)) {
            currentRotationZ = currentRotationZ + (targetRotationZ - currentRotationZ) * Math.min(rotationSpeed * deltaTime, 1);
        }

        // 回転の設定
        let rotation = new Quaternion().setFromEulerAngles(new Vector3(currentRotationZ, currentRotationY, 0));
        $.setRotation(rotation);

    } else if (Date.now() - lastDetectedTime > resetDelay * 1000) {
        // プレイヤーが判定範囲外に出てから2秒経過後に回転をリセット
        currentRotationY = currentRotationY + (0 - currentRotationY) * Math.min(rotationSpeed * deltaTime, 1);
        currentRotationZ = currentRotationZ + (0 - currentRotationZ) * Math.min(rotationSpeed * deltaTime, 1);

        let rotation = new Quaternion().setFromEulerAngles(new Vector3(currentRotationZ, currentRotationY, 0));
        $.setRotation(rotation);
    }
});
