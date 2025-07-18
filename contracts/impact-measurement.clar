;; Impact Measurement Contract
;; Tracks charitable outcome effectiveness and measurable results

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-CAUSE-NOT-FOUND (err u102))

;; Data Variables
(define-data-var impact-counter uint u0)
(define-data-var total-beneficiaries uint u0)

;; Data Maps
(define-map impact-records
  { record-id: uint }
  {
    program-id: (string-ascii 50),
    cause-id: (string-ascii 50),
    beneficiaries-targeted: uint,
    beneficiaries-served: uint,
    outcome-metric: uint,
    cost-per-beneficiary: uint,
    timestamp: uint,
    reporter: principal
  }
)

(define-map program-summaries
  { program-id: (string-ascii 50) }
  {
    total-beneficiaries: uint,
    total-cost: uint,
    success-rate: uint,
    impact-score: uint,
    last-updated: uint
  }
)

(define-map cause-impact
  { cause-id: (string-ascii 50) }
  {
    total-programs: uint,
    total-beneficiaries: uint,
    average-success-rate: uint,
    total-investment: uint
  }
)

;; Private Functions
(define-private (calculate-success-rate (targeted uint) (served uint))
  (if (> targeted u0)
    (/ (* served u100) targeted)
    u0
  )
)

(define-private (calculate-cost-per-beneficiary (total-cost uint) (beneficiaries uint))
  (if (> beneficiaries u0)
    (/ total-cost beneficiaries)
    u0
  )
)

(define-private (update-program-summary (program-id (string-ascii 50)) (beneficiaries uint) (cost uint) (success-rate uint))
  (let (
    (current-summary (default-to
      { total-beneficiaries: u0, total-cost: u0, success-rate: u0, impact-score: u0, last-updated: u0 }
      (map-get? program-summaries { program-id: program-id })
    ))
    (timestamp (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (map-set program-summaries
      { program-id: program-id }
      {
        total-beneficiaries: (+ (get total-beneficiaries current-summary) beneficiaries),
        total-cost: (+ (get total-cost current-summary) cost),
        success-rate: success-rate,
        impact-score: (calculate-impact-score beneficiaries cost success-rate),
        last-updated: timestamp
      }
    )
  )
)

(define-private (calculate-impact-score (beneficiaries uint) (cost uint) (success-rate uint))
  ;; Impact score = (beneficiaries * success-rate) / (cost / 1000000)
  (if (> cost u0)
    (/ (* beneficiaries success-rate) (/ cost u1000000))
    u0
  )
)

(define-private (update-cause-impact (cause-id (string-ascii 50)) (beneficiaries uint) (investment uint) (success-rate uint))
  (let (
    (current-impact (default-to
      { total-programs: u0, total-beneficiaries: u0, average-success-rate: u0, total-investment: u0 }
      (map-get? cause-impact { cause-id: cause-id })
    ))
  )
    (map-set cause-impact
      { cause-id: cause-id }
      {
        total-programs: (+ (get total-programs current-impact) u1),
        total-beneficiaries: (+ (get total-beneficiaries current-impact) beneficiaries),
        average-success-rate: (/ (+ (* (get average-success-rate current-impact) (get total-programs current-impact)) success-rate) (+ (get total-programs current-impact) u1)),
        total-investment: (+ (get total-investment current-impact) investment)
      }
    )
  )
)

;; Public Functions
(define-public (record-impact (program-id (string-ascii 50)) (cause-id (string-ascii 50)) (beneficiaries-targeted uint) (beneficiaries-served uint) (total-cost uint))
  (let (
    (record-id (+ (var-get impact-counter) u1))
    (success-rate (calculate-success-rate beneficiaries-targeted beneficiaries-served))
    (cost-per-beneficiary (calculate-cost-per-beneficiary total-cost beneficiaries-served))
    (timestamp (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> beneficiaries-targeted u0) ERR-INVALID-AMOUNT)
    (asserts! (<= beneficiaries-served beneficiaries-targeted) ERR-INVALID-AMOUNT)

    (map-set impact-records
      { record-id: record-id }
      {
        program-id: program-id,
        cause-id: cause-id,
        beneficiaries-targeted: beneficiaries-targeted,
        beneficiaries-served: beneficiaries-served,
        outcome-metric: success-rate,
        cost-per-beneficiary: cost-per-beneficiary,
        timestamp: timestamp,
        reporter: tx-sender
      }
    )

    (update-program-summary program-id beneficiaries-served total-cost success-rate)
    (update-cause-impact cause-id beneficiaries-served total-cost success-rate)

    (var-set impact-counter record-id)
    (var-set total-beneficiaries (+ (var-get total-beneficiaries) beneficiaries-served))

    (ok record-id)
  )
)

(define-public (update-outcome-metric (record-id uint) (new-metric uint))
  (let (
    (record-data (unwrap! (map-get? impact-records { record-id: record-id }) ERR-CAUSE-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set impact-records
      { record-id: record-id }
      (merge record-data { outcome-metric: new-metric })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-impact-record (record-id uint))
  (map-get? impact-records { record-id: record-id })
)

(define-read-only (get-program-summary (program-id (string-ascii 50)))
  (map-get? program-summaries { program-id: program-id })
)

(define-read-only (get-cause-impact (cause-id (string-ascii 50)))
  (map-get? cause-impact { cause-id: cause-id })
)

(define-read-only (get-total-beneficiaries)
  (var-get total-beneficiaries)
)

(define-read-only (get-impact-count)
  (var-get impact-counter)
)

(define-read-only (calculate-program-efficiency (program-id (string-ascii 50)))
  (let (
    (summary (map-get? program-summaries { program-id: program-id }))
  )
    (match summary
      program-data (if (> (get total-cost program-data) u0)
                     (some (/ (get total-beneficiaries program-data) (/ (get total-cost program-data) u1000000)))
                     (some u0))
      none
    )
  )
)

(define-read-only (get-overall-success-rate)
  (let (
    (total-records (var-get impact-counter))
  )
    (if (> total-records u0)
      ;; This is a simplified calculation - in practice, you'd iterate through records
      u75 ;; Placeholder for average success rate
      u0
    )
  )
)
