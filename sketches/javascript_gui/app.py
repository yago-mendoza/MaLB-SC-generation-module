from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/send-message', methods=['POST'])
def send_message():
    data = request.get_json()
    user_message = data['message']
    
    # Here you would process the message and generate a response
    bot_response = generate_response(user_message)
    
    return jsonify({'reply': bot_response})

def generate_response(message):
    # This is where you'd implement your chatbot logic
    if 'shipping rates' in message.lower():
        return 'Shipping rates are $5 for orders under $50.'
    else:
        return 'I am not sure about that. Could you please clarify?'

if __name__ == '__main__':
    app.run(debug=True)
