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