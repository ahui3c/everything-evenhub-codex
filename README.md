# Everything Even Hub for Codex

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

```powershell
codex plugin marketplace add .
codex plugin add everything-evenhub@even-realities-community
```

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

This portable bundle installs 13 Even Realities development skills into Codex.

### Requirements

- Codex CLI 0.121 or newer
- Node.js 18 or newer for Even Hub development

### Install

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Codex and open a new task after installation.

Upstream source: https://github.com/even-realities/everything-evenhub

License: MIT
