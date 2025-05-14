;; Metric Definition Contract
;; Standardizes sustainability measures across industries

(define-data-var admin principal tx-sender)

;; Map to store metric definitions
(define-map metrics uint
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    unit: (string-utf8 20),
    industry: (string-utf8 50),
    created-at: uint,
    is-active: bool
  }
)

;; Counter for metric IDs
(define-data-var metric-id-counter uint u1)

;; Public function to define a new metric (admin only)
(define-public (define-metric
    (name (string-utf8 100))
    (description (string-utf8 500))
    (unit (string-utf8 20))
    (industry (string-utf8 50)))
  (let ((new-id (var-get metric-id-counter)))
    (begin
      (asserts! (is-admin tx-sender) (err u403))
      (map-set metrics new-id
        {
          name: name,
          description: description,
          unit: unit,
          industry: industry,
          created-at: block-height,
          is-active: true
        }
      )
      (var-set metric-id-counter (+ new-id u1))
      (ok new-id)
    )
  )
)

;; Public function to update a metric (admin only)
(define-public (update-metric
    (id uint)
    (name (string-utf8 100))
    (description (string-utf8 500))
    (unit (string-utf8 20))
    (industry (string-utf8 50)))
  (begin
    (asserts! (is-admin tx-sender) (err u403))
    (asserts! (is-some (map-get? metrics id)) (err u404))
    (ok (map-set metrics id
      {
        name: name,
        description: description,
        unit: unit,
        industry: industry,
        created-at: (get created-at (unwrap-panic (map-get? metrics id))),
        is-active: true
      }
    ))
  )
)

;; Public function to deactivate a metric (admin only)
(define-public (deactivate-metric (id uint))
  (begin
    (asserts! (is-admin tx-sender) (err u403))
    (asserts! (is-some (map-get? metrics id)) (err u404))
    (ok (map-set metrics id
      (merge (unwrap-panic (map-get? metrics id)) { is-active: false })
    ))
  )
)

;; Read-only function to get metric details
(define-read-only (get-metric (id uint))
  (map-get? metrics id)
)

;; Read-only function to get current metric count
(define-read-only (get-metric-count)
  (var-get metric-id-counter)
)

;; Helper function to check if caller is admin
(define-private (is-admin (caller principal))
  (is-eq caller (var-get admin))
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) (err u403))
    (ok (var-set admin new-admin))
  )
)
