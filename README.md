# DeepPi-OLED: Thinking AI on Raspberry Pi 5 🧠

**DeepPi-OLED** brings the power of **DeepSeek R1** (Reasoning Model) to the Raspberry Pi 5 device. It features a push-to-talk voice interface and visualizes the AI's internal *Chain of Thought* process in real-time on an OLED display.

![DeepSeek R1](https://img.shields.io/badge/Model-DeepSeek%20R1-blue)
![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%205-red)
![Language](https://img.shields.io/badge/Language-Python-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🌟 Features

* 🗣️ **Voice Activated:** Physical push-to-talk mechanism using a USB microphone.
* 🧠 **Reasoning Display:** Watch the AI "think" before it speaks. The internal monologue is streamed to the OLED screen.
* 📺 **Matrix Terminal Effect:** Implements a scrolling terminal interface on the SSD1306 OLED.
* 🚀 **One-Command Install:** Automated setup script handles dependencies, Ollama installation, and environment configuration.

---

## 🛠️ Hardware Requirements

* **Raspberry Pi 5** (8GB RAM recommended for best token/sec, works on 4GB).
* **0.96" I2C OLED Display** (SSD1306 Driver).
* **USB Microphone**.
* **Push Button (Tactile Switch)**.
* **Active Cooler** (Required for sustained AI loads).

---

## 🔌 Wiring Diagram

| Component      | Raspberry Pi Pin | GPIO Number | Description           |
| -------------- | ---------------- | ----------- | --------------------- |
| **OLED VCC**   | Pin 1            | 3.3V        | Power (Do not use 5V) |
| **OLED GND**   | Pin 9            | GND         | Ground                |
| **OLED SDA**   | Pin 3            | GPIO 2      | I2C Data              |
| **OLED SCL**   | Pin 5            | GPIO 3      | I2C Clock             |
| **Button (+)** | Pin 11           | GPIO 17     | Signal                |
| **Button (-)** | Pin 14           | GND         | Ground                |

---

## 🚀 Installation

Open your Raspberry Pi terminal and run the following commands:

```bash
# 0. Install git
sudo apt install -y git

# 1. Clone the repository
git clone https://github.com/ibodeth/DeepPi-OLED.git

# 2. Enter the directory
cd DeepPi-OLED

# 3. Make the script executable
chmod +x install.sh

# 4. Run the installer
./install.sh
```

The script will automatically update the system, enable I2C, install Ollama, pull the DeepSeek-R1 model, and set up the Python environment.

---

## 🎮 Usage

Once the installation is complete, you don't need to navigate to folders. Just type `ai` anywhere in the terminal:

```bash
ai
```

Workflow:

* The OLED screen will show **READY**.
* Press and hold (or click) the Button.
* Speak your question into the microphone.
* Watch the screen — you will see the **[THINKING...]** phase first, followed by the **[ANSWER]**.

---

## 🧩 Customization

To change the language (e.g., to Turkish) or the model:

1. Edit the main file:

   ```bash
   nano ~/DeepPi/main.py
   ```

2. Change the speech language:

   ```python
   language = "tr-TR"
   ```

3. Change the model name:

   ```python
   MODEL_NAME = "llama3.2"
   ```

---

## 📜 License

This project is licensed under the **MIT License** — see the `LICENSE` file for details.

---

## ✨ Credits

Created by **İbrahim Nuryağınlı**
