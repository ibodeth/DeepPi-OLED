#!/bin/bash

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   DEEPSEEK R1 (7B) - RASPBERRY PI 5 INSTALLER     ${NC}"
echo -e "${CYAN}   (Fixed for Pi 5 & Debian Bookworm/Trixie)       ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. UPDATE
echo -e "${YELLOW}[1/8] Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. LIBRARIES (FIXED: Added python3-dev and libtiff-dev)
echo -e "${YELLOW}[2/8] Installing system dependencies...${NC}"
# 'python3-dev' is CRITICAL for compiling PyAudio
# 'libtiff-dev' replaces old libtiff5
sudo apt install -y python3-dev python3-venv python3-pip git portaudio19-dev libasound2-dev i2c-tools libopenjp2-7 libtiff-dev libjpeg-dev

# 3. I2C SETUP
echo -e "${YELLOW}[3/8] Enabling I2C Interface...${NC}"
sudo raspi-config nonint do_i2c 0
echo -e "${GREEN}I2C Enabled!${NC}"

# 4. OLLAMA
echo -e "${YELLOW}[4/8] Checking Ollama installation...${NC}"
if ! command -v ollama &> /dev/null
then
    curl -fsSL https://ollama.com/install.sh | sh
    echo -e "${YELLOW}Waiting for Ollama service to start...${NC}"
    sleep 10 # Wait for service to spin up
else
    echo -e "${GREEN}Ollama is already installed.${NC}"
fi

# 5. MODEL (7B)
echo -e "${YELLOW}[5/8] Pulling DeepSeek R1 (7B) model...${NC}"
# Check if ollama is running, if not start it
if ! pgrep -x "ollama" > /dev/null
then
    echo "Starting Ollama server..."
    ollama serve &
    sleep 5
fi
ollama pull deepseek-r1:7b

# 6. VENV
echo -e "${YELLOW}[6/8] Setting up Python Environment (~/DeepPi)...${NC}"
mkdir -p ~/DeepPi
cd ~/DeepPi

# Re-create venv to be safe
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo -e "${YELLOW}Installing Python libraries (This may take a while)...${NC}"
pip install --upgrade pip setuptools wheel

# FIX FOR PI 5: Use rpi-lgpio instead of RPi.GPIO
# FIX FOR AUDIO: PyAudio needs python3-dev (installed above)
pip install rpi-lgpio ollama luma.oled SpeechRecognition pyaudio requests

# 7. GENERATE PYTHON CODE
echo -e "${YELLOW}[7/8] Generating main.py...${NC}"

cat << 'EOF' > main.py
import time
import RPi.GPIO as GPIO
import speech_recognition as sr
import ollama
from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from luma.core.virtual import terminal
from PIL import ImageFont

# --- CONFIG ---
BUTTON_PIN = 17
MODEL_NAME = "deepseek-r1:7b" 
I2C_ADDR = 0x3C

# --- HARDWARE SETUP ---
try:
    serial = i2c(port=1, address=I2C_ADDR)
    device = ssd1306(serial)
    font = ImageFont.load_default()
    term = terminal(device, font)
except Exception as e:
    print(f"Display Error: {e}")
    print("Check your wiring and I2C address.")
    exit()

# Microphone
recognizer = sr.Recognizer()
try:
    mic = sr.Microphone()
except:
    print("Microphone not found! Check USB connection.")

GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

def listen_for_speech():
    term.clear()
    term.println("LISTENING...")
    with mic as source:
        recognizer.adjust_for_ambient_noise(source, duration=0.5)
        try:
            # Listen for 5-8 seconds
            audio = recognizer.listen(source, timeout=5, phrase_time_limit=8)
            term.println("PROCESSING...")
            # Using English for global compatibility
            text = recognizer.recognize_google(audio, language="en-US")
            return text
        except Exception:
            return None

def process_ai_flow(question):
    term.clear()
    term.println(f"> {question[:15]}...")
    term.println("-" * 20)
    
    try:
        stream = ollama.chat(
            model=MODEL_NAME,
            messages=[{'role': 'user', 'content': question}],
            stream=True,
        )

        is_thinking = False
        
        for chunk in stream:
            content = chunk['message']['content']
            if not content: continue
                
            if "<think>" in content:
                is_thinking = True
                term.println("[THINKING...]")
                content = content.replace("<think>", "")
            
            if "</think>" in content:
                is_thinking = False
                term.println("")
                term.println("[ANSWER]:")
                term.println("-" * 20)
                content = content.replace("</think>", "")

            if content.strip(): 
                term.print(content)
                
        term.println("\n[DONE]")
        
    except Exception as e:
        term.println(f"Error: {str(e)[:10]}")

# --- MAIN LOOP ---
term.clear()
term.println("DEEP-PI R1")
term.println("READY.")
term.println("PRESS BUTTON.")
print("System Ready. Press Ctrl+C to exit.")

try:
    while True:
        if GPIO.input(BUTTON_PIN) == False:
            question = listen_for_speech()
            if question:
                process_ai_flow(question)
            else:
                term.println("No Audio/Error")
                time.sleep(1)
            
            time.sleep(3)
            term.clear()
            term.println("READY.")
            
        time.sleep(0.1)

except KeyboardInterrupt:
    GPIO.cleanup()
    term.clear()
    print("\nExiting...")
EOF

# 8. CREATE COMMAND
echo -e "${YELLOW}[8/8] Creating 'ai' command...${NC}"

cat << 'EOF' > ai_launcher
#!/bin/bash
cd ~/DeepPi
source venv/bin/activate
python main.py
EOF

sudo mv ai_launcher /usr/local/bin/ai
sudo chmod +x /usr/local/bin/ai

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE! (7B Model)               ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${CYAN}You can now run the AI by typing:${NC}"
echo -e "   ${YELLOW}ai${NC}"