# F4FLEDSTIX EdgeTX Widget

A custom EdgeTX widget designed to manage LED strips dynamically based on telemetry, arm status, and stick positions on 360x240 radios.
Fully tested on **Helloradio V12 MAX**

## ⚙️ 1. Initial Configuration & Options
To set up and use the widget on your EdgeTX radio:
* 📂 **Hyper easy Installation:** Place the folder `/WIDGETS/` into the radio's SD card root directory
# **Then follow these steps**
* <img width="1920" height="800" alt="F4F_LEDSTIX" src="https://github.com/user-attachments/assets/61df0867-9636-4593-bb8f-37d3d3a32ab1" />
#Options:
* 🎨 **BgColor:** Main background color of radios interface.(Radio Shell)
* 🕹️ **StickColor:** Stick center points and highlight elements color.
* ⭕ **GimbalColor:** Base and grid color for stick simulators.
* 🌈 **RingColor:** Outer ring color of the gimbals.
* 📉 **TrailColor & TrailTime:** Stick movement trail color and persistence time (0.5s to 2.0s).
* 🎛️ **Op1 / Op2:** Secondary potentiometer assignments (`P1`, `P2`, `S1`, `S2`, `LS`, `RS`).


## 🚁 2. Arming & Throttle Animations
* 🔄 **Initial Scroll:** Upon arming, LEDs execute an inverted green scroll with the trail.
* ⚡ **Throttle Transition:** Shifts to a green throttle meter proportional to the throttle stick position.

## 🔋 3. Telemetry & Alerts
* 🔋 **Battery Voltage (`tx-voltage`):** Exact numerical value and graphical level indicator (Green: Optimal, Yellow: Normal, Red: Low
* 📶 **RSSI Indicator:** Center circle reflects signal quality and status (Green **A** when Armed, Red **D** when Disarmed).
* 🚨 **Link Alerts:** Visual flashes on telemetry loss or reconnection.

# F4Ftelem - EdgeTX Lua Widget

**F4Ftelem** is an advanced telemetry Lua widget designed for color-screen EdgeTX radios (such as the Helloradio v12 MAX. optimized specifically for FPV drones and radio control systems running **ExpressLRS (ELRS)**.

This widget combines a futuristic cut-box visual design with intelligent hybrid navigation between telemetry pages and an automated post-flight summary (*Flight Debrief*).

---

## 🚀 Key Features

* **Hybrid Navigation (Manual + Automatic):** 
  * Switch between pages manually using a configured channel/source (by moving to the endpoints $> 95\%$ or $< -95\%$).
  * If there is no manual input, the widget automatically cycles through pages based on a configurable interval timer.
* **4 Specialized Pages:**
  1. **POWER CORE:** Detailed battery monitoring (percentage, consumed capacity in mAh, real-time voltage, and current draw).
  2. **RF LINK [ELRS]:** Vital radio link metrics (Link Quality `RQly`, Antenna 1 RSSI, RSNR, Transmitter RSSI `TRSS`, and Transmission Power `TPWR`).
  3. **MISSION & STATUS:** Prominent flight timer and real-time connection status (`ONLINE` / `NO LINK`).
  4. **RACING TEAM:** Custom themed screen featuring a checkered flag design and FPV branding.
* **Flight Debrief (Post-Flight Summary):** As soon as telemetry is lost (motor disarmed or model out of range), the widget automatically displays a summary screen showing minimum voltage, minimum RF signal levels, and peak consumed capacity from the completed flight.

---

## 📂 Installation

1. Copy the `f4ftelem` folder to your radio SD card WIDGETS directory:
 
/WIDGETS/f4ftelem/main.lua


## 📜 License
This project is licensed under the **GNU General Public License v3.0 (GPLv3)**. See the `LICENSE` file for details.
