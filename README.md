Wilson Telematics Insurance
<div align="center">

A Complete iOS Telematics-Based Driving Behavior Analytics Application












Real-world driving behavior → route visualization → harsh events → phone usage → trip analytics.

</div>
📋 Table of Contents

Overview

Features

Screens

Architecture

Project Structure

Backend API

Installation

Configuration

Usage

Roadmap

License

🎯 Overview

Wilson Telematics Insurance is a full telematics pipeline application built to collect, process, and visualize real driving data.
It integrates:

Damoov / Mobile-Telematics SDK (native telematics data)

Node.js backend proxy (secure DataHub API calls)

SwiftUI iOS app (map, routes, events, stats)

Insurance-oriented driving metrics (risk factors)

This project is ideal for:

Usage-based insurance (UBI) modeling

Driving behavior analysis

Risk scoring research

Telematics prototype demonstration

✨ Features
🚗 iOS Telematics App (SwiftUI)

Login & authenticate with telematics credentials

Automatically track trips after login

Dashboard with:

Daily stats summary

Recent trips (distance / time / scores)

Trip list (see all)

Trip Detail View:

Beautiful A → B MapRoute

Blue polyline route

Start / End markers

Harsh event markers

Phone-usage event markers

Summary statistics (distance, duration, avg/max speed)

🗺 Screens

What the app currently supports:

📍 Trip Detail Map

Blue polyline for route

Start marker (“A”)

End marker (“B”)

Colored markers for events:

🟠 Harsh Braking

🟡 Harsh Acceleration

🔵 Harsh Cornering

📱 Phone usage (if available)

📊 Trip Summary

Shows:

Distance (km)

Duration (minutes)

Average speed

Max speed

🚨 Driving Events

Harsh braking count

Harsh acceleration count

Harsh cornering count

Phone usage seconds

Night driving ratio

Rush-hour ratio

🏗 Architecture
┌───────────────────────────────────────┐
│                iOS App               │
│ SwiftUI + MapKit + TelematicsService │
└─────────────────────┬─────────────────┘
                      │
                      ▼
┌───────────────────────────────────────┐
│         Node.js Proxy Backend         │
│ /api/trips                            │
│ /api/trips/:tripId/waypoints          │
│ /api/daily-stats                      │
└─────────────────────┬─────────────────┘
                      │
                      ▼
┌───────────────────────────────────────┐
│          Damoov DataHub APIs          │
│ Trips / Waypoints / Events / Stats    │
└───────────────────────────────────────┘

Key Principles

SDK Secrets stay on the backend (secure)

iOS uses only JWT & deviceToken

All high-frequency data from Damoov → backend → iOS

Combine + @Published for real-time UI updates

📁 Project Structure
WilsonTelematicsInsurance/
│
├── App/
│   ├── ContentView.swift
│   ├── AppDelegate.swift
│
├── Core/
│   ├── Models/
│   │   ├── Trip.swift
│   │   ├── DailyStat.swift
│   │   └── TripsResponse.swift
│   │
│   ├── Services/
│       ├── TelematicsService.swift
│       ├── TelematicsAuthManager.swift
│       └── PermissionManager.swift
│
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── RecentTripRow.swift
│   │
│   ├── TripDetail/
│       ├── TripDetailView.swift
│       └── TripMapView.swift
│
└── backend/
    └── server.js

🖥 Backend API
GET /api/trips

Returns list of user trips:

{
  "trips": [
    {
      "id": "...",
      "distanceKm": 7.86,
      "durationSec": 780,
      "averageSpeedKmh": 46.8,
      "maxSpeedKmh": 93,
      "harshAccelerationCount": 1,
      "harshBrakingCount": 1,
      "phoneUsageSeconds": 26
    }
  ]
}

GET /api/trips/:tripId/waypoints
{
  "tripId": "...",
  "polyline": [
    { "lat": 33.9, "lon": -117.6 }
  ],
  "speedSeries": [
    { "t": 0, "speedKmh": 12 }
  ],
  "events": [
    { "lat": 33.93, "lon": -117.65, "kind": "braking" }
  ]
}

GET /api/daily-stats

Daily aggregated stats (km, avg speed, etc.)

🚀 Installation
Clone the repo
git clone https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main
cd WilsonTelematicsInsurance-1.0-main

Install iOS dependencies

SPM automatically resolves Damoov SDK.

Run the Backend
cd backend
npm install
node server.js


Make sure .env contains:

SDK_SECRET=YOUR_DAMOOV_SECRET
PORT=4000

⚙️ Configuration
In TelematicsService.swift

SDK is initialized after login:

RPEntry.instance.virtualDeviceToken = credentials.deviceToken
RPEntry.instance.setEnableSdk(true)

Set backend URL:
private let backendBaseURL = URL(string: "http://YOUR_LOCAL_IP:4000")!

🕹 Usage

Register / Login

SDK begins tracking automatically

Trips sync to backend

You tap a trip → see route map + events

Dashboard summarizes your daily stats

🗺 Roadmap
Coming soon

📱 Phone-usage map markers

📈 Speed chart (beautified)

🌙 Night driving color overlays

⚠️ Speeding zone detection

📉 Risk scoring engine

💰 Insurance premium simulator

☁️ Firebase / Supabase trip storage

📄 License

This project is for education, research, and demonstration use only.
Telematics SDK belongs to Damoov / Mobile-Telematics and follows their license.
