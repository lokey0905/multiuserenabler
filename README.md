# Android 多使用者啟用模組（MultiUser Enabler）

這是一個 Magisk 模組，用來在裝置上啟用 Android 多使用者介面，並在開機後嘗試自動啟動其他已建立的使用者。

## 功能特色

- 啟用 Android 多使用者介面（`fw.show_multiuserui=1`）
- 設定最大使用者數（預設 `fw.max_users=5`）
- 開機完成後自動列出系統中所有使用者，並嘗試啟動非 0 號使用者
- 提供簡單日誌，便於除錯

## 專案結構

- `module.prop`：模組中繼資訊（名稱、版本、作者）
- `system.prop`：系統屬性設定（多使用者 UI 與最大使用者數）
- `service.sh`：開機後執行的腳本，負責自動啟動其他使用者
- `META-INF/com/google/android/*`：Magisk 安裝流程所需檔案

## 需求條件

- 已解鎖並可安裝 Magisk 模組的 Android 裝置
- Magisk v20.4 以上（由安裝腳本檢查）
- 裝置/ROM 需支援多使用者功能（部分廠商 ROM 可能限制）

## 安裝方式

1. 將本專案打包為可刷入的 Magisk ZIP（保留目前目錄結構）。
2. 開啟 Magisk App，進入模組安裝頁面。
3. 選取 ZIP 安裝。
4. 安裝完成後重新開機。

## 使用方式

1. 重開機後，進入系統設定中的使用者/多使用者選項。
2. 建立你需要的其他使用者。
3. 每次開機完成後，模組會嘗試啟動所有非 0 號使用者。

## 日誌與除錯

- 腳本日誌檔案：`/data/local/tmp/multiuseruienabler.log`
- 腳本 Tag：`MultiUserUIEnabler`

若發現沒有自動啟動成功，請先查看上述 log，並確認 ROM 是否允許背景啟動其他使用者。

## 可調整項目

你可以編輯 `system.prop` 來調整最大使用者數，例如：

- `fw.max_users=50` → 可改成你需要的上限
- `fw.show_multiuserui=1` → 保持為 1 才會顯示多使用者介面

## 注意事項

- 不同品牌/不同 Android 版本對多使用者功能的限制差異很大。
- `fw.max_users` 只代表可建立的使用者上限，不等於可同時執行的使用者數量。
- 實際可同時執行的上限受系統限制，請以 `pm get-max-running-users` 的結果為準。
- 若同時執行人數超過 `pm get-max-running-users` 上限，`am start-user` 可能失敗或被系統拒絕。
- 啟動多使用者可能增加記憶體占用與耗電。
- 本模組不保證在所有 ROM 上都能完整運作。

你可以用以下指令查看裝置限制：

```sh
pm get-max-running-users
```
