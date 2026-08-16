<div align="center">

# 💋 ColorOS Porting Project ✨

*That's that me espresso... but for your phone.* ☕

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-pink.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-ff69b4.svg?style=for-the-badge)](https://github.com/ozyern/coloros_port/graphs/commit-activity)

A *Short n' Sweet* toolkit for porting ColorOS and Realme UI to Snapdragon 865, 870, and 888 series devices. 

> *Please Please Please* read the docs before starting! Don't bring me to tears when your phone won't boot. 🥺

<br>
</div>

---

## ☕ Getting Started

*Skip the small talk. Here's the whole thing.* 💅

```bash
# 1. Pour the willpower (installs every dependency — needs sudo on Linux)
./willpower.sh

# 2. Espresso in, ColorOS out
./brina.sh <BASEROM.zip> <PORTROM.zip> [PORTROM2.zip] [PARTITIONS]
```

Your flashable zip lands in `out/`. That's that me espresso. ☕

| 🎀 Script | 💋 What it does |
| :--- | :--- |
| `brina.sh` | The main event. Does the actual porting, start to finish. |
| `caffeine.sh` | The helper library — logging, patching, all the little functions that keep `brina.sh` awake. Sourced automatically. |
| `willpower.sh` | One-time dependency setup. Run it before anything else. |

> Both local files and download links work as arguments — hand it a URL and it'll fetch the ROM itself. *No nonsense.* ✨

---

## 📱 Supported Hardware

*Because we love a good match. Is it that sweet? I guess so.* 💅

| 🫀 Chipset | 📱 Verified Devices |
| :--- | :--- |
| **Snapdragon 865/870** | OnePlus 8 Series, OnePlus 9R, OPPO Find X3 |
| **Snapdragon 888** | OnePlus 9 Series (Tested on 9 Pro), OPPO Find X3 Pro |

---

## 🔍 Tested ROMs

*We’ve got the receipts. No nonsense here.* 📝

### 🏠 Base Firmware (Host)
* **OnePlus 8 / 8T / 8 Pro:** `KB2003_14.0.0.600`, `IN2013_13.1.190`, `IN2023_13.1.0.190`
* **OnePlus 9 Pro:** `LE2123_14.0.0.1902`

### 🎯 Target Port ROMs
* **ColorOS 16:** OnePlus 15T (`16.0.5.703`), Find X9 Ultra (`16.0.5.702`)
* **OxygenOS 16:** OnePlus 15 (`16.0.7.201`)
* **Realme UI 7:** Realme GT 8 Pro (`16.0.5.704`)



---

## 🛠 Feature Status

*What's working like a dream, and what's... well, a little bit of a mess.* 🪶

### ✨ Working Perfectly
- **Security:** Face Unlock & Fingerprint (Biometrics) 💋
- **Connectivity:** NFC & Network 📶
- **Hardware:** Camera & Automatic Brightness 📸

### 🚩 Known Bugs
*Don't say I didn't warn you...*

- 🔅 **AOD:** Display is too dim on SM8250 devices.
- 🎥 **Multimedia:** Video recording is currently broken on 8 Series and 9R.
- 🔌 **Audio/Power:** Voice triggers, wired earphones, and power-off charging are taking a sick day.

---

<div align="center">

**⚠️ Disclaimer:** Porting ROMs carries a risk of bricking your device. Always backup your data before proceeding. *Taste* the danger, but stay safe! 🔪🎀

</div>
