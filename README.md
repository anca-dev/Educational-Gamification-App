# Educational Gamification Platform

A blockchain-based gamification system that makes learning engaging through challenges, points, and achievements for challenging subjects.

## Overview

This smart contract powers a gamified learning experience where students complete educational challenges, earn points, and level up. All progress is permanently recorded on the Stacks blockchain.

## Features

- **Challenge System**: Create educational challenges with difficulty ratings
- **Points & Scoring**: Earn points for completing challenges
- **Level Progression**: Automatic level calculation based on total points
- **Achievement Tracking**: Permanent record of completed challenges
- **Leaderboard Ready**: Query user statistics for competitive elements

## Contract Functions

### Public Functions

- `create-challenge`: Add new educational challenges (owner only)
- `complete-challenge`: Submit challenge completion with score

### Read-Only Functions

- `get-challenge`: Retrieve challenge details
- `get-user-progress`: Check specific challenge completion
- `get-user-stats`: View user's total points and level
- `get-challenge-count`: Get total available challenges

## Level System

- Level 1: 0-249 points
- Level 2: 250-499 points
- Level 3: 500-749 points
- Level 4: 750-999 points
- Level 5: 1000+ points

## Usage

1. Admin creates educational challenges
2. Students complete challenges and submit scores
3. System awards points and updates levels automatically
4. Progress is permanently recorded on blockchain

## Technology

- Clarity smart contracts
- Stacks blockchain
- Tamper-proof achievement records