# Everything Even Hub for Codex

## 下載套裝

請下載 repository 根目錄中的 **`everything-evenhub-codex-0.1.0.zip`**：

[下載 Everything Even Hub Codex ZIP 套裝](https://github.com/ahui3c/everything-evenhub-codex/raw/refs/heads/main/everything-evenhub-codex-0.1.0.zip)

目前未另外發布 GitHub Release；請使用上方的 ZIP 直接下載連結。下載後請先完整解壓縮，再依照下方步驟安裝。

## 繁體中文安裝說明

這個可攜式套裝可將 13 個 Even Realities 開發技能安裝到 Codex，涵蓋 Even G2 應用程式建立、眼鏡介面、輸入控制、裝置功能、模擬器測試及打包部署。

### 系統需求

- Codex CLI 0.121 或更新版本
- Node.js 18 或更新版本（開發 Even Hub 應用程式時需要）

### Windows 一鍵安裝

1. 將 ZIP 壓縮檔完整解壓縮。
2. 在解壓後的 `evenhub-codex-bundle` 資料夾開啟 PowerShell。
3. 執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

安裝完成後，重新啟動 Codex 並開啟一個新任務，讓 Codex 載入新增的技能。

### 手動安裝

如果不想執行安裝腳本，請在解壓後的資料夾執行：

```powershell
codex plugin marketplace add .
codex plugin add everything-evenhub@even-realities-community
```

接著重新啟動 Codex，並開啟新任務。

### 使用範例

- `$quickstart my-even-app`：建立新的 Even G2 應用程式
- `$glasses-ui 建立包含三個項目的選單`：製作眼鏡顯示介面
- `$test-with-simulator 測試目前的應用程式`：使用模擬器測試
- `$build-and-deploy 打包這個應用程式`：建立可部署的套件

### 疑難排解

- 顯示找不到 `codex`：請先安裝或更新 Codex CLI，然後重新開啟 PowerShell。
- 安裝後看不到技能：請完全重新啟動 Codex，並使用新任務測試。
- Even Hub 開發工具無法執行：確認已安裝 Node.js 18 或更新版本。

---

## English installation guide

### Download the bundle

Download **`everything-evenhub-codex-0.1.0.zip`** from the repository root:

[Download the Everything Even Hub Codex ZIP bundle](https://github.com/ahui3c/everything-evenhub-codex/raw/refs/heads/main/everything-evenhub-codex-0.1.0.zip)

No separate GitHub Release is currently published. Use the direct ZIP link above, extract the archive completely, and then follow the installation steps below.

This portable bundle installs 13 Even Realities development skills into Codex.

## Requirements

- Codex CLI 0.121 or newer
- Node.js 18 or newer for Even Hub development

## Windows one-command install

Open PowerShell in this extracted folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Codex and open a new task after installation.

## Manual install

From this extracted folder, run:

```powershell
codex plugin marketplace add .
codex plugin add everything-evenhub@even-realities-community
```

## Example requests

- `$quickstart my-even-app`
- `$glasses-ui Build a three-item menu`
- `$test-with-simulator Test the current app`
- `$build-and-deploy Package this app`

Upstream source: https://github.com/even-realities/everything-evenhub

License: MIT