# Initial Concept
PurePitch is a tool that can test a person's vocal pitch. Supports Android, iOS, Windows, MacOS, and Linux.

# Project Vision
PurePitch aims to be a cross-platform, high-performance, and premium local pitch analysis tool. It combines the processing power of a Rust core with the expressive UI capabilities of Flutter to provide a privacy-focused, real-time, and highly accurate pitch feedback experience.

# Target Audience
*   **Professional Singers & Vocal Learners**: Used for high-precision pitch practice and correcting vocal details.
*   **Music Enthusiasts**: Exploring personal vocal range and recording/tracking pitch performance over time.

# Core Features

* **Real-time Pitch Visualization**: Providing buttery smooth, persistent pitch curves with ultra-low latency frequency capture and wall-clock time anchoring.

* **Offline Audio-to-MIDI**: Leveraging the Basic Pitch model to convert external audio or local recordings into MIDI note sequences.

* **High-Precision & Stable Analysis**: Leveraging the Basic Pitch model combined with hysteresis/inertia algorithms to provide professional, continuous note extraction, preventing melody fragmentation.
* **Session Recording & Analysis**: Support for saving vocal sessions with analytical data playback overlays.
* **Horizontal Timeline**: A synchronized horizontal time ruler providing precise visual context for pitch events.
* **Accompaniment Sync**: Support for importing and playing backing tracks in sync with vocal recording and review.

# Visual Identity & UX
* **Immersive Premium Feel**: A professional modern interface combined with subtle background textures and fluid motion transitions.
* **Glowing Interactive Elements**: Key controls and pitch curves feature "glowing" visual effects to enhance tech-immersion.
* **Buttery Smooth Performance**: Optimized for high refresh rate displays, ensuring pitch curves flow like silk.
* **Adaptive Time Scaling**: The pitch visualization automatically scales between 5 and 10 seconds based on the screen width, with manual zoom controls and persistent session history.
* **Refined Control Layout**: A clean interface with a navigation drawer for secondary actions and a focused control bar for real-time audio settings.
* **Continuous Session Review**: Users can scroll back through their entire performance history after a recording session ends.

# Competitive Advantage
*   **Privacy & Performance**: All AI inference and processing happen locally on the device. Data never leaves the machine. Extreme performance is achieved through the Rust core.
*   **Multi-platform Consistency**: Delivering a highly consistent professional tool experience across Mobile (iOS/Android) and Desktop (macOS/Windows/Linux).
