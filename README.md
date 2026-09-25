# F4FLEDSTIX EdgeTX Widget

A custom EdgeTX widget designed to manage LED strips dynamically based on telemetry, arm status, and stick positions on 360x240 radios.

## ⚙️ 1. Initial Configuration & Options
To set up and use the widget on your EdgeTX radio:
* 📂 **Installation:** Place the script file into the `/WIDGETS/` folder on your radio's SD card.
* 🎨 **BgColor:** Main background color of radios interface.
* 🕹️ **StickColor:** Stick center points and highlight elements color.
* ⭕ **GimbalColor:** Base and grid color for stick simulators.
* 🌈 **RingColor:** Outer ring color of the gimbals.
* 📉 **TrailColor & TrailTime:** Stick movement trail color and persistence time (0.5s to 2.0s).
* 🎛️ **Op1 / Op2:** Secondary potentiometer assignments (`P1`, `P2`, `S1`, `S2`, `LS`, `RS`).

## 🚁 2. Arming & Throttle Animations
* 🔄 **Initial Scroll:** Upon arming, LEDs execute an inverted green scroll with the trail cleared for 1 second (50 ticks).
* ⚡ **Throttle Transition:** Shifts to a green throttle meter proportional to the throttle stick position.

## 🔋 3. Telemetry & Alerts
* 🔋 **Battery Voltage (`tx-voltage`):** Exact numerical value and graphical level indicator (Green: optimal, Yellow: 6.8V–7.4V, Red: <6.8V).
* 📶 **RSSI Indicator:** Center circle reflects signal quality and status (Green **A** when Armed, Red **D** when Disarmed).
* 🚨 **Link Alerts:** Visual flashes on telemetry loss or reconnection.

## 📜 License
This project is licensed under the **GNU General Public License v3.0 (GPLv3)**. See the `LICENSE` file for details.
