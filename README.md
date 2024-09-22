# deTicketing - Event and Ticketing Smart Contract

deTicketing is a decentralized smart contract built on the Stacks blockchain using the Clarity programming language. It enables event organizers to create events, sell tickets, transfer ticket ownership, and issue refunds securely on-chain. All transactions are recorded in a transparent and immutable ledger, ensuring trust and traceability.

## Features

- **Event Creation**: Organizers can create events by specifying the number of tickets and the price for each ticket.
- **Ticket Purchase**: Users can securely purchase tickets for events using STX tokens.
- **Ticket Transfer**: Ticket owners can transfer their tickets to other users at any time.
- **Ticket Refund**: Organizers can refund ticket holders, returning the ticket price and reissuing the ticket.

## Technology Stack

- **Blockchain**: Stacks Blockchain (layer-1 blockchain, secured by Bitcoin)
- **Smart Contract Language**: Clarity (a safe, deterministic, and decidable language)

## Prerequisites

Before running or deploying the smart contract, you need the following tools installed:

- Stacks CLI or an IDE supporting Clarity (e.g., Clarinet)
- Stacks Wallet
- Basic knowledge of Clarity and smart contract development

## Contract Details

### Data Structures

- **Events (events map)**: Stores event details such as the organizer, total tickets, ticket price, and remaining tickets.
- **Tickets (tickets map)**: Tracks individual tickets, their owners, and the associated event.
- **Counters**:
    - `event-counter`: Keeps track of the number of events created.
    - `ticket-counter`: Tracks the total number of tickets issued.

### Public Functions

1. **create-event**

     Allows an event organizer to create a new event by specifying:
     
     - `total-tickets`: Number of tickets available for the event.
     - `price`: Ticket price in STX.
     
     The function validates that both `total-tickets` and `price` are greater than zero, assigns an `event-id`, and stores the event details.

     ```clarity
     (define-public (create-event (total-tickets uint) (price uint)) -> uint)
     ```

     Returns the unique `event-id` of the created event.

2. **buy-ticket**

     Allows users to purchase a ticket for a specific event:
     
     - `event-id`: The ID of the event they want to buy a ticket for.
     
     The function checks that tickets are available, ensures the user has sufficient STX, and transfers the payment to the organizer. A new ticket is minted and assigned to the buyer.

     ```clarity
     (define-public (buy-ticket (event-id uint)) -> uint)
     ```

     Returns the `ticket-id` of the purchased ticket.

3. **transfer-ticket**

     Allows a ticket owner to transfer ownership of their ticket to another user:
     
     - `ticket-id`: The ID of the ticket to be transferred.
     - `new-owner`: The principal of the new ticket owner.
     
     The function ensures the sender owns the ticket and updates the ticket ownership.

     ```clarity
     (define-public (transfer-ticket (ticket-id uint) (new-owner principal)) -> bool)
     ```

     Returns true on a successful transfer.

4. **refund-ticket**

     Allows the event organizer to refund a ticket holder:
     
     - `ticket-id`: The ID of the ticket being refunded.
     
     The function transfers the ticket price back to the owner and deletes the ticket record, making the ticket available again for purchase.

     ```clarity
     (define-public (refund-ticket (ticket-id uint)) -> bool)
     ```

     Returns true upon a successful refund.

## Installation & Usage

### Clone the Repository

```bash
git clone https://github.com/Armolas/Decentralized-Ticketing.git
cd Decentralized-Ticketing
```

### Compile the Contract

Use Clarinet to compile the contract:

```bash
clarinet check
```

### Test the Contract

Run unit tests to ensure everything is working:

```bash
clarinet test
```

### Deploy the Contract

Before deploying, make sure you have a valid Stacks wallet with some STX available. Deploy the contract using Stacks CLI or through Hiro Wallet and Clarinet.

Example CLI command for deployment:

```bash
clarinet contract deploy deTicketing --network testnet
```

### Interact with the Contract

You can interact with the contract using the Stacks Explorer or CLI commands to invoke the functions.

## Error Codes

- `u8`: Invalid number of total tickets (must be greater than 0).
- `u9`: Invalid ticket price (must be greater than 0).
- `u10`: Event not found.
- `u1`: No tickets available.
- `u2`: Insufficient balance to purchase the ticket.
- `u12`: Invalid ticket ID.
- `u3`: Unauthorized action on the ticket.
- `u7`: Only the event organizer can refund tickets.

## Contributing

If you'd like to contribute to deTicketing, feel free to submit pull requests or open issues on the GitHub repository.

1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -m "Add new feature"`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please contact:

- **GitHub**: [Armolas](https://github.com/Armolas)
- **Email**: [armolas06@gmail.com](mailto:armolas06@gmail.com)
