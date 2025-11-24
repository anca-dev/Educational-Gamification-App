;; edu-gamification.clar
;; Educational gamification with challenges and achievements

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-completed (err u102))
(define-constant err-invalid-score (err u103))
(define-constant err-inactive-challenge (err u104))
(define-constant err-invalid-difficulty (err u105))
(define-constant err-streak-not-found (err u106))
(define-constant err-already-exists (err u107))
(define-constant err-invalid-reward (err u108))

;; Data variables
(define-data-var challenge-counter uint u0)
(define-data-var total-users uint u0)
(define-data-var achievement-counter uint u0)
(define-data-var leaderboard-size uint u10)

;; Data maps
(define-map challenges
    { challenge-id: uint }
    {
        subject: (string-ascii 50),
        difficulty: uint,
        points: uint,
        active: bool,
        completions: uint
    }
)

(define-map user-progress
    { user: principal, challenge-id: uint }
    { completed: bool, score: uint, timestamp: uint }
)

(define-map user-stats
    { user: principal }
    { total-points: uint, challenges-completed: uint, level: uint }
)

(define-map achievements
    { achievement-id: uint }
    {
        name: (string-ascii 50),
        description: (string-ascii 100),
        points-required: uint,
        badge-type: (string-ascii 20)
    }
)

(define-map user-achievements
    { user: principal, achievement-id: uint }
    { unlocked: bool, unlock-timestamp: uint }
)

(define-map daily-streaks
    { user: principal }
    { current-streak: uint, longest-streak: uint, last-activity: uint }
)

(define-map subject-mastery
    { user: principal, subject: (string-ascii 50) }
    { completed-challenges: uint, total-score: uint, mastery-level: uint }
)