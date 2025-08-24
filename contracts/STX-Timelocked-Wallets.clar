;; Time-locked Wallet Smart Contract
;; Allows users to deposit STX tokens that can only be withdrawn after a specific block height

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_WALLET_NOT_FOUND (err u102))
(define-constant ERR_TIME_LOCK_ACTIVE (err u103))
(define-constant ERR_INVALID_BLOCK_HEIGHT (err u104))

;; Data maps
(define-map wallets 
  { owner: principal }
  { 
    balance: uint,
    unlock-height: uint,
    created-at: uint
  }
)

;; Private functions
(define-private (get-current-block-height)
  block-height
)

;; Public functions

;; Create a time-locked wallet with initial deposit
(define-public (create-wallet (unlock-height uint) (initial-deposit uint))
  (let ((current-height (get-current-block-height)))
    (asserts! (> unlock-height current-height) ERR_INVALID_BLOCK_HEIGHT)
    (asserts! (> initial-deposit u0) ERR_INSUFFICIENT_FUNDS)
    (try! (stx-transfer? initial-deposit tx-sender (as-contract tx-sender)))
    (map-set wallets 
      { owner: tx-sender }
      { 
        balance: initial-deposit,
        unlock-height: unlock-height,
        created-at: current-height
      }
    )
    (ok true)
  )
)

;; Add funds to existing wallet
(define-public (deposit (amount uint))
  (let ((wallet-data (unwrap! (map-get? wallets { owner: tx-sender }) ERR_WALLET_NOT_FOUND)))
    (asserts! (> amount u0) ERR_INSUFFICIENT_FUNDS)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set wallets
      { owner: tx-sender }
      (merge wallet-data { balance: (+ (get balance wallet-data) amount) })
    )
    (ok true)
  )
)

;; Withdraw funds (only after unlock height is reached)
(define-public (withdraw (amount uint))
  (let (
    (wallet-data (unwrap! (map-get? wallets { owner: tx-sender }) ERR_WALLET_NOT_FOUND))
    (current-height (get-current-block-height))
  )
    (asserts! (>= current-height (get unlock-height wallet-data)) ERR_TIME_LOCK_ACTIVE)
    (asserts! (<= amount (get balance wallet-data)) ERR_INSUFFICIENT_FUNDS)
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set wallets
      { owner: tx-sender }
      (merge wallet-data { balance: (- (get balance wallet-data) amount) })
    )
    (ok true)
  )
)

;; Withdraw all funds (only after unlock height is reached)
(define-public (withdraw-all)
  (let (
    (wallet-data (unwrap! (map-get? wallets { owner: tx-sender }) ERR_WALLET_NOT_FOUND))
    (current-height (get-current-block-height))
    (balance (get balance wallet-data))
  )
    (asserts! (>= current-height (get unlock-height wallet-data)) ERR_TIME_LOCK_ACTIVE)
    (asserts! (> balance u0) ERR_INSUFFICIENT_FUNDS)
    (try! (as-contract (stx-transfer? balance tx-sender tx-sender)))
    (map-delete wallets { owner: tx-sender })
    (ok balance)
  )
)

;; Read-only functions

;; Get wallet information for a specific owner
(define-read-only (get-wallet-info (owner principal))
  (map-get? wallets { owner: owner })
)

;; Get wallet balance for a specific owner
(define-read-only (get-wallet-balance (owner principal))
  (match (map-get? wallets { owner: owner })
    wallet (some (get balance wallet))
    none
  )
)

;; Get unlock height for a specific owner
(define-read-only (get-unlock-height (owner principal))
  (match (map-get? wallets { owner: owner })
    wallet (some (get unlock-height wallet))
    none
  )
)

;; Check if wallet is unlocked for a specific owner
(define-read-only (is-wallet-unlocked (owner principal))
  (match (map-get? wallets { owner: owner })
    wallet (>= (get-current-block-height) (get unlock-height wallet))
    false
  )
)

;; Get blocks remaining until unlock for a specific owner
(define-read-only (get-blocks-until-unlock (owner principal))
  (match (map-get? wallets { owner: owner })
    wallet 
      (let ((current-height (get-current-block-height))
            (unlock-height (get unlock-height wallet)))
        (if (>= current-height unlock-height)
          (some u0)
          (some (- unlock-height current-height))
        )
      )
    none
  )
)