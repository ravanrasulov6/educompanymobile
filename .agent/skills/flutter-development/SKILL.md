---
name: flutter-development
description: Build premium cross-platform mobile apps using Flutter and Dart. Includes 3D hero animations, clean Material 3 UI, state management (Provider/BLoC), navigation, API integration, and production-ready architecture.
---

# Flutter Development

## Overview

Build high-performance, visually stunning, and premium mobile applications using Flutter with Dart.  
This skill focuses on clean architecture, minimal yet elegant UI design, advanced navigation, scalable state management, and smooth 3D-powered onboarding experiences.

Designed for enterprise-level mobile products that require performance, scalability, and polished UX.

---

## When to Use

- Building iOS and Android apps with near-native performance
- Creating premium minimal UI with Material 3
- Implementing interactive 3D animations (Rive / Lottie / Spline)
- Developing scalable apps with Provider or BLoC
- Integrating REST APIs and secure authentication
- Rapid iteration using Hot Reload
- Delivering consistent cross-platform UX

---

# Core Design Philosophy

## Premium + Minimal UI

- Clean layout with generous white space
- Limited color palette (1 primary + neutral tones)
- Soft shadows and rounded corners
- Smooth micro-interactions
- Clear typography hierarchy (Title / Body / Caption)
- Subtle motion transitions

---

# First Screen Requirement (Hero Landing Screen)

## Welcome / Landing Page Structure

### Layout:

- Top: App logo + brand name
- Center: **3D Animated Student Character (Hero Section)**
- Bottom: 3 Primary CTA buttons:

1. **Premium Sign Up**
2. **Log In**
3. **Continue as Guest**

---

## 3D Animation Guidelines

The landing screen must include a high-quality 3D student-themed animation.

### Recommended Tools:
- Rive (preferred for interactive animations)
- Lottie (lightweight vector animations)
- Spline (3D exported asset)

### Performance Requirements:
- 60 FPS smooth rendering
- Optimized asset size
- Lazy load animation after first frame
- Use `RepaintBoundary` where needed

---

# Project Structure Recommendation

