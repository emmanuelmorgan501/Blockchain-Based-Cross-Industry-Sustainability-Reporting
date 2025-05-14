;; Entity Verification Contract
;; Validates reporting organizations on the blockchain

(define-data-var admin principal tx-sender)

;; Map to store verified entities
(define-map verified-entities principal
  {
    name: (string-utf8 100),
    industry: (string-utf8 50),
    verification-date: uint,
    is-active: bool
  }
)

;; Public function to verify a new entity (admin only)
(define-public (verify-entity (entity principal) (name (string-utf8 100)) (industry (string-utf8 50)))
  (begin
    (asserts! (is-admin tx-sender) (err u403))
    (asserts! (is-none (map-get? verified-entities entity)) (err u100))
    (ok (map-set verified-entities entity
      {
        name: name,
        industry: industry,
        verification-date: block-height,
        is-active: true
      }
    ))
  )
)

;; Public function to revoke verification (admin only)
(define-public (revoke-verification (entity principal))
  (begin
    (asserts! (is-admin tx-sender) (err u403))
    (asserts! (is-some (map-get? verified-entities entity)) (err u404))
    (ok (map-set verified-entities entity
      (merge (unwrap-panic (map-get? verified-entities entity)) { is-active: false })
    ))
  )
)

;; Read-only function to check if an entity is verified
(define-read-only (is-verified (entity principal))
  (match (map-get? verified-entities entity)
    verified-data (get is-active verified-data)
    false
  )
)

;; Read-only function to get entity details
(define-read-only (get-entity-details (entity principal))
  (map-get? verified-entities entity)
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
