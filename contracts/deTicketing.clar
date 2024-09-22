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
