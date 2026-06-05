# Android MultiUser Enabler

> English version: [README.en.md](README.en.md)

一個 Magisk 模組，用來在支援多使用者的 Android ROM 上開啟多使用者 UI、提高可建立的使用者數量，並在開機後嘗試自動啟動既有的非 owner 使用者。

這個模組不負責建立使用者或工作資料夾本身。它的定位是補上 Android 多使用者相關的系統屬性與開機後啟動流程；建立、管理與突破建立限制建議交給下方搭配工具處理。

## 功能

- 開啟 Android 多使用者 UI：`fw.show_multiuserui=1`
- 提高可建立使用者數量：預設 `fw.max_users=50`
- 開機後等待系統完成啟動，再列出所有 Android 使用者
- 對一般非 owner 使用者寫入 setup / provisioned 狀態，然後執行 `am start-user`
- 在 Xiaomi 裝置上，對一般使用者移除 `com.android.updater`，降低 OTA 更新流程干擾
- 對 `999` 以上的特殊使用者，例如 Xiaomi Second Space / XSpace，只執行 `am start-user`，不修改 setup flag 或 package 狀態
- 寫入簡易 log，方便確認開機流程和失敗原因

## 建議搭配使用

| 專案 | 用途 | 建議搭配方式 |
| --- | --- | --- |
| [lokey0905/Multiisland](https://github.com/lokey0905/Multiisland) | 多 Island / 多工作資料夾場景 | 由 Multiisland 處理 profile / Island 端的建立與管理，本模組負責開啟多使用者 UI 與開機後嘗試啟動使用者。 |
| [icepony/AlwaysCreateUser](https://github.com/icepony/AlwaysCreateUser) | Xposed 模組，用於繞過 Android 使用者 / profile 建立限制 | 當系統顯示 `Maximum user limit is reached`、`Cannot add more managed profiles` 或類似建立失敗時，建議搭配使用。 |

建議分工如下：

1. 需要突破使用者或 profile 建立限制時，先準備 Xposed / LSPosed 環境並啟用 AlwaysCreateUser。
2. 需要管理多個 Island / 工作資料夾時，使用 Multiisland 處理 profile 側流程。
3. 安裝本 Magisk 模組，讓系統顯示多使用者 UI，並在每次開機後嘗試啟動既有使用者。

## 安裝需求

- 已 root 的 Android 裝置
- Magisk v20.4 或更新版本
- ROM / framework 本身仍需具備 Android 多使用者能力
- 如果要搭配 AlwaysCreateUser，需要另行準備 Xposed / LSPosed 類環境

## 安裝方式

1. 將本專案打包成 Magisk 可安裝 ZIP，ZIP 根目錄需保留 `module.prop`、`system.prop`、`service.sh` 和 `META-INF/`。
2. 在 Magisk App 中進入模組安裝。
3. 選取 ZIP 並安裝。
4. 重開機。
5. 依需求到系統設定、Multiisland 或其他 profile 管理工具建立使用者 / profile。

## 驗證

可在電腦端使用 adb 檢查：

```cmd
adb shell su -c "getprop fw.show_multiuserui"
adb shell su -c "getprop fw.max_users"
adb shell su -c "pm list users"
adb shell su -c "pm get-max-running-users"
adb shell su -c "cat /data/local/tmp/multiuserenabler.log"
```

預期狀態：

- `fw.show_multiuserui` 應為 `1`
- `fw.max_users` 應符合 `system.prop` 內設定，預設為 `50`
- `pm list users` 應能看到已建立的使用者 / profile
- log 內應能看到開機後解析使用者、Xiaomi OTA 處理、`am start-user` 的結果

## Log

- Log 檔案：`/data/local/tmp/multiuserenabler.log`
- Log tag：`MultiUserEnabler`

如果自動啟動失敗，先看 log 中對應使用者的 `am start-user` 回傳值與輸出。

## 故障排除

- 多使用者 UI 沒出現：確認 `getprop fw.show_multiuserui` 是否為 `1`，也要確認 ROM 沒有額外封鎖多使用者入口。
- 可以建立很多使用者，但開不起來：`fw.max_users` 只控制建立上限；同時執行上限請看 `pm get-max-running-users`。
- `am start-user` 失敗：查看 `/data/local/tmp/multiuserenabler.log`，確認是否達到系統同時執行使用者上限。
- 無法建立更多 profile：這通常不是本模組能單獨解決的範圍，建議搭配 AlwaysCreateUser。
- Island / managed profile 內的 App 仍被停用或暫停：profile owner / DPM policy 仍可能覆蓋 root package command，需要檢查 `dumpsys device_policy`。
- Xiaomi OTA App 在一般使用者中消失：這是目前 `service.sh` 的預期行為。

## 專案結構

- `module.prop`：Magisk 模組資訊
- `system.prop`：多使用者相關系統屬性
- `service.sh`：開機後處理使用者啟動、Xiaomi OTA 與 log 的腳本
- `META-INF/com/google/android/*`：Magisk 安裝所需檔案

## 注意事項

- 不同廠牌、Android 版本與 ROM 對多使用者支援差異很大，本模組不保證每台裝置都能正常使用。
- 同時啟動更多使用者會增加記憶體、背景服務與耗電壓力。
- 本模組不繞過所有 framework / device policy 限制；建立限制與 managed profile policy 建議交給對應工具處理。
