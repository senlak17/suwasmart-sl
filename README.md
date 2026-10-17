# Suvavi — Regional Smart Hospital & AI Channeling Network

**Suvavi** is an AI-native regional healthcare and hospital queue-management platform built with [Jac](https://www.google.com/search?q=https%3A%2F%2Fjaclang.org%2F) and [JacHammer](https://www.google.com/search?q=https%3A%2F%2Fjachammer.ai%2F) to eliminate long outpatient waiting times across Sri Lanka. It connects patients, doctors, diagnostic laboratories, and hospital administrators within customizable **Regional Hospital Networks**, delivering location-aware specialist matching, live arrival-time predictions, and WhatsApp-style agentic triage.

## Short GitHub "About" Description (Copy-Paste for Repo Sidebar)

> AI-powered regional hospital channeling, WhatsApp symptom triage, 1990 Suwa Seriya emergency dispatch, and live queue delay prediction app for Sri Lanka—built with Jac & JacHammer.

**Suggested GitHub Topics:** `jaclang` `jaseci` `jachammer` `agentic-ai` `healthcare` `sri-lanka` `smart-hospital` `whatsapp-bot` `queue-management`

## Core Features

- **Customizable Regional Hospital Networks**: Dynamically tailors hospital, specialist, diagnostic lab, and ambulance routing based on the patient's home address or live selected town/region across Sri Lanka.
- **1-Click 1990 Suwa Seriya Emergency Dispatch**: Provides immediate pre-login and in-chat emergency dispatch to [1990 Suwa Seriya](https://www.google.com/search?q=https%3A%2F%2Fwww.1990.lk%2F) with location and landmark sharing routed to the nearest regional emergency unit.
- **WhatsApp-Style Agentic Symptom Triage (`by llm()`)**: Evaluates symptom location, pain type, duration, severity, allergies, and medical history to recommend either an **Immediate Online GP** consultation (within minutes) or an **Optimal Regional Specialist**.
- **Predictive Queue & Doctor Delay Alerts**: Calculates real-time hospital arrival windows per token number whenever a doctor is delayed, advances the active token, or cancels a physical session—pushing automated WhatsApp notifications so patients never wait for hours in crowded hospital hallways.
- **AI-Suggested & Direct Diagnostic Lab Booking**: Suggests targeted blood tests or imaging scans from symptom triage (or allows direct self-booking) at diagnostic centers inside the patient's active regional network.
- **Longitudinal Health Situation Tracker**: Tracks completed lab and scan metrics chronologically with color-coded clinical flags (`Normal`, `Borderline`, `Attention Required`) and a 30-second clinical brief for doctors.

## Three Role-Based Portals

| Portal | Key Capabilities |
| :--- | :--- |
| **Patient** | Register/login with medical history & allergies, trigger 1990 emergency dispatch, chat with the WhatsApp AI triage agent, book online/physical channeling and lab scans, receive live delay alerts, and track health reports over time. |
| **Doctor & Lab Staff** | **Doctors:** View daily token queues, review 30-second AI patient clinical briefs, conduct online sessions, and update live delay/token status.<br>**Lab Staff:** Manage regional test/scan workflows and publish structured diagnostic results. |
| **Admin** | Configure regional hospital networks, onboard doctors and diagnostic centers, monitor live queue bottlenecks, and oversee emergency dispatch logs. |

## Built With

- **[Jac Programming Language](https://www.google.com/search?q=https%3A%2F%2Fjaclang.org%2F) ([Jaseci](https://www.google.com/search?q=https%3A%2F%2Fwww.jaseci.org%2F))**: Object-Spatial Programming (`node`, `edge`, `walker`), Meaning-Typed AI (`by llm()`), and full-stack UI in a single unified codebase.
- **[JacHammer](https://www.google.com/search?q=https%3A%2F%2Fjachammer.ai%2F)**: Browser-based AI development, verification, and cloud deployment.
