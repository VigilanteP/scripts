from flask import Flask, request, abort
import logging

app = Flask(__name__)

@app.route('/validate-token', methods=['GET'])
def validate_token():
    # Set the expected token
    token_filepath = "/usr/bin/tokeup"
    token_file = open(token_filepath)
    expected_token = token_file.read().strip()

    for value in request.headers:
        print(value)

    client_token = request.headers.get('token')

    print("Checking auth...")
    print(f"Expected Token: {expected_token}")
    print(f"Client Token: {client_token}")
    if client_token == expected_token:
        return '', 200  # Valid token
    else:
        abort(401)  # Unauthorized

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)

