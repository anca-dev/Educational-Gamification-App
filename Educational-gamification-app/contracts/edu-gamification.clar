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

;; Create challenge
;;[#allow(unchecked_data)]
(define-public (create-challenge (subject (string-ascii 50)) (difficulty uint) (points uint))
    (let
        (
            (new-id (+ (var-get challenge-counter) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= difficulty u5) err-invalid-difficulty)
        (map-set challenges
            { challenge-id: new-id }
            {
                ;; #[allow(unchecked_data)]
                subject: subject,
                difficulty: difficulty,
                ;; #[allow(unchecked_data)]
                points: points,
                active: true,
                completions: u0
            }
        )
        (var-set challenge-counter new-id)
        (ok new-id)
    )
)

;; Complete challenge
;;[#allow(unchecked_data)]
(define-public (complete-challenge (challenge-id uint) (score uint))
    (let
        (
            (challenge (unwrap! (map-get? challenges { challenge-id: challenge-id }) err-not-found))
            (existing-progress (map-get? user-progress { user: tx-sender, challenge-id: challenge-id }))
            (current-stats (default-to { total-points: u0, challenges-completed: u0, level: u1 }
                (map-get? user-stats { user: tx-sender })))
            (current-time stacks-block-height)
        )
        (asserts! (get active challenge) err-inactive-challenge)
        (asserts! (is-none existing-progress) err-already-completed)
        (asserts! (<= score u100) err-invalid-score)
        (map-set user-progress
            ;; #[allow(unchecked_data)]
            { user: tx-sender, challenge-id: challenge-id }
            { completed: true, score: score, timestamp: current-time }
        )
        (map-set user-stats
            { user: tx-sender }
            {
                total-points: (+ (get total-points current-stats) (get points challenge)),
                challenges-completed: (+ (get challenges-completed current-stats) u1),
                level: (calculate-level (+ (get total-points current-stats) (get points challenge)))
            }
        )
        (map-set challenges
            ;; #[allow(unchecked_data)]
            { challenge-id: challenge-id }
            (merge challenge { completions: (+ (get completions challenge) u1) })
        )
        (unwrap! (update-streak tx-sender current-time) err-not-found)
        (unwrap! (update-subject-mastery tx-sender (get subject challenge) score) err-not-found)
        (ok true)
    )
)

;; Update challenge status
;;[#allow(unchecked_data)]
(define-public (toggle-challenge-status (challenge-id uint))
    (let
        (
            (challenge (unwrap! (map-get? challenges { challenge-id: challenge-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set challenges
            ;; #[allow(unchecked_data)]
            { challenge-id: challenge-id }
            (merge challenge { active: (not (get active challenge)) })
        )
        (ok true)
    )
)

;; Update challenge points
;;[#allow(unchecked_data)]
(define-public (update-challenge-points (challenge-id uint) (new-points uint))
    (let
        (
            (challenge (unwrap! (map-get? challenges { challenge-id: challenge-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> new-points u0) err-invalid-reward)
        (map-set challenges
            ;; #[allow(unchecked_data)]
            { challenge-id: challenge-id }
            (merge challenge { points: new-points })
        )
        (ok true)
    )
)

;; Create achievement
;;[#allow(unchecked_data)]
(define-public (create-achievement (name (string-ascii 50)) (description (string-ascii 100)) (points-required uint) (badge-type (string-ascii 20)))
    (let
        (
            (new-id (+ (var-get achievement-counter) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set achievements
            { achievement-id: new-id }
            {
                ;; #[allow(unchecked_data)]
                name: name,
                ;; #[allow(unchecked_data)]
                description: description,
                ;; #[allow(unchecked_data)]
                points-required: points-required,
                ;; #[allow(unchecked_data)]
                badge-type: badge-type
            }
        )
        (var-set achievement-counter new-id)
        (ok new-id)
    )
)

;; Unlock achievement
;;[#allow(unchecked_data)]
(define-public (unlock-achievement (achievement-id uint))
    (let
        (
            (achievement (unwrap! (map-get? achievements { achievement-id: achievement-id }) err-not-found))
            (user-stat (unwrap! (map-get? user-stats { user: tx-sender }) err-not-found))
            (existing-unlock (map-get? user-achievements { user: tx-sender, achievement-id: achievement-id }))
        )
        (asserts! (is-none existing-unlock) err-already-exists)
        (asserts! (>= (get total-points user-stat) (get points-required achievement)) err-invalid-score)
        (map-set user-achievements
            ;; #[allow(unchecked_data)]
            { user: tx-sender, achievement-id: achievement-id }
            { unlocked: true, unlock-timestamp: stacks-block-height }
        )
        (ok true)
    )
)