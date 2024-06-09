// script.js
document.addEventListener('DOMContentLoaded', function () {
    const sendButton = document.getElementById('send-button');
    const messageInput = document.getElementById('message-input');
    const chatBody = document.getElementById('chat-body');

    sendButton.addEventListener('click', function () {
        const message = messageInput.value;
        if (message.trim() !== '') {
            addMessage(message, 'user-message');
            messageInput.value = '';
            sendMessageToBackend(message);
        }
    });

    function addMessage(text, className) {
        const messageDiv = document.createElement('div');
        messageDiv.className = className;
        messageDiv.textContent = text;
        chatBody.appendChild(messageDiv);
        chatBody.scrollTop = chatBody.scrollHeight;
    }

    function sendMessageToBackend(message) {
        // This function will send the message to the backend (Python)
        fetch('http://127.0.0.1:5000/send-message', {  // Ensure this URL is correct
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: message })
        })
        .then(response => response.json())
        .then(data => {
            addMessage(data.reply, 'bot-message');
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
});
