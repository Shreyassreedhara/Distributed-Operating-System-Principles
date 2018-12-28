// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket

//Chart 2
var ctx1 = document.getElementById('myChart1').getContext('2d');
var chart1 = new Chart(ctx1, {
    // The type of chart we want to create
    type: 'line',

    // The data for our dataset
    data: {
        labels: ["0"],
        datasets: [{
            label: "Wallet Balances of users",
            backgroundColor: 'rgba(155, 89, 182,0.2)',
            borderColor: 'rgba(142, 68, 173,1.0)',
            pointBackgroundColor: "rgba(142, 68, 173,1.0)",
            data: [0],
        }]
    },

    // Configuration options go here
    options: {
      scales: {
            yAxes: [{
                ticks: {
                  max: 20,
                  min: -10,
                  stepSize: 2
                }
            }]
        }
    }
});

// let chatInput = $("#chat-input");
let messagesContainer = $("#messages");
let messagesContainer1 = $("#balances");

// var ctx = document.getElementById('myChart').getContext('2d');
// var chart = new Chart(ctx, {
//     // The type of chart we want to create
//     type: 'line',

//     // The data for our dataset
//     data: {
//         labels: ["0"],
//         datasets: [{
//             label: "Balances of all the users",
//             backgroundColor: 'rgb(255, 99, 132)',
//             borderColor: 'rgb(255, 99, 132)',
//             data: [0],
//         }]
//     },

//     // Configuration options go here
//     options: {
//       scales: {
//             yAxes: [{
//                 ticks: {
//                   max: 120,
//                   min: 90,
//                   stepSize: 3
//                 }
//             }]
//         }
//     }
// });



function addData(chart, label, data) {
      chart.data.labels.push(label);
      chart.data.datasets.forEach((dataset) => {
          dataset.data.push(data);
      });
      chart.update();
  }
channel.on("new_balance", payload1 => {
      messagesContainer1.append(`<br/><br/>[${Date()}] <br/>${"User: "}${payload1.nodeID}${" has a new balance of "}${payload1.bal}${" after mining"}`)
      // addData(chart,payload.trans,payload.coins)
    })
    
channel.on("new_chart", payload2 => {
      addData(chart,payload2.usernum,payload2.balfinal)
    })

channel.on("new_chart1", payload3 => {
      addData(chart1,payload3.usernum,payload3.balfinal)
    })
channel.on("new_message", payload => {
      messagesContainer.append(`<br/><br/>[${Date()}] <br/>${"New Transaction!"}<br/>${"Transaction number: "}${payload.number}<br/>${payload.sender} <br/>${payload.receiver} <br/>${payload.value}`)
      // addData(chart,payload.trans,payload.coins)
    })
