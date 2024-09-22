;; deTicketing
;; This smart contract handles event management and ticketing. It allows event organizers to create events,
;; sell tickets to users, transfer ownership of tickets, and issue refunds. The contract also tracks the number of 
;; events and tickets created.

;; constants
;; Add any constants here if needed (e.g., for error codes or standard prices)

;; data maps and vars
;;

;; Define an event structure
;; `events` map holds event details, indexed by `event-id`. Each event stores:
;; - `organizer`: the principal who created the event
;; - `total-tickets`: the total number of tickets available for the event
;; - `price`: the price of each ticket (in STX)
;; - `tickets-remaining`: the number of tickets still available
(define-map events
  {event-id: uint}
  {
    organizer: principal,
    total-tickets: uint,
    price: uint,
    tickets-remaining: uint
  }
)

;; Define a ticket ownership structure
;; `tickets` map holds information about each ticket, indexed by `ticket-id`. Each ticket stores:
;; - `event-id`: the ID of the event this ticket belongs to
;; - `owner`: the principal who owns the ticket
(define-map tickets
  {ticket-id: uint}
  {
    event-id: uint,
    owner: principal
  }
)

;; Track total number of events and tickets
;; `event-counter`: keeps track of how many events have been created.
;; `ticket-counter`: keeps track of how many tickets have been issued.
(define-data-var event-counter uint u0)
(define-data-var ticket-counter uint u0)

;; private functions
;; None in this implementation but can be added later if internal operations need encapsulation.

;; public functions
;;

;; Event creation
;; Allows an organizer to create a new event by specifying the total number of tickets and the ticket price.
;; Ensures that the total number of tickets and the price are both greater than zero.
;; Increments the event counter after successfully creating the event and stores the event details.
(define-public (create-event (total-tickets uint) (price uint))
  (begin
    ;; Ensure total-tickets is greater than zero
    (asserts! (> total-tickets u0) (err u8))
    ;; Ensure price is greater than zero
    (asserts! (> price u0) (err u9))
    (let ((new-event-id (var-get event-counter)))
      ;; Store the event details
      (map-set events {event-id: new-event-id}
        {
          organizer: tx-sender,
          total-tickets: total-tickets,
          price: price,
          tickets-remaining: total-tickets
        }
      )
      ;; Increment the event counter for the next event
      (var-set event-counter (+ new-event-id u1))
      (ok new-event-id)
    )
  )
)


;; Ticket purchase
;; Allows a user to purchase a ticket for a specified event (by `event-id`).
;; Ensures the event exists, tickets are still available, and the buyer has enough STX to cover the ticket price.
;; Transfers the STX payment to the event organizer and assigns the ticket to the buyer.
;; Increments the ticket counter for each new ticket sold.
(define-public (buy-ticket (event-id uint))
  (begin
    ;; Validate event-id
    (asserts! (is-some (map-get? events {event-id: event-id})) (err u10))
    (let (
      (event (unwrap! (map-get? events {event-id: event-id}) (err u0)))
      (price (get price event))
      (organizer (get organizer event))
      (tickets-remaining (get tickets-remaining event))
    )
      ;; Ensure tickets are available
      (asserts! (> tickets-remaining u0) (err u1))

      ;; Ensure buyer has sent the correct amount
      (asserts! (>= (stx-get-balance tx-sender) price) (err u2))

      ;; Generate a new ticket ID
      (let ((new-ticket-id (var-get ticket-counter)))

        ;; Transfer the payment to the organizer
        (try! (stx-transfer? price tx-sender organizer))

        ;; Mint the ticket and assign it to the buyer
        ;; #[allow(unchecked_data)]
        (map-set tickets {ticket-id: new-ticket-id}
          {
            event-id: event-id,
            owner: tx-sender
          }
        )

        ;; Update the remaining tickets for the event
        ;; #[allow(unchecked_data)]
        (map-set events {event-id: event-id}
          (merge event {tickets-remaining: (- tickets-remaining u1)})
        )

        ;; Increment the ticket counter for future tickets
        (var-set ticket-counter (+ new-ticket-id u1))

        (ok new-ticket-id)
      )
    )
  )
)

;; Ticket transfer
;; Allows the owner of a ticket to transfer it to another user.
;; Validates the `ticket-id` and ensures that the current owner is the sender of the transaction.
(define-public (transfer-ticket (ticket-id uint) (new-owner principal))
  (begin
    ;; Validate ticket-id
    (asserts! (is-some (map-get? tickets {ticket-id: ticket-id})) (err u12))
    (let (
      (ticket (unwrap! (map-get? tickets {ticket-id: ticket-id}) (err u3)))
      (ticket-owner (get owner ticket))
    )
      ;; Ensure the sender owns the ticket
      (asserts! (is-eq tx-sender ticket-owner) (err u4))

      ;; Transfer the ticket ownership
      ;; #[allow(unchecked_data)]
      (map-set tickets {ticket-id: ticket-id}
        (merge ticket {owner: new-owner})
      )
      (ok true)
    )
  )
)


;; Ticket refund
;; Allows the event organizer to refund a ticket, returning the STX to the ticket owner.
;; Deletes the ticket and increases the number of remaining tickets for the event.
(define-public (refund-ticket (ticket-id uint))
  (begin
    ;; Validate ticket-id
    (asserts! (is-some (map-get? tickets {ticket-id: ticket-id})) (err u13))
    (let (
      (ticket (unwrap! (map-get? tickets {ticket-id: ticket-id}) (err u5)))
      (event-id (get event-id ticket))
      (event (unwrap! (map-get? events {event-id: event-id}) (err u6)))
      (organizer (get organizer event))
      (price (get price event))
      (ticket-owner (get owner ticket))
      (tickets-remaining (get tickets-remaining event))
    )
      ;; Ensure the organizer is initiating the refund
      (asserts! (is-eq tx-sender organizer) (err u7))

      ;; Refund the ticket price to the ticket owner
      (try! (stx-transfer? price tx-sender ticket-owner))

      ;; Remove the ticket from the records
      ;; #[allow(unchecked_data)]
      (map-delete tickets {ticket-id: ticket-id})

      ;; Increase the tickets-remaining count
      (map-set events {event-id: event-id}
        (merge event {tickets-remaining: (+ tickets-remaining u1)})
      )

      (ok true)
    )
  )
)