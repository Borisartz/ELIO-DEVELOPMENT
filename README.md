<div align="center">

# 🤖 ELIO
### Smart Waste Sorting Robot — Mobile Controller App

![Flutter](https://img.shields.io/badge/Flutter-3.41.7-02569B?style=flat&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Connected-FFCA28?style=flat&logo=firebase)
![Android](https://img.shields.io/badge/Android-API%2036-3DDC84?style=flat&logo=android)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?style=flat&logo=dart)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=flat)

*A Flutter mobile app to control and monitor the ELIO waste sorting robot via WiFi and MQTT*

</div>

---

## 📱 About ELIO

ELIO is an AI-powered waste sorting robot that uses **YOLOv object segmentation** to classify waste into three categories:

| Category | Description |
|---|---|
| 🌿 Organic | Food waste, plant material |
| ♻️ Inorganic | Plastic, metal, glass, paper |
| ⚠️ Hazardous | Batteries, chemicals, medical waste |

This mobile app serves as the **remote controller and monitoring interface** for the ELIO robot, connecting via WiFi and MQTT protocol to an **ESP32-CAM** module.

---

## ✨ Features

- 🔐 **Authentication** — Google Sign-In, Email/Password, Guest mode
- 📚 **E-Learning** — Waste type education and management guides
- 🤖 **Robot Control** — D-pad controls via MQTT
- 📷 **Live Camera** — Real-time MJPEG stream from ESP32-CAM
- 🧠 **AI Detection** — YOLOv segmentation overlay on camera feed
- ⚙️ **ESP32 Config** — WiFi and MQTT broker configuration

---

## 🗺️ Development Roadmap
Phase 1 — Splash Screen          ✅ Complete
Phase 2 — Authentication         🔄 In Progress
Phase 3 — Home + Navigation      ⬜ Todo
Phase 4 — E-Learning Screen      ⬜ Todo
Phase 5 — ESP32-CAM Config       ⬜ Todo
Phase 6 — D-Pad + Camera         ⬜ Todo
