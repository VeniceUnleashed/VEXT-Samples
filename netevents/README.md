# NetEvents Demo:

This simple NetEvents demo shows how NetEvents can be used.
The example is very simple and shows sending to local client, broadcasting, passing arguments, ...
The example itself is useless but whats important is that it shows the concept and the idea behind.

- On player join a 'Player:Authenticated' event get triggered and handled in the server side
- The function that handle the event Send two events, one to the client that joined and another to all the players that are connected to the server
- When the function that handle the broadcast net event get called everyone will recevied in his even that a player joined the server
- When the function that handle the local net event sent by the server its going to print something in the consol, and then send another event to the server to confirm that the client recevied the event (this confirmation is useless, and its done here for demonstration purposes)
- Finally if everything goes fine, the server recevies the event from the client and print confirmation string on the server console

